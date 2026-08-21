import 'package:flutter/material.dart';
import 'tema_app.dart';
import 'vistas/vista_catalogo.dart';

void main() {
  runApp(const AplicacionAgroDirecto());
}

class AplicacionAgroDirecto extends StatelessWidget {
  const AplicacionAgroDirecto({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgroDirecto',
      debugShowCheckedModeBanner: false,
      theme: TemaApp.temaClaro,
      home: const VistaCatalogo(),
    );
  }
}
