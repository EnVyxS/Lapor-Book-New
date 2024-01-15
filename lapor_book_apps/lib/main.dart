import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lapor_book_apps/firebase_options.dart';
import 'package:lapor_book_apps/pages/AddFormPage.dart';
import 'package:lapor_book_apps/pages/DetailPage.dart';
import 'package:lapor_book_apps/pages/SplashPage.dart';
import 'package:lapor_book_apps/pages/LoginPage.dart';
import 'package:lapor_book_apps/pages/RegisterPage.dart';
import 'package:lapor_book_apps/pages/dashboard/DashboardPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MaterialApp(
    title: "Aplikasi Lapor Book",
    initialRoute: '/',
    routes: {
      '/': (context) => const SplashPage(),
      '/login': (context) => const LoginPage(),
      '/register': (context) => const RegisterPage(),
      '/dashboard': (context) => const DashboardPage(),
      '/add': (context) => const AddFormPage(),
      '/detail': (context) => const DetailPage(),
    },
  ));
}
