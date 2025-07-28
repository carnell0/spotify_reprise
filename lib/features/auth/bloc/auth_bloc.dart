import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spotify_reprise/features/auth/bloc/auth_event.dart';
import 'package:spotify_reprise/features/auth/bloc/auth_state.dart';
import 'package:spotify_reprise/features/auth/services/auth_repository.dart';
import 'package:spotify_reprise/core/errors/exceptions.dart'; // Pour capturer vos exceptions

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  User? _currentUser; // Pour garder une trace de l'utilisateur actuel

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthInitial()) { // État initial
    // Mappage des événements aux états
    on<AuthSignUpRequested>(_onSignUpRequested);
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<AuthCheckUserStatus>(_onCheckUserStatus);

    // Écoutez les changements d'état d'authentification de Firebase
    // Cela nous permet de mettre à jour l'état du Bloc si l'utilisateur
    // se connecte/déconnecte en dehors d'une action directe du Bloc.
    _authRepository.authStateChanges.listen((user) {
      _currentUser = user; // Met à jour l'utilisateur interne
      if (user != null) {
        // Si un utilisateur est connecté, émettez l'état authentifié
        add(AuthCheckUserStatus()); // Ou directement emit(AuthAuthenticated(user: user));
      } else {
        // Si aucun utilisateur n'est connecté, émettez l'état non authentifié
        add(AuthCheckUserStatus()); // Ou directement emit(AuthUnauthenticated());
      }
    });
  }

  // Gestionnaire pour l'événement d'inscription
  Future<void> _onSignUpRequested(
      AuthSignUpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final User? user = await _authRepository.signUpWithEmailAndPassword(
        event.email,
        event.password,
      );
      if (user != null) {
        // Envisagez de sauvegarder d'autres infos (fullName) dans Firestore ici
        emit(AuthAuthenticated(user: user));
      } else {
        emit(const AuthError(message: 'Sign up failed. User is null.'));
      }
    } on ServerException catch (e) {
      emit(AuthError(message: e.message));
    } catch (e) {
      emit(AuthError(message: 'An unexpected error occurred: ${e.toString()}'));
    }
  }

  // Gestionnaire pour l'événement de connexion
  Future<void> _onSignInRequested(
      AuthSignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final User? user = await _authRepository.signInWithEmailAndPassword(
        event.email,
        event.password,
      );
      if (user != null) {
        emit(AuthAuthenticated(user: user));
      } else {
        emit(const AuthError(message: 'Sign in failed. User is null.'));
      }
    } on ServerException catch (e) {
      emit(AuthError(message: e.message));
    } catch (e) {
      emit(AuthError(message: 'An unexpected error occurred: ${e.toString()}'));
    }
  }

  // Gestionnaire pour l'événement de déconnexion
  Future<void> _onSignOutRequested(
      AuthSignOutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authRepository.signOut();
      emit(AuthUnauthenticated());
    } on ServerException catch (e) {
      emit(AuthError(message: e.message));
    } catch (e) {
      emit(AuthError(message: 'An unexpected error occurred during sign out: ${e.toString()}'));
    }
  }

  // Gestionnaire pour vérifier le statut de l'utilisateur
  // Utile au démarrage de l'app ou après des changements d'état externes
  void _onCheckUserStatus(
      AuthCheckUserStatus event, Emitter<AuthState> emit) {
    final user = _authRepository.getCurrentUser();
    if (user != null) {
      emit(AuthAuthenticated(user: user));
    } else {
      emit(AuthUnauthenticated());
    }
  }
}
