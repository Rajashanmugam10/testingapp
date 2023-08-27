import 'dart:typed_data';

import 'package:air/services/storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? get currentUser => _firebaseAuth.currentUser;
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> signinwithemailandpassword(
      {required String email, required String password}) async {
    await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  Future<void> createuserwithemailandpassword(
      {required String email,
      required String password,
      required String name,
      required String username,
      required Uint8List file,
      required String bio}) async {
    await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
    String imageurl = await Storage().uploadprofileimage('profileimage', file);

    await _firestore
        .collection('userdetails')
        .doc(_firebaseAuth.currentUser!.uid)
        .set({
      "email": email,
      "password": password,
      "name": name,
      "username": username,
      "bio": bio,
      "profileimage": imageurl
    });
  }

  Future<void> signout() async {
    await _firebaseAuth.signOut();
  }

  Future<void> uploatpost({
    required String uid,
    required String username,
    required String profile,
    required String info,
    required Uint8List file,
  }) async {
    String id = const Uuid().v1();

    String posturl = await Storage().uploadpostfile(id, file);
    await _firestore.collection('publicposts').doc(id).set({
      "username": username,
      "uid": uid,
      "info": info,
      "post": posturl,
      "profileimage": profile
    });
  }
}
