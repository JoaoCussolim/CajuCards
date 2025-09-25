import 'package:flutter/material.dart';
import 'package:cajucards/screens/register_screen.dart';
import 'package:cajucards/screens/initial_screen.dart';
import 'package:cajucards/screens/battle_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class MyApp extends StatelessWidget {
  const MyApp({super.key}); 

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'CajuCards',
      home: InitialScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'SUA_SUPABASE_URL',
    anonKey: 'SUA_SUPABASE_ANON_KEY',
  );
  runApp(const MyApp());
}

final supabase = Supabase.instance.client;