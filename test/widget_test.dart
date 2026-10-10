import 'package:app_flutter/app/app.dart';
import 'package:app_flutter/features/home/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App renders the home feature', (tester) async {
    await tester.pumpWidget(const App());

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(HomeView), findsOneWidget);
    expect(find.text('Foundation ready'), findsOneWidget);
  });
}
