import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:real_life_rpg/providers/app_state.dart';
import 'package:real_life_rpg/providers/admin_state.dart';
import 'package:real_life_rpg/providers/rankings_provider.dart';
import 'package:real_life_rpg/screens/login_screen.dart';
import 'package:real_life_rpg/screens/register_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({'is_logged_in': false});
  });

  testWidgets('LoginScreen renders fields and hero branding', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AppState()),
          ChangeNotifierProvider(create: (_) => AdminState()),
          ChangeNotifierProvider(create: (_) => RankingsProvider()),
        ],
        child: const MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    expect(find.text('Welcome Back Hero'), findsOneWidget);
    expect(find.text('LOG IN'), findsOneWidget);
    expect(find.text('Username or Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });

  testWidgets('RegisterScreen renders fields and avatar selector', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AppState()),
          ChangeNotifierProvider(create: (_) => AdminState()),
          ChangeNotifierProvider(create: (_) => RankingsProvider()),
        ],
        child: const MaterialApp(
          home: RegisterScreen(),
        ),
      ),
    );

    expect(find.text('BEGIN YOUR JOURNEY'), findsOneWidget);
    expect(find.text('Choose Your Avatar'), findsOneWidget);
    expect(find.text('Hero Username'), findsOneWidget);
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('CREATE HERO ACCOUNT'), findsOneWidget);
  });
}
