import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_reprise/features/auth/bloc/theme_bloc.dart';
import 'package:spotify_reprise/features/auth/bloc/theme_state.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        final bool isDarkMode = state.themeData.brightness == Brightness.dark;
        final Color dynamicForegroundColor = isDarkMode ? Colors.white : Colors.black;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              'Search',
              style: TextStyle(
                color: dynamicForegroundColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'What do you want to listen to?',
                    hintStyle: TextStyle(color: dynamicForegroundColor.withOpacity(0.6)),
                    prefixIcon: Icon(Icons.search, color: dynamicForegroundColor.withOpacity(0.8)),
                    filled: true,
                    fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: TextStyle(color: dynamicForegroundColor),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Center(
                    child: Text(
                      'Explore millions of songs, podcasts, and artists!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: dynamicForegroundColor.withOpacity(0.7),
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}