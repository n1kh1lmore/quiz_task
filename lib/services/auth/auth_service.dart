import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  // instance of auth
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

// instance of firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //create user

  Future<UserCredential> signUpWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

//after creating the user, create a new document for the user in the users collection
      _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
      });

      return userCredential;
    } on FirebaseException catch (e) {
      throw Exception(e.code);
    }
  }

  //sign in
  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

//add a new document for the user in users collection if it doesn't already exists
      _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
      }, SetOptions(merge: true));

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  // sign out

  Future<void> signOut() async {
    return await FirebaseAuth.instance.signOut();
  }

  //password reset
    Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('No user found for that email.');
      } else {
        throw Exception('Failed to send reset email: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to send reset email: $e');
    }
  }

    String? getCurrentUserId() {
    User? user = _firebaseAuth.currentUser;
    return user?.uid;
  }
}
