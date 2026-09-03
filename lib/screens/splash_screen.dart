import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/api_config.dart';
import '../providers/app_state.dart';
import '../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSessionAndNavigate();
  }

  Future<void> _checkSessionAndNavigate() async {
    await ApiConfig.init();
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    final isLoggedIn = await AuthService.instance.isLoggedIn();

    if (isLoggedIn) {
      if (!mounted) return;
      try {
        final state = Provider.of<AppState>(context, listen: false);
        await state.refreshAllData();
      } catch (_) {
        // Continue with local cache if network is temporarily unreachable
      }
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/main');
    } else {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                'assets/logo.png',
                width: 140,
                height: 140,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 24),
            const Text('LEVEL UP', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            const SizedBox(height: 4),
            const Text('REAL LIFE RPG', style: TextStyle(color: Color(0xFFF5B942), fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 40),
            const CircularProgressIndicator(color: Color(0xFFF5B942)),
          ],
        ),
      ),
    );
  }
}
