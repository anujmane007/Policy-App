import 'package:flutter/material.dart';
import 'package:privacy_app/constants.dart';
import 'package:privacy_app/screens/home.dart';
import 'package:privacy_app/screens/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Map<String, dynamic>> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    String? userEmail = prefs.getString('userEmail');
    return {'isLoggedIn': isLoggedIn, 'userEmail': userEmail};
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _checkLoginStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(); // or a splash screen
        } else {
          bool isLoggedIn = snapshot.data?['isLoggedIn'] ?? false;
          String? userEmail = snapshot.data?['userEmail'] ?? '';

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Policy App',
            theme: ThemeData(
              primaryColor: kPrimaryColor,
              scaffoldBackgroundColor: const Color.fromARGB(255, 255, 255, 255),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  foregroundColor: Colors.white,
                  backgroundColor: kPrimaryColor,
                  shape: const StadiumBorder(),
                  maximumSize: const Size(double.infinity, 56),
                  minimumSize: const Size(double.infinity, 56),
                ),
              ),
              inputDecorationTheme: const InputDecorationTheme(
                filled: true,
                fillColor: kPrimaryLightColor,
                iconColor: kPrimaryColor,
                prefixIconColor: kPrimaryColor,
                contentPadding: EdgeInsets.symmetric(
                    horizontal: defaultPadding, vertical: defaultPadding),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            home: isLoggedIn
                ? HomeScreen(userEmail: userEmail ?? '')
                : const LoginPage(),
          );
        }
      },
    );
  }
}
