import 'package:equatable/equatable.dart';

// Pour utiliser Equatable, ajoutez `equatable: ^latest_version` à votre pubspec.yaml
// flutter pub get

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  //final String? fullName; // Optionnel, si vous voulez l'utiliser

  const AuthSignUpRequested({required this.email, required this.password, });

  @override
  List<Object?> get props => [email, password, ];
}

class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthSignInRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

class AuthCheckUserStatus extends AuthEvent {
  const AuthCheckUserStatus();
}
