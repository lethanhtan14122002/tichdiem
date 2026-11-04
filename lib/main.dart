import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:vic/firebase_options.dart';
import 'package:vic/screens/admin.dart';
import 'screens/loyalty_card_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const VicApp());
}

class VicApp extends StatelessWidget {
  const VicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'VIC - Khách hàng thân thiết',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFEAF4FF),
      ),
      home: const LoyaltyCardScreen(),
    );
  }
}
