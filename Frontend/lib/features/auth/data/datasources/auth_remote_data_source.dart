import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/constants/firestore_collections.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

/// [FE-01] Nguồn dữ liệu xác thực.
abstract class AuthRemoteDataSource {
  Future<UserModel?> getCurrentUser();
  Future<UserModel> login(String email, String password);
  Future<UserModel> register({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    required String nationality,
  });
  Future<void> sendPasswordReset(String email);
  Future<void> changePassword(String currentPassword, String newPassword);
  Future<UserModel> updateProfile(UserModel user);
  Future<void> logout();
}

/// Dữ liệu mẫu chạy offline – có sẵn tài khoản demo.
class MockAuthRemoteDataSource implements AuthRemoteDataSource {
  static const demoEmail = 'dukhach@smarttravel.vn';
  static const demoPassword = '123456';

  final Map<String, ({UserModel user, String password})> _accounts = {
    demoEmail: (
      user: UserModel(
        uid: 'demo-tourist-001',
        fullName: 'Nguyễn Minh Anh',
        email: demoEmail,
        phone: '0905123456',
        nationality: 'Việt Nam',
        memberSince: DateTime(2026, 3, 12),
      ),
      password: demoPassword,
    ),
  };

  UserModel? _current;

  @override
  Future<UserModel?> getCurrentUser() async => _current;

  @override
  Future<UserModel> login(String email, String password) async {
    await simulateLatency();
    final account = _accounts[email.toLowerCase()];
    if (account == null || account.password != password) {
      throw const AuthException('Email hoặc mật khẩu không đúng. Vui lòng kiểm tra lại.');
    }
    return _current = account.user;
  }

  @override
  Future<UserModel> register({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    required String nationality,
  }) async {
    await simulateLatency();
    final key = email.toLowerCase();
    if (_accounts.containsKey(key)) {
      throw const AuthException('Email này đã được đăng ký. Vui lòng đăng nhập.');
    }
    final user = UserModel(
      uid: 'user-${DateTime.now().millisecondsSinceEpoch}',
      fullName: fullName,
      email: key,
      phone: phone,
      nationality: nationality,
      memberSince: DateTime.now(),
    );
    _accounts[key] = (user: user, password: password);
    return _current = user;
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    await simulateLatency();
    // Vì lý do bảo mật, luôn trả về thành công dù email có tồn tại hay không.
  }

  @override
  Future<void> changePassword(String currentPassword, String newPassword) async {
    await simulateLatency();
    final user = _current;
    if (user == null) throw const AuthException('Phiên đăng nhập đã hết hạn.');
    final account = _accounts[user.email]!;
    if (account.password != currentPassword) {
      throw const AuthException('Mật khẩu hiện tại không đúng.');
    }
    _accounts[user.email] = (user: account.user, password: newPassword);
  }

  @override
  Future<UserModel> updateProfile(UserModel user) async {
    await simulateLatency();
    final account = _accounts[user.email];
    if (account != null) _accounts[user.email] = (user: user, password: account.password);
    return _current = user;
  }

  @override
  Future<void> logout() async => _current = null;
}

/// Triển khai thật với Firebase Auth + Firestore `users/{uid}`.
/// Hồ sơ ban đầu (role = TOURIST, loyaltyPoints = 0) do Cloud Function
/// `onUserCreated` tạo – client không tự ghi các trường này.
class FirebaseAuthRemoteDataSource implements AuthRemoteDataSource {
  FirebaseAuthRemoteDataSource({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _firestore.collection(FirestoreCollections.users).doc(uid);

  Future<UserModel> _loadProfile(User user) async {
    final snap = await _userDoc(user.uid).get();
    if (snap.exists) return UserModel.fromFirestore(snap);
    return UserModel(uid: user.uid, fullName: user.displayName ?? 'Du khách', email: user.email ?? '');
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    return user == null ? null : _loadProfile(user);
  }

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return await _loadProfile(cred.user!);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapError(e.code));
    }
  }

  @override
  Future<UserModel> register({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    required String nationality,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      await cred.user!.updateDisplayName(fullName);
      final model = UserModel(
        uid: cred.user!.uid,
        fullName: fullName,
        email: email,
        phone: phone,
        nationality: nationality,
        memberSince: DateTime.now(),
      );
      await _userDoc(model.uid).set(model.toFirestoreProfileUpdate(), SetOptions(merge: true));
      return model;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapError(e.code));
    }
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapError(e.code));
    }
  }

  @override
  Future<void> changePassword(String currentPassword, String newPassword) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) throw const AuthException('Phiên đăng nhập đã hết hạn.');
    try {
      final credential = EmailAuthProvider.credential(email: user.email!, password: currentPassword);
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapError(e.code));
    }
  }

  @override
  Future<UserModel> updateProfile(UserModel user) async {
    await _userDoc(user.uid).set(user.toFirestoreProfileUpdate(), SetOptions(merge: true));
    await _auth.currentUser?.updateDisplayName(user.fullName);
    return user;
  }

  @override
  Future<void> logout() => _auth.signOut();

  String _mapError(String code) => switch (code) {
        'invalid-credential' || 'wrong-password' || 'user-not-found' =>
          'Email hoặc mật khẩu không đúng. Vui lòng kiểm tra lại.',
        'email-already-in-use' => 'Email này đã được đăng ký. Vui lòng đăng nhập.',
        'weak-password' => 'Mật khẩu quá yếu, vui lòng chọn mật khẩu khác.',
        'invalid-email' => 'Email chưa đúng định dạng.',
        'too-many-requests' => 'Bạn thao tác quá nhiều lần. Vui lòng thử lại sau ít phút.',
        'network-request-failed' => 'Không có kết nối mạng. Vui lòng kiểm tra lại đường truyền.',
        _ => 'Không thể xác thực tài khoản lúc này. Vui lòng thử lại.',
      };
}
