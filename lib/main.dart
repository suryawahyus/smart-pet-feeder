import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pet_feeder/content/widget/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyATCLUA8E-gPWcy08RG9HQcZp0eifxbtO8",
      appId: "1:939758413286:android:d3d4ae93a0d075cf5c2227",
      messagingSenderId: "939758413286",
      projectId: "tesiot-ef201",
      databaseURL:
          "https://tesiot-ef201-default-rtdb.asia-southeast1.firebasedatabase.app",
      storageBucket: "tesiot-ef201.appspot.com",
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 17, 191, 229),
        ),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}
