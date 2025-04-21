// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:travel__planner/main.dart';
import 'package:travel__planner/providers/trip_provider.dart';
import 'package:travel__planner/providers/expense_provider.dart';
import 'package:travel__planner/providers/theme_provider.dart';
import 'package:travel__planner/providers/profile_provider.dart';

void main() {
  testWidgets('App should render without errors', (WidgetTester tester) async {
    // Initialize providers
    final themeProvider = await ThemeProvider.initialize();

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => TripProvider(),
          ),
          ChangeNotifierProvider(
            create: (_) => ExpenseProvider(),
          ),
          ChangeNotifierProvider.value(
            value: themeProvider,
          ),
          ChangeNotifierProvider(
            create: (_) => ProfileProvider(),
          ),
        ],
        child:  MyApp(
          themeProvider: themeProvider,
        ),
      ),
    );

    // Verify that the app renders without errors
    expect(find.byType(MaterialApp), findsOneWidget);
    
    // You can add more specific tests here
    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.text('My Trips'), findsOneWidget);
  });
}
