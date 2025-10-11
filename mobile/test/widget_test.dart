import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pet_grooming_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PetGroomingApp());

    // Verify that the app builds without throwing an exception.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
