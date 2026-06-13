import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/router_provider.dart';
import 'screens/login_screen.dart';
import 'utils/theme.dart';

// Global flag to check if Firebase is successfully configured
bool isFirebaseInitialized = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Attempt standard Firebase setup
    await Firebase.initializeApp();
    isFirebaseInitialized = true;
    debugPrint('Firebase initialized successfully.');
  } catch (e) {
    isFirebaseInitialized = false;
    debugPrint('Firebase initialization warning: $e. ACROMA will run in Demo/Simulated Mode.');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RouterProvider()),
      ],
      child: const AcromaApp(),
    ),
  );
}

class AcromaApp extends StatelessWidget {
  const AcromaApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ACROMA Router Monitor',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
    );
  }
}
