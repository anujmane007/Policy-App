import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:privacy_app/screens/home.dart';
import 'package:privacy_app/screens/login.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text("An error occurred. Please try again later."),
            );
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const LoginPage();
          } else {
            // Extract the user's email and pass it to HomeScreen
            final userEmail = snapshot.data!.email ?? 'Unknown';
            return HomeScreen(userEmail: userEmail);
          }
        },
      ),
    );
  }
}
