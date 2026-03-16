import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crp_cursos/main.dart';

void main() {
  testWidgets('App should render without errors', (WidgetTester tester) async {
    await tester.pumpWidget(const CrpApp());
    await tester.pump();
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
