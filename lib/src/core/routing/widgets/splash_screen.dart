import 'package:flutter/material.dart';

/// Loading screen shown while the auth gate resolves its first
/// `authStateProvider` emission — avoids a sign-in/shell flicker on cold
/// start.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
