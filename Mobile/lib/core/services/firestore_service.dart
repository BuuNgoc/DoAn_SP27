import 'package:cloud_firestore/cloud_firestore.dart';

/// Cloud Firestore Service wrapper with offline cache enabled (LI-04, LI-05)
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirebaseFirestore get instance => _firestore;

  CollectionReference collection(String path) => _firestore.collection(path);
  DocumentReference document(String path) => _firestore.doc(path);
}
