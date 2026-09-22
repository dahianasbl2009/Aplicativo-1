import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Supabase con las credenciales del proyecto
  await Supabase.initialize(
    url: 'https://wvagjbetevrjyctjoanr.supabase.co',
    anonKey: 'sb_publishable_-NtYHUpewCImXQq07cGAaw_d38IgwY1',
  );

  runApp(const SiraApp());
}

class SiraApp extends StatelessWidget {
  const SiraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SIRA - Gestión de Aprendices',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      // Inicia directamente en la pantalla de Inicio de Sesión
      home: const LoginScreen(),
    );
  }
}
