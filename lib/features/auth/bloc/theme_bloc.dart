import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spotify_reprise/features/auth/bloc/theme_event.dart';
import 'package:spotify_reprise/features/auth/bloc/theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc()
      : super(ThemeState(themeData: _lightTheme)) {
    on<ThemeChanged>((event, emit) {
      emit(ThemeState(themeData: event.brightness == Brightness.dark
          ? _darkTheme
          : _lightTheme));
    });
  }

  static final ThemeData _darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.green,
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      elevation: 0,
      centerTitle: true,
    ),
    textTheme: GoogleFonts.montserratTextTheme(
      ThemeData.dark().textTheme, // Applique le style par défaut du thème sombre
    ),
    // ===========================================
    colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.green, brightness: Brightness.dark,).copyWith(background: Colors.black),
  );

  static final ThemeData _lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.green,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.black),
      titleTextStyle: TextStyle(color: Colors.black, fontSize: 20),
    ),
    // === AJOUTE CECI pour la police Montserrat ===
    textTheme: GoogleFonts.montserratTextTheme(
      ThemeData.light().textTheme, // Applique le style par défaut du thème clair
    ),
    // ===========================================
    colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.green).copyWith(background: Colors.white),
  );
}