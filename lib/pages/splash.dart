import 'package:flutter/material.dart';
import 'package:PIL/pages/getstarted.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _navigateToGetStarted();
  }

  Future<void> _navigateToGetStarted() async {
    // Wait for 2 seconds
    await Future.delayed(const Duration(seconds: 2));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => const GetStartedPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'lib/assets/images/pillogo2.png',
          height: 250,
          width: 250,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
