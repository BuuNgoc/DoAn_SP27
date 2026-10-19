import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

/// Firebase Storage Service for images and media uploads (LI-10)
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadFile(String path, File file) async {
    final ref = _storage.ref().child(path);
    final uploadTask = await ref.putFile(file);
    return await uploadTask.ref.getDownloadURL();
  }
}
