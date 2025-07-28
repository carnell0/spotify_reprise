import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:spotify_reprise/core/routes/routes.dart';
import 'package:spotify_reprise/features/auth/bloc/theme_bloc.dart';
import 'package:spotify_reprise/features/auth/bloc/theme_state.dart';

class SignInPage extends StatefulWidget { // Renommage de la classe
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState(); // Renommage de l'état
}

class _SignInPageState extends State<SignInPage> { // Renommage de l'état
  bool _isPasswordVisible = false;

  // Contrôleurs pour les champs de texte
  final TextEditingController _usernameEmailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Clé globale pour le formulaire
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Message d'erreur/validation à afficher
  String? _validationMessage;

  @override
  void dispose() {
    // N'oubliez pas de disposer les contrôleurs pour libérer les ressources
    _usernameEmailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Regex pour la validation d'email (peut être utilisé si l'entrée est supposée être un email)
  final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
  );

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        final bool isDarkMode = state.themeData.brightness == Brightness.dark;
        final Color dynamicBackgroundColor = state.themeData.scaffoldBackgroundColor;
        final Color dynamicForegroundColor = isDarkMode ? Colors.white : Colors.black;
        final Color accentColor = Theme.of(context).primaryColor;

        return Scaffold(
          resizeToAvoidBottomInset: true,
          body: Stack(
            children: [
              Container(
                color: dynamicBackgroundColor,
                width: double.infinity,
                height: double.infinity,
              ),
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () {
                              context.go(AppRoutes.welcome);
                            },
                            child: Icon(Icons.arrow_back_ios, color: dynamicForegroundColor),
                          ),
                          SvgPicture.asset(
                            'assets/icons/spotify_logo1.svg',
                            height: 40,
                            width: 120,
                            
                          ),
                          const SizedBox(width: 24),
                        ],
                      ),
                      const SizedBox(height: 50),
                      Text(
                        'Sign In',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: dynamicForegroundColor,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'If You Need Any Support ',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: dynamicForegroundColor.withOpacity(0.7),
                                ),
                          ),
                          GestureDetector(
                            onTap: () {
                              print('Click Here for support tapped!');
                            },
                            child: Text(
                              'Click Here',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: accentColor,
                                    decoration: TextDecoration.underline,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // Formulaire pour la validation
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField( // Champ pour le nom d'utilisateur ou l'email
                              controller: _usernameEmailController,
                              decoration: InputDecoration(
                                labelText: 'Enter Username Or Email',
                                labelStyle: TextStyle(color: dynamicForegroundColor.withOpacity(0.7)),
                                hintStyle: TextStyle(color: dynamicForegroundColor.withOpacity(0.5)),
                                filled: true,
                                fillColor: dynamicForegroundColor.withOpacity(0.1),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                  borderSide: BorderSide(color: dynamicForegroundColor.withOpacity(0.3)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                  borderSide: BorderSide(color: accentColor, width: 2.0),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                  borderSide: BorderSide(color: Colors.red, width: 2.0),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                  borderSide: BorderSide(color: Colors.red, width: 2.0),
                                ),
                                contentPadding: const EdgeInsets.symmetric(vertical: 25.0, horizontal: 15.0),
                              ),
                              style: TextStyle(color: dynamicForegroundColor),
                              keyboardType: TextInputType.emailAddress, // ou TextInputType.text
                              cursorColor: accentColor,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your username or email';
                                }
                                // Si vous voulez valider spécifiquement l'email si c'est un email
                                // if (!value.contains('@') || !_emailRegex.hasMatch(value)) {
                                //   return 'Please enter a valid username or email';
                                // }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            TextFormField( // Champ pour le mot de passe
                              controller: _passwordController,
                              obscureText: !_isPasswordVisible,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                labelStyle: TextStyle(color: dynamicForegroundColor.withOpacity(0.7)),
                                hintStyle: TextStyle(color: dynamicForegroundColor.withOpacity(0.5)),
                                filled: true,
                                fillColor: dynamicForegroundColor.withOpacity(0.1),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                  borderSide: BorderSide(color: dynamicForegroundColor.withOpacity(0.3)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                  borderSide: BorderSide(color: accentColor, width: 2.0),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                  borderSide: BorderSide(color: Colors.red, width: 2.0),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                  borderSide: BorderSide(color: Colors.red, width: 2.0),
                                ),
                                contentPadding: const EdgeInsets.symmetric(vertical: 25.0, horizontal: 15.0),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                    color: dynamicForegroundColor.withOpacity(0.6),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                ),
                              ),
                              style: TextStyle(color: dynamicForegroundColor),
                              cursorColor: accentColor,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10), // Espace avant "Recovery Password"
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {
                            print('Recovery Password tapped!');
                            // TODO: Implémenter la navigation vers la page de récupération de mot de passe
                          },
                          child: Text(
                            'Recovery Password',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: accentColor,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Message de validation (affiché si _validationMessage n'est pas null)
                      if (_validationMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Text(
                            _validationMessage!,
                            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),

                      // Bouton principal "Sign In"
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                _validationMessage = null;
                              });
                              print('Form is valid! Signing In...');
                              // Ici, vous pouvez appeler votre logique de connexion
                            } else {
                              setState(() {
                                _validationMessage = 'Please fill in all fields correctly.';
                              });
                              print('Form is invalid.');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 18.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(9.0),
                            child: Text(
                              'Sign In',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Ligne "Or"
                      Row(
                        children: [
                          Expanded(child: Divider(color: dynamicForegroundColor.withOpacity(0.3))),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Text(
                              'Or',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: dynamicForegroundColor.withOpacity(0.7),
                                  ),
                            ),
                          ),
                          Expanded(child: Divider(color: dynamicForegroundColor.withOpacity(0.3))),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // Icônes de connexion tierces (Google, Apple)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              //border: Border.all(color: dynamicForegroundColor.withOpacity(0.3), width: 1),
                            ),
                            child: Center(
                              child: Image.asset(
                                'assets/images/google.png',
                                height: 35,
                                width: 35,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              //border: Border.all(color: dynamicForegroundColor.withOpacity(0.3), width: 1),
                            ),
                            child: Center(
                              child: Image.asset(
                                'assets/images/apple.png',
                                height: 35,
                                width: 35,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0 ? 20 : 0),
                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Not A Member? ',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: dynamicForegroundColor.withOpacity(0.7),
                                ),
                          ),
                          GestureDetector(
                            onTap: () {
                              context.go(AppRoutes.register);
                            },
                            child: Text(
                              'Register Now',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: accentColor,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}