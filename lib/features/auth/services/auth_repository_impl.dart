// lib/features/auth/services/auth_repository_impl.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spotify_reprise/features/auth/services/auth_repository.dart';
import 'package:spotify_reprise/core/errors/exceptions.dart'; // Assure-toi que ce fichier existe

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;

  AuthRepositoryImpl(this._firebaseAuth);

  @override
  Future<User?> signUpWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      // Gérer les erreurs spécifiques à Firebase Auth
      String errorMessage;
      if (e.code == 'weak-password') {
        errorMessage = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'The account already exists for that email.';
      } else {
        errorMessage = e.message ?? 'An unknown error occurred during sign up.';
      }
      // Vous pouvez utiliser votre classe AppException si vous en avez une, sinon lancez juste une exception.
      throw ServerException(message: errorMessage);
    } catch (e) {
      // Gérer d'autres types d'erreurs inattendues
      throw ServerException(message: 'An unexpected error occurred: ${e.toString()}');
    }
  }

  @override
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      // Gérer les erreurs spécifiques à Firebase Auth
      String errorMessage;
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Wrong password provided for that user.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'The email address is not valid.';
      } else {
        errorMessage = e.message ?? 'An unknown error occurred during sign in.';
      }
      throw ServerException(message: errorMessage);
    } catch (e) {
      // Gérer d'autres types d'erreurs inattendues
      throw ServerException(message: 'An unexpected error occurred: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to sign out.');
    } catch (e) {
      throw ServerException(message: 'An unexpected error occurred during sign out: ${e.toString()}');
    }
  }

  @override
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
}