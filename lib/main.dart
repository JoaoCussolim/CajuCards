import 'package:flutter/material.dart';
import 'package:cajucards/screens/register_screen.dart';
import 'package:cajucards/screens/initial_screen.dart';
import 'package:cajucards/screens/history_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class MyApp extends StatelessWidget {
  const MyApp({super.key}); 

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'CajuCards',
      home: HistoryScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://gvlcgmozoqjkcexcchrn.supabase.co',
    anonKey: 'sb_publishable_FNhzHMG2L1Yu0gFGa5YI6w_7xkJgqnd',
  );
  runApp(const MyApp());
}

final supabase = Supabase.instance.client;