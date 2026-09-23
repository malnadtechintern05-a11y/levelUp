import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/app_state.dart';
import '../services/api_client.dart';
import '../services/analytics_service.dart';
import '../widgets/social_auth_icons.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _showEmailForm = false;
  bool _isLoading = false;
  String _loadingText = 'Authenticating...';
  bool _obscurePassword = true;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _loadingText = 'Logging in...';
    });

    final identifier = _identifierController.text.trim();
    final password = _passwordController.text;

    try {
      final state = Provider.of<AppState>(context, listen: false);
      final res = await state.loginUser(identifier, password);

      if (!mounted) return;

      if (res['status'] == 'success') {
        AnalyticsService.instance.logLogin(loginMethod: 'email_password');
        Navigator.pushReplacementNamed(context, '/main');
      } else {
        final message = res['message'] ?? 'Invalid credentials. Please try again.';
        _showErrorSnackBar(message);
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      _showErrorSnackBar(e.message);
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('Connection failed. Start XAMPP (Apache/MySQL) or check Server Settings.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleSocialAuth(String providerName) async {
    setState(() {
      _isLoading = true;
      _loadingText = 'Connecting with $providerName...';
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      String? savedSocialUsername = prefs.getString('saved_${providerName.toLowerCase()}_user');
      if (savedSocialUsername == null || savedSocialUsername.isEmpty) {
        final randSuffix = DateTime.now().millisecondsSinceEpoch.toString().substring(8);
        savedSocialUsername = '${providerName.toLowerCase()}_hero_$randSuffix';
        await prefs.setString('saved_${providerName.toLowerCase()}_user', savedSocialUsername);
      }

      if (!mounted) return;
      final state = Provider.of<AppState>(context, listen: false);
      final res = await state.loginSocial(
        provider: providerName.toLowerCase(),
        username: savedSocialUsername,
        displayName: '$providerName Hero',
        email: '$savedSocialUsername@${providerName.toLowerCase()}.levelup.com',
      );

      if (!mounted) return;

      if (res['status'] == 'success') {
        final activeName = (res['user'] != null && res['user']['username'] != null)
            ? res['user']['username']
            : savedSocialUsername;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎉 Authenticated with $providerName! Welcome, $activeName!'),
            backgroundColor: const Color(0xFF16A34A),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pushReplacementNamed(context, '/main');
      } else {
        _showErrorSnackBar(res['message'] ?? 'Failed to authenticate with $providerName.');
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('Network error connecting with $providerName. Check Server Settings.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleGuestQuickPlay() async {
    setState(() {
      _isLoading = true;
      _loadingText = 'Creating your Hero Journey...';
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      String? savedGuestId = prefs.getString('saved_guest_hero_id');
      if (savedGuestId == null || savedGuestId.isEmpty) {
        savedGuestId = 'hero_${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
        await prefs.setString('saved_guest_hero_id', savedGuestId);
      }

      if (!mounted) return;
      final state = Provider.of<AppState>(context, listen: false);
      final res = await state.loginSocial(
        provider: 'guest',
        username: savedGuestId,
        displayName: 'Guest Adventurer',
        email: '$savedGuestId@guest.levelup.com',
      );

      if (!mounted) return;

      if (res['status'] == 'success') {
        // Award starter bonus
        state.addNotification(
          '🎉 Starter Bonus Claimed!',
          'You received +100 Bonus XP & 50 Gold for starting your epic RPG journey!',
          category: 'System',
        );

        Navigator.pushReplacementNamed(context, '/main');
      } else {
        _showErrorSnackBar(res['message'] ?? 'Failed to start guest session.');
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('Failed to initialize hero profile. Check server connection.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade800,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      body: SafeArea(
        child: Stack(
          children: [
            // Background subtle gradient glow
            Positioned(
              top: -60,
              left: -40,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFF5B942).withValues(alpha: 0.12),
                ),
              ),
            ),
            Positioned(
              bottom: -60,
              right: -40,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF38BDF8).withValues(alpha: 0.08),
                ),
              ),
            ),

            // Main Content Centered Card
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF131926).withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: const Color(0xFF26334D), width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Centered App Logo Badge
                        Center(
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              gradient: const LinearGradient(
                                colors: [Color(0xFFD9F99D), Color(0xFF84CC16)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF84CC16).withValues(alpha: 0.35),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.asset(
                                  'assets/logo.png',
                                  width: 44,
                                  height: 44,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) => const Icon(
                                    Icons.flash_on_rounded,
                                    color: Color(0xFF0F172A),
                                    size: 34,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Title & Subtitle
                        Text(
                          'Welcome to LevelUp',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 26,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sign up and conquer your real life for free',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: const Color(0xFFAAB4C2).withValues(alpha: 0.85),
                            letterSpacing: -0.2,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Loading State Overlay or Auth Content
                        if (_isLoading) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 36.0),
                            child: Column(
                              children: [
                                const CircularProgressIndicator(
                                  color: Color(0xFFF5B942),
                                  strokeWidth: 3,
                                ),
                                const SizedBox(height: 18),
                                Text(
                                  _loadingText,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ] else if (!_showEmailForm) ...[
                          // 1. Highlight Banner / Offer Button
                          _buildOfferButton(
                            title: 'Sign in with business email & Get 50 credits',
                            onTap: _handleGuestQuickPlay,
                          ),

                          const SizedBox(height: 12),

                          // 2. Continue with Google
                          _buildSocialAuthButton(
                            icon: const GoogleLogoIcon(size: 20),
                            label: 'Continue with Google',
                            onTap: () => _handleSocialAuth('Google'),
                          ),

                          const SizedBox(height: 12),

                          // 3. Continue with Apple
                          _buildSocialAuthButton(
                            icon: const AppleLogoIcon(size: 20),
                            label: 'Continue with Apple',
                            onTap: () => _handleSocialAuth('Apple'),
                          ),

                          const SizedBox(height: 12),

                          // 4. Continue with Microsoft
                          _buildSocialAuthButton(
                            icon: const MicrosoftLogoIcon(size: 18),
                            label: 'Continue with Microsoft',
                            onTap: () => _handleSocialAuth('Microsoft'),
                          ),

                          const SizedBox(height: 18),

                          // Divider: OR
                          Row(
                            children: [
                              Expanded(child: Divider(color: const Color(0xFF26334D), thickness: 1)),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                child: Text(
                                  'OR',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                              ),
                              Expanded(child: Divider(color: const Color(0xFF26334D), thickness: 1)),
                            ],
                          ),

                          const SizedBox(height: 18),

                          // 5. Continue with Email
                          _buildSocialAuthButton(
                            icon: const Icon(Icons.mail_outline_rounded, color: Colors.white, size: 20),
                            label: 'Continue with Email',
                            onTap: () {
                              setState(() {
                                _showEmailForm = true;
                              });
                            },
                          ),
                        ] else ...[
                          // Email & Password Form View
                          Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                TextFormField(
                                  controller: _identifierController,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    labelText: 'Username or Email',
                                    prefixIcon: const Icon(Icons.alternate_email, color: Color(0xFFAAB4C2)),
                                    filled: true,
                                    fillColor: const Color(0xFF1E283D),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(color: Color(0xFF2E3D5C)),
                                    ),
                                  ),
                                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter username or email' : null,
                                ),
                                const SizedBox(height: 14),
                                TextFormField(
                                  controller: _passwordController,
                                  style: const TextStyle(color: Colors.white),
                                  obscureText: _obscurePassword,
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFFAAB4C2)),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                        color: const Color(0xFFAAB4C2),
                                      ),
                                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xFF1E283D),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(color: Color(0xFF2E3D5C)),
                                    ),
                                  ),
                                  validator: (v) => (v == null || v.isEmpty) ? 'Please enter your password' : null,
                                ),
                                const SizedBox(height: 18),
                                ElevatedButton(
                                  onPressed: _handleEmailLogin,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFF5B942),
                                    foregroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(vertical: 15),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    elevation: 2,
                                  ),
                                  child: const Text('Log In with Email', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                ),
                                const SizedBox(height: 12),
                                OutlinedButton(
                                  onPressed: () {
                                    setState(() {
                                      _showEmailForm = false;
                                    });
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white70,
                                    side: const BorderSide(color: Color(0xFF2E3D5C)),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  ),
                                  child: const Text('← Back to Social Sign In', style: TextStyle(fontWeight: FontWeight.w600)),
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text("New here? ", style: TextStyle(color: Color(0xFFAAB4C2), fontSize: 13)),
                                    GestureDetector(
                                      onTap: () => Navigator.pushNamed(context, '/register'),
                                      child: const Text(
                                        'Create Account',
                                        style: TextStyle(color: Color(0xFFF5B942), fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),

                        // Bottom SSO / Info Footer
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.cloud_outlined, size: 16, color: Color(0xFF64748B)),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'SSO available on Scale and Enterprise plans',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: const Color(0xFF94A3B8).withValues(alpha: 0.8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfferButton({
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF26331A).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF84CC16).withValues(alpha: 0.45),
          width: 1.2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFFBEF264),
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialAuthButton({
    required Widget icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF192132),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF2B3852),
          width: 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13.5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icon,
                const SizedBox(width: 12),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
