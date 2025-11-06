import 'package:cajucards/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cajucards/providers/player_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flame/flame.dart';
import 'package:cajucards/api/services/socket_service.dart';
import 'package:cajucards/api/api_client.dart'; // 1. Importe o ApiClient

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Flame.images.prefix = '';

  await Supabase.initialize(
    url: 'https://gvlcgmozoqjkcexcchrn.supabase.co',
    anonKey: 'sb_publishable_FNhzHMG2L1Yu0gFGa5YI6w_7xkJgqnd',
  );

  final ApiClient apiClient = ApiClient();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => PlayerProvider(apiClient: apiClient),
        ),
        ChangeNotifierProvider(create: (context) => SocketService()),
      ],
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