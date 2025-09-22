import 'package:flutter/material.dart';
import 'package:cajucards/screens/registerScreen.dart';
import 'package:cajucards/screens/initialScreen.dart';
import 'package:cajucards/screens/battleScreen.dart';
import 'package:cajucards/screens/shopScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); 

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'CajuCards',
      home: ShopScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}