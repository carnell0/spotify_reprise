// lib/features/auth/services/auth_repository.dart
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  // Méthode pour s'inscrire avec email et mot de passe
  Future<User?> signUpWithEmailAndPassword(String email, String password);

  // Méthode pour se connecter avec email et mot de passe
  Future<User?> signInWithEmailAndPassword(String email, String password);

  // Méthode pour se déconnecter
  Future<void> signOut();

  // Obtenir l'utilisateur actuellement connecté
  User? getCurrentUser();

  // Écouter les changements d'état de l'authentification (connexion/déconnexion)
  Stream<User?> get authStateChanges;
}