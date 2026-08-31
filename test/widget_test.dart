import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agro_directo/main.dart';

void main() {
  testWidgets('El catálogo muestra el título y al menos un lote', (WidgetTester tester) async {
    await tester.pumpWidget(const AplicacionAgroDirecto());

    expect(find.text('AgroDirecto'), findsOneWidget);

    final botonComprador = find.text('Soy Comprador / Restaurante');
    await tester.ensureVisible(botonComprador);
    await tester.pumpAndSettle();
    await tester.tap(botonComprador);
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.shopping_basket), findsOneWidget);
    expect(find.text('Limón Criollo'), findsOneWidget);
  });
}
