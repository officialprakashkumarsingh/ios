import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'ios_page_transitions.dart';

import 'auth_and_profile_pages.dart';
import 'auth_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize the AuthService singleton so it's available everywhere
  AuthService(); 
  
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Color(0xFFFAFAFA),
    statusBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const AhamAIApp());
}

class AhamAIApp extends StatelessWidget {
  const AhamAIApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AhamAI',
      debugShowCheckedModeBanner: false,
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        physics: const BouncingScrollPhysics(),
      ),
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF383A42),
          secondary: Color(0xFF4078F2),
          background: Color(0xFFFAFAFA),
        ),
        scaffoldBackgroundColor: const Color(0xFFFAFAFA),
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: IOSPageTransitionsBuilder(),
            TargetPlatform.iOS: IOSPageTransitionsBuilder(),
            TargetPlatform.linux: IOSPageTransitionsBuilder(),
            TargetPlatform.macOS: IOSPageTransitionsBuilder(),
            TargetPlatform.windows: IOSPageTransitionsBuilder(),
          },
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFAFAFA),
          foregroundColor: Color(0xFF383A42),
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        fontFamily: 'Inter',
      ),
      // Single light theme based on Atom One Light colors
      // AuthGate will decide which page to show
      home: const AuthGate(),
    );
  }
}