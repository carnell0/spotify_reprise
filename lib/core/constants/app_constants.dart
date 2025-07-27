/// Application constants
class AppConstants {
  /// App name
  static const String appName = 'Spotify Reprise';
  
  /// API base URL
  static const String apiBaseUrl = 'https://api.spotify.com/v1';
  
  /// Assets paths
  static const String imagePath = 'assets/images/';
  static const String iconPath = 'assets/icons/';
  
  /// Shared preferences keys
  static const String tokenKey = 'token';
  static const String userKey = 'user';
  
  /// Error messages
  static const String networkErrorMessage = 'Vérifiez votre connexion internet';
  static const String serverErrorMessage = 'Une erreur serveur est survenue';
  static const String unknownErrorMessage = 'Une erreur inconnue est survenue';
  
  /// Animation durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 500);
  static const Duration longAnimationDuration = Duration(milliseconds: 800);
}