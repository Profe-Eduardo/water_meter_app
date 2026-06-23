// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:primera_app/main.dart'; // Asegúrate de que este nombre coincida con tu proyecto

void main() {
  testWidgets('Prueba de humo: Carga inicial de Water Meter', (
    WidgetTester tester,
  ) async {
    // 1. Construye nuestra aplicación y dispara el primer cuadro (frame).
    await tester.pumpWidget(const MiPrimeraApp());

    // 2. Verifica que el título de la pantalla de carga (Splash) aparezca en pantalla.
    expect(find.text('WATER METER'), findsOneWidget);

    // 3. Verifica que inicie buscando actualizaciones.
    expect(find.text('Buscando actualizaciones...'), findsOneWidget);

    // 4. Verifica que pinte el indicador de progreso circular.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
