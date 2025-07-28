import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_reprise/features/auth/bloc/theme_bloc.dart';
import 'package:spotify_reprise/features/auth/bloc/theme_state.dart';
import 'package:spotify_reprise/features/auth/bloc/auth_bloc.dart';
import 'package:spotify_reprise/features/auth/bloc/auth_event.dart'; // Pour l'événement de déconnexion
import 'package:go_router/go_router.dart';
import 'package:spotify_reprise/core/routes/routes.dart'; // Pour la redirection après déconnexion

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        final bool isDarkMode = state.themeData.brightness == Brightness.dark;
        final Color dynamicForegroundColor = isDarkMode ? Colors.white : Colors.black;
        final Color accentColor = Theme.of(context).primaryColor;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              'Your Profile',
              style: TextStyle(
                color: dynamicForegroundColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.edit, color: dynamicForegroundColor),
                onPressed: () {
                  // TODO: Gérer l'édition du profil
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: accentColor.withOpacity(0.2),
                    child: Icon(
                      Icons.person_outline,
                      size: 70,
                      color: accentColor,
                    ),
                    // Vous pouvez ajouter une Image.network ici si l'utilisateur a un avatar
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'User Name', // Remplacer par le nom de l'utilisateur réel
                    style: TextStyle(
                      color: dynamicForegroundColor,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'user.email@example.com', // Remplacer par l'email de l'utilisateur réel
                    style: TextStyle(
                      color: dynamicForegroundColor.withOpacity(0.7),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildProfileOption(
                    context,
                    icon: Icons.settings,
                    title: 'Account Settings',
                    onTap: () {
                      // TODO: Naviguer vers les paramètres du compte
                    },
                    isDarkMode: isDarkMode,
                    foregroundColor: dynamicForegroundColor,
                  ),
                  _buildProfileOption(
                    context,
                    icon: Icons.playlist_play,
                    title: 'Your Playlists',
                    onTap: () {
                      // TODO: Naviguer vers les playlists de l'utilisateur
                    },
                    isDarkMode: isDarkMode,
                    foregroundColor: dynamicForegroundColor,
                  ),
                  _buildProfileOption(
                    context,
                    icon: Icons.star_border,
                    title: 'Premium Plan',
                    onTap: () {
                      // TODO: Naviguer vers les options Premium
                    },
                    isDarkMode: isDarkMode,
                    foregroundColor: dynamicForegroundColor,
                  ),
                  _buildProfileOption(
                    context,
                    icon: Icons.logout,
                    title: 'Sign Out',
                    onTap: () {
                      // Dispatch l'événement de déconnexion
                      context.read<AuthBloc>().add(const AuthSignOutRequested());
                      // Après déconnexion, le BlocListener dans app.dart devrait rediriger
                      // vers la page de connexion, mais on peut aussi forcer ici pour s'assurer
                      // context.go(AppRoutes.signIn); // Ceci peut être redondant si app.dart gère bien
                    },
                    isDarkMode: isDarkMode,
                    foregroundColor: dynamicForegroundColor,
                    isDestructive: true, // Pour un bouton de déconnexion
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool isDarkMode,
    required Color foregroundColor,
    bool isDestructive = false,
  }) {
    return Card(
      color: isDarkMode ? Colors.grey[900] : Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? Colors.redAccent : foregroundColor.withOpacity(0.8),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? Colors.redAccent : foregroundColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: foregroundColor.withOpacity(0.5)),
        onTap: onTap,
      ),
    );
  }
}