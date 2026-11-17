import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/constants/firestore_collections.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

/// [FE-01] Nguồn dữ liệu Firebase cho xác thực và quản lý hồ sơ người dùng.
abstract class AuthFirebaseDataSource {
  Stream<UserModel?> get authStateChanges;
  Future<UserModel> loginWithEmailPassword({required String email, required String password});
  Future<UserModel> registerWithEmailPassword({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  });
  Future<UserModel> signInWithGoogle();
  Future<void> resetPassword({required String email});
  Future<void> changePassword({required String currentPassword, required String newPassword});
  Future<UserModel> getCurrentUserProfile();
  Future<UserModel> updateProfile({
    required String fullName,
    required String phoneNumber,
    String? newAvatarFilePath,
  });
  Future<void> logout();
}

class AuthFirebaseDataSourceImpl implements AuthFirebaseDataSource {
  AuthFirebaseDataSourceImpl({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn(scopes: ['email', 'profile']),
        _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _firestore.collection(FirestoreCollections.users).doc(uid);

  @override
  Stream<UserModel?> get authStateChanges {
    return _auth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      try {
        final doc = await _userDoc(firebaseUser.uid).get();
        if (doc.exists && doc.data() != null) {
          return UserModel.fromFirestore(doc);
        }
        return UserModel(
          uid: firebaseUser.uid,
          fullName: firebaseUser.displayName ?? 'Du khách SmartTravel',
          email: firebaseUser.email ?? '',
          phoneNumber: firebaseUser.phoneNumber ?? '',
          avatarUrl: firebaseUser.photoURL,
        );
      } catch (_) {
        return UserModel(
          uid: firebaseUser.uid,
          fullName: firebaseUser.displayName ?? 'Du khách SmartTravel',
          email: firebaseUser.email ?? '',
          phoneNumber: firebaseUser.phoneNumber ?? '',
          avatarUrl: firebaseUser.photoURL,
        );
      }
    });
  }

  @override
  Future<UserModel> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = cred.user;
    if (user == null) {
      throw const AuthException('Đăng nhập thất bại. Không thể nhận diện người dùng.');
    }

    final docSnap = await _userDoc(user.uid).get();
    if (docSnap.exists) {
      final model = UserModel.fromFirestore(docSnap);
      if (!model.isActive) {
        await _auth.signOut();
        throw const AuthException('Tài khoản của bạn đã bị khóa bởi Quản trị viên.');
      }
      return model;
    }

    // Trường hợp chưa có doc trên Firestore (dự phòng)
    final newModel = UserModel(
      uid: user.uid,
      fullName: user.displayName ?? 'Du khách SmartTravel',
      email: user.email ?? email,
      createdAt: DateTime.now(),
    );
    await _userDoc(user.uid).set(newModel.toFirestore(), SetOptions(merge: true));
    return newModel;
  }

  @override
  Future<UserModel> registerWithEmailPassword({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = cred.user;
    if (user == null) {
      throw const AuthException('Không thể khởi tạo tài khoản lúc này.');
    }

    await user.updateDisplayName(fullName);

    final newUser = UserModel(
      uid: user.uid,
      fullName: fullName,
      email: email.trim(),
      phoneNumber: phoneNumber.trim(),
      role: 'TOURIST',
      loyaltyPoints: 0,
      totalEarnedPoints: 0,
      favoriteDestinationIds: const [],
      isActive: true,
      createdAt: DateTime.now(),
    );

    await _userDoc(user.uid).set(newUser.toFirestore(), SetOptions(merge: true));
    return newUser;
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    final UserCredential userCred;

    if (kIsWeb) {
      // Trên Web: Dùng trực tiếp signInWithPopup của Firebase Auth để tương thích hoàn toàn
      // với luồng OAuth và tránh lỗi `origin_mismatch` do random port của localhost.
      try {
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        userCred = await _auth.signInWithPopup(googleProvider);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'popup-closed-by-user') {
          throw const AuthException('Bạn đã đóng cửa sổ đăng nhập Google.');
        }
        throw AuthException('Đăng nhập Google thất bại: ${e.message ?? e.code}');
      }
    } else {
      // Trên Mobile (Android / iOS): Dùng GoogleSignIn native
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw const AuthException('Bạn đã hủy đăng nhập bằng Google.');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      userCred = await _auth.signInWithCredential(credential);
    }

    final User? firebaseUser = userCred.user;
    if (firebaseUser == null) {
      throw const AuthException('Đăng nhập Google vào Firebase thất bại.');
    }

    // Đồng bộ hồ sơ trên Firestore ngay lập tức (tránh độ trễ cold-start của trigger)
    final userDocRef = _userDoc(firebaseUser.uid);
    final docSnap = await userDocRef.get();

    if (docSnap.exists) {
      final userModel = UserModel.fromFirestore(docSnap);
      if (!userModel.isActive) {
        await _auth.signOut();
        if (!kIsWeb) {
          try {
            await _googleSignIn.signOut();
          } catch (_) {}
        }
        throw const AuthException('Tài khoản của bạn đã bị khóa bởi Quản trị viên.');
      }
      return userModel;
    }

    // Lần đầu đăng nhập qua Google: Khởi tạo hồ sơ người dùng mới
    final newUser = UserModel(
      uid: firebaseUser.uid,
      fullName: firebaseUser.displayName ?? 'Du khách SmartTravel',
      email: firebaseUser.email ?? '',
      phoneNumber: firebaseUser.phoneNumber ?? '',
      avatarUrl: firebaseUser.photoURL,
      role: 'TOURIST',
      loyaltyPoints: 0,
      totalEarnedPoints: 0,
      favoriteDestinationIds: const [],
      isActive: true,
      createdAt: DateTime.now(),
    );

    await userDocRef.set(newUser.toFirestore(), SetOptions(merge: true));
    return newUser;
  }

  @override
  Future<void> resetPassword({required String email}) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw const AuthException('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.');
    }

    final hasPasswordProvider = user.providerData.any((p) => p.providerId == 'password');
    if (!hasPasswordProvider) {
      throw const AuthException(
        'Tài khoản này được đăng nhập thông qua Google, không thể sử dụng tính năng đổi mật khẩu thông thường.',
      );
    }

    // Xác thực lại mật khẩu hiện tại trước khi đổi mật khẩu mới
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );

    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }

  @override
  Future<UserModel> getCurrentUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const AuthException('Chưa có phiên đăng nhập hợp lệ.');
    }

    final docSnap = await _userDoc(user.uid).get();
    if (!docSnap.exists || docSnap.data() == null) {
      final fallback = UserModel(
        uid: user.uid,
        fullName: user.displayName ?? 'Du khách SmartTravel',
        email: user.email ?? '',
        phoneNumber: user.phoneNumber ?? '',
        avatarUrl: user.photoURL,
        role: 'TOURIST',
        loyaltyPoints: 0,
        totalEarnedPoints: 0,
        favoriteDestinationIds: const [],
        isActive: true,
        createdAt: DateTime.now(),
      );
      await _userDoc(user.uid).set(fallback.toFirestore(), SetOptions(merge: true));
      return fallback;
    }

    final model = UserModel.fromFirestore(docSnap);
    if (!model.isActive) {
      await _auth.signOut();
      if (!kIsWeb) {
        try {
          await _googleSignIn.signOut();
        } catch (_) {}
      }
      throw const AuthException('Tài khoản của bạn đã bị khóa bởi Quản trị viên.');
    }
    return model;
  }

  @override
  Future<UserModel> updateProfile({
    required String fullName,
    required String phoneNumber,
    String? newAvatarFilePath,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const AuthException('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.');
    }

    String? avatarUrl;

    // 1. Tải ảnh đại diện lên Firebase Storage nếu có ảnh mới
    if (newAvatarFilePath != null && newAvatarFilePath.isNotEmpty) {
      final file = File(newAvatarFilePath);
      if (await file.exists()) {
        final storageRef = _storage.ref().child('users/${user.uid}/avatar/profile.jpg');
        final metadata = SettableMetadata(contentType: 'image/jpeg');
        final uploadTask = await storageRef.putFile(file, metadata);
        avatarUrl = await uploadTask.ref.getDownloadURL();
        await user.updatePhotoURL(avatarUrl);
      }
    }

    // 2. Cập nhật Firebase Auth displayName
    await user.updateDisplayName(fullName);

    // 3. Cập nhật Firestore document
    final updateData = <String, dynamic>{
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'phone': phoneNumber,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (avatarUrl != null) {
      updateData['avatarUrl'] = avatarUrl;
    }

    await _userDoc(user.uid).update(updateData);

    // 4. Trả về hồ sơ mới nhất
    return await getCurrentUserProfile();
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
  }
}
