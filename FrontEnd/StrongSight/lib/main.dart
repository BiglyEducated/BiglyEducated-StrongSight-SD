import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'providers/theme_provider.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/register_page.dart';
import 'pages/calendar_page.dart';
import 'pages/splash_page.dart';
import 'pages/profile_page.dart';
import 'pages/workout_page.dart';
import 'pages/exercises_page.dart';
import 'pages/main_page.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:ui' as ui;


Future<void> verifyAssets() async {
  final assets = [
    'assets/images/logo.png',
    'assets/images/Deadlift.png',
    'assets/images/Squat.png',
  ];

  for (final path in assets) {
    try {
      final data = await rootBundle.load(path);
      await ui.instantiateImageCodec(data.buffer.asUint8List());
      print('✅ $path loaded fine');
    } catch (e) {
      print('❌ $path failed: $e');
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize Firebase before running the app
  await Firebase.initializeApp();


  await verifyAssets();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'StrongSight',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.currentTheme,

      // LIGHT THEME
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF094941),
          secondary: Color(0xFF748067),
        ),
        scaffoldBackgroundColor: const Color(0xFFFCF5E3),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF094941),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        cardColor: Colors.white,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF094941),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
            textStyle:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ),

      // DARK THEME
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF094941),
          secondary: Color(0xFF748067),
        ),
        scaffoldBackgroundColor: const Color(0xFF0B0F14),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Color(0xFF039E39),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          iconTheme: IconThemeData(color: Color(0xFF094941)),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF161C22),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
            borderSide: BorderSide.none,
          ),
          labelStyle: TextStyle(color: Color(0xFF748067)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF039E39),
            foregroundColor: const Color(0xFFFCF5E3),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
            textStyle:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF039E39),
          foregroundColor: Color(0xFFFCF5E3),
        ),
        cardColor: const Color(0xFF10161B),
      ),

      initialRoute: '/splash',
      routes: {
        '/': (context) => const LoginPage(),
        '/splash': (context) => const SplashScreen(),
        '/home': (context) => const MainPage(),
        '/register': (context) => const RegisterPage(),
        '/calendar': (context) => const CalendarPage(),
        '/profile': (context) => const ProfilePage(),
        '/workout': (context) => const WorkoutPage(),
        '/exercises': (context) => const ExercisesPage(),
      },
    );
  }
}
