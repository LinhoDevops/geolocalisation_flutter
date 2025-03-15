// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:weather_app/main.dart';

void main() {
  testWidgets('Weather app loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const WeatherApp());

    // Vérifiez quelque chose de spécifique à votre application météo
    // Par exemple, si le SplashScreen contient un texte spécifique :
    expect(find.text('Bienvenue dans Weather Explorer!'), findsOneWidget);

    // Ou vous pourriez vérifier la présence d'un bouton spécifique
    expect(find.byIcon(Icons.explore), findsOneWidget);
  });
}