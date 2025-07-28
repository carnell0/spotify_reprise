import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:spotify_reprise/core/routes/routes.dart';
import 'package:spotify_reprise/features/auth/bloc/theme_bloc.dart';
import 'package:spotify_reprise/features/auth/bloc/theme_state.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _isPasswordVisible = false;

  // Contrôleurs pour les champs de texte
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Clé globale pour le formulaire
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Message d'erreur/validation à afficher
  String? _validationMessage;

  @override
  void dispose() {
    // N'oubliez pas de disposer les contrôleurs pour libérer les ressources
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Regex pour la validation d'email
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
                        'Register',
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
                        key: _formKey, // Associe la clé globale au formulaire
                        child: Column(
                          children: [
                            TextFormField( // Changé de TextField à TextFormField
                              controller: _fullNameController,
                              decoration: InputDecoration(
                                labelText: 'Full Name',
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
                                errorBorder: OutlineInputBorder( // Style pour l'erreur
                                  borderRadius: BorderRadius.circular(25.0),
                                  borderSide: BorderSide(color: Colors.red, width: 2.0),
                                ),
                                focusedErrorBorder: OutlineInputBorder( // Style pour l'erreur au focus
                                  borderRadius: BorderRadius.circular(25.0),
                                  borderSide: BorderSide(color: Colors.red, width: 2.0),
                                ),
                                contentPadding: const EdgeInsets.symmetric(vertical: 25.0, horizontal: 15.0),
                              ),
                              style: TextStyle(color: dynamicForegroundColor),
                              keyboardType: TextInputType.name,
                              cursorColor: accentColor,
                              validator: (value) { // Validateur pour le nom complet
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your full name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            TextFormField( // Changé de TextField à TextFormField
                              controller: _emailController,
                              decoration: InputDecoration(
                                labelText: 'Enter Email',
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
                              keyboardType: TextInputType.emailAddress,
                              cursorColor: accentColor,
                              validator: (value) { // Validateur pour l'email (avec regex)
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!_emailRegex.hasMatch(value)) {
                                  return 'Please enter a valid email address';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            TextFormField( // Changé de TextField à TextFormField
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
                              validator: (value) { // Validateur pour le mot de passe
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                if (value.length < 6) { // Exemple: mot de passe d'au moins 6 caractères
                                  return 'Password must be at least 6 characters long';
                                }
                                return null;
                              },
                            ),
                          ],
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

                      // Bouton principal "Create Account"
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // Valider le formulaire
                            if (_formKey.currentState!.validate()) {
                              // Si le formulaire est valide, effacer le message d'erreur
                              setState(() {
                                _validationMessage = null;
                              });
                              print('Form is valid! Creating account...');
                              // Ici, vous pouvez appeler votre logique d'inscription
                            } else {
                              // Si le formulaire n'est pas valide, afficher un message général
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
                              'Create Account',
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
                                'assets/images/google.png', // Assurez-vous d'avoir ces images
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
                                'assets/images/apple.png', // Assurez-vous d'avoir ces images
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
                            'Do You Have An Account? ',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: dynamicForegroundColor.withOpacity(0.7),
                                ),
                          ),
                          GestureDetector(
                            onTap: () {
                              context.go(AppRoutes.signIn);
                            },
                            child: Text(
                              'Sign In',
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