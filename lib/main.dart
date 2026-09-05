import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'tema_app.dart';
import 'vistas/vista_login.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://uewivsswuxrfndekybuk.supabase.co', 
    publishableKey: 'sb_publishable_c_OtopQLQbfU75ahNc7BIw_D9gKmLTq',                  
  );

  runApp(const AplicacionAgroDirecto());
}

final supabase = Supabase.instance.client;

class AplicacionAgroDirecto extends StatelessWidget {
  const AplicacionAgroDirecto({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgroDirecto',
      debugShowCheckedModeBanner: false,
      theme: TemaApp.temaClaro,
      home: const VistaLogin(),
    );
  }
}
