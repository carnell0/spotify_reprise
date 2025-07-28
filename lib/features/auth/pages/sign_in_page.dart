// lib/features/auth/pages/sign_in_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:spotify_reprise/core/routes/routes.dart';
import 'package:spotify_reprise/features/auth/bloc/auth_bloc.dart'; // Importe AuthBloc
import 'package:spotify_reprise/features/auth/bloc/auth_event.dart'; // Importe AuthEvent
import 'package:spotify_reprise/features/auth/bloc/auth_state.dart'; // Importe AuthState
import 'package:spotify_reprise/features/auth/bloc/theme_bloc.dart';
import 'package:spotify_reprise/features/auth/bloc/theme_state.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  bool _isPasswordVisible = false;

  final TextEditingController _usernameEmailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? _validationMessage; // Pour afficher les erreurs de validation du formulaire

  @override
  void dispose() {
    _usernameEmailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Accède au AuthBloc
    final authBloc = BlocProvider.of<AuthBloc>(context);

    return BlocListener<AuthBloc, AuthState>( // Ajoute un BlocListener
      listener: (context, state) {
        if (state is AuthLoading) {
          // Affiche un indicateur de chargement (par exemple, un SnackBar ou un Dialog)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Signing in...'), duration: Duration(seconds: 1)),
          );
        } else if (state is AuthAuthenticated) {
          // L'utilisateur est connecté, le BlocListener dans app.dart gérera la navigation.
          // Ici, vous pouvez simplement effacer les messages d'erreur et les champs si nécessaire.
          ScaffoldMessenger.of(context).hideCurrentSnackBar(); // Cache le message de chargement
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Successfully signed in!'), duration: Duration(seconds: 2)),
          );
          // La navigation vers AppRoutes.home est gérée dans app.dart
        } else if (state is AuthError) {
          // Affiche le message d'erreur de l'authentification
          ScaffoldMessenger.of(context).hideCurrentSnackBar(); // Cache le message de chargement
          setState(() {
            _validationMessage = state.message;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${state.message}')),
          );
        }
      },
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          final bool isDarkMode = themeState.themeData.brightness == Brightness.dark;
          final Color dynamicBackgroundColor = themeState.themeData.scaffoldBackgroundColor;
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
                              colorFilter: ColorFilter.mode(
                                dynamicForegroundColor,
                                BlendMode.srcIn,
                              ),
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

                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
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
                                keyboardType: TextInputType.emailAddress,
                                cursorColor: accentColor,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your username or email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
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

                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {
                              print('Recovery Password tapped!');
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

                        // Affiche le message de validation/erreur du Bloc
                        if (_validationMessage != null && _validationMessage!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: Text(
                              _validationMessage!,
                              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              // Vérifie la validation du formulaire local
                              if (_formKey.currentState!.validate()) {
                                setState(() {
                                  _validationMessage = null; // Efface les messages d'erreur précédents
                                });
                                // Dispatche l'événement de connexion au AuthBloc
                                authBloc.add(
                                  AuthSignInRequested(
                                    email: _usernameEmailController.text.trim(),
                                    password: _passwordController.text.trim(),
                                  ),
                                );
                              } else {
                                // Affiche une erreur de validation locale si le formulaire n'est pas valide
                                setState(() {
                                  _validationMessage = 'Please fill in all fields correctly.';
                                });
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

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: dynamicForegroundColor.withOpacity(0.3), width: 1),
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
                                border: Border.all(color: dynamicForegroundColor.withOpacity(0.3), width: 1),
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
      ),
    );
  }
}