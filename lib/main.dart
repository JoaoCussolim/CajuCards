import 'package:cajucards/screens/initial_screen.dart';
import 'package:cajucards/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cajucards/providers/player_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cajucards/screens/victory_screen.dart';
import 'package:cajucards/screens/defeat_screen.dart';
import 'package:cajucards/screens/playground.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://gvlcgmozoqjkcexcchrn.supabase.co',
    anonKey: 'sb_publishable_FNhzHMG2L1Yu0gFGa5YI6w_7xkJgqnd',
  );

  runApp(
    // Envolve o MyApp com o ChangeNotifierProvider
    ChangeNotifierProvider(
      create: (context) => PlayerProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'CajuCards',
      home: LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

final supabase = Supabase.instance.client;
