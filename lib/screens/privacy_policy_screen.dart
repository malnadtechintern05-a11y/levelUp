import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/privacy_policy_service.dart';
import '../screens/pusherhub_privacy_policy_screen.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  late Future<Map<String, String>> _policyFuture;

  @override
  void initState() {
    super.initState();
    _policyFuture = PrivacyPolicyService.instance.getLevelUpPolicy();
  }

  Future<void> _launchUrl(BuildContext context, String urlString) async {
    final uri = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      }
    } catch (_) {}

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open link: $urlString')),
      );
    }
  }

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required String content,
    IconData? icon,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF162033) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: const Color(0xFFF5B942), size: 20),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomSection({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF162033) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFFF5B942), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildThirdPartyLink({
    required BuildContext context,
    required String title,
    required VoidCallback onTap,
    bool isSpecial = false,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isSpecial ? const Color(0xFFF5B942) : const Color(0xFF38BDF8),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSpecial ? FontWeight.bold : FontWeight.w500,
                    color: isSpecial
                        ? (isDark ? const Color(0xFFF5B942) : const Color(0xFFD97706))
                        : const Color(0xFF38BDF8),
                    decoration: TextDecoration.underline,
                    decorationColor: isSpecial
                        ? const Color(0xFFF5B942).withValues(alpha: 0.6)
                        : const Color(0xFF38BDF8).withValues(alpha: 0.6),
                  ),
                ),
              ),
              Icon(
                isSpecial ? Icons.chevron_right_rounded : Icons.open_in_new_rounded,
                size: 16,
                color: isSpecial ? const Color(0xFFF5B942) : theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: FutureBuilder<Map<String, String>>(
        future: _policyFuture,
        builder: (context, snapshot) {
          final policy = snapshot.data ?? {
            'lastUpdated': PrivacyPolicyService.defaultLevelUpLastUpdated,
            'intro': PrivacyPolicyService.defaultLevelUpIntro,
            'infoCollected': PrivacyPolicyService.defaultLevelUpInfoCollected,
            'howWeUse': PrivacyPolicyService.defaultLevelUpHowWeUse,
            'dataSecurity': PrivacyPolicyService.defaultLevelUpDataSecurity,
            'thirdPartyIntro': PrivacyPolicyService.defaultLevelUpThirdPartyIntro,
            'logData': PrivacyPolicyService.defaultLevelUpLogData,
            'cookies': PrivacyPolicyService.defaultLevelUpCookies,
            'children': PrivacyPolicyService.defaultLevelUpChildren,
            'changes': PrivacyPolicyService.defaultLevelUpChanges,
          };

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                        : [const Color(0xFFF8FAFC), const Color(0xFFEDE9FE)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFF5B942).withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5B942).withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.shield_outlined, color: Color(0xFFF5B942), size: 28),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'LevelUp Privacy Policy',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Last Updated: ${policy['lastUpdated']}',
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Your privacy and data sovereignty are fundamental to our mission. LevelUp is built with privacy-first architecture.',
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              // 1. Introduction
              _buildSection(
                context: context,
                title: '1. Introduction',
                icon: Icons.info_outline,
                content: policy['intro']!,
              ),

              // 2. Information We Collect
              _buildSection(
                context: context,
                title: '2. Information We Collect',
                icon: Icons.folder_open_outlined,
                content: policy['infoCollected']!,
              ),

              // 3. How We Use Your Information
              _buildSection(
                context: context,
                title: '3. How We Use Your Information',
                icon: Icons.psychology_outlined,
                content: policy['howWeUse']!,
              ),

              // 4. Task and Progress Data
              _buildSection(
                context: context,
                title: '4. Task and Progress Data',
                icon: Icons.check_circle_outline,
                content:
                    'All quest records, completion history, XP logs, hydration entries, and personal milestones remain your private data. They are never shared, sold, broadcast, or monetized.',
              ),

              // 5. Notifications
              _buildSection(
                context: context,
                title: '5. Notifications',
                icon: Icons.notifications_none,
                content:
                    'LevelUp provides local in-app congratulatory celebrations and reminders (such as task completion alerts, Level Up announcements, and streak maintenance). Notifications are generated locally on your device without tracking your activity.',
              ),

              // 6. Data Storage & Security
              _buildSection(
                context: context,
                title: '6. Data Storage & Security',
                icon: Icons.lock_outline,
                content: policy['dataSecurity']!,
              ),

              // 7. Third-Party Services
              _buildCustomSection(
                context: context,
                title: '7. Third-Party Service Providers',
                icon: Icons.public_outlined,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      policy['thirdPartyIntro']!,
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildThirdPartyLink(
                            context: context,
                            title: 'Google Play Services',
                            onTap: () => _launchUrl(context, 'https://policies.google.com/privacy'),
                          ),
                          Divider(height: 1, color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                          _buildThirdPartyLink(
                            context: context,
                            title: 'AdMob',
                            onTap: () => _launchUrl(context, 'https://support.google.com/admob/answer/6128543?hl=en'),
                          ),
                          Divider(height: 1, color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                          _buildThirdPartyLink(
                            context: context,
                            title: 'Google Analytics for Firebase',
                            onTap: () => _launchUrl(context, 'https://firebase.google.com/policies/analytics'),
                          ),
                          Divider(height: 1, color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                          _buildThirdPartyLink(
                            context: context,
                            title: 'Firebase Crashlytics',
                            onTap: () => _launchUrl(context, 'https://firebase.google.com/support/privacy'),
                          ),
                          Divider(height: 1, color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                          _buildThirdPartyLink(
                            context: context,
                            title: 'Facebook',
                            onTap: () => _launchUrl(context, 'https://www.facebook.com/about/privacy/update/printable'),
                          ),
                          Divider(height: 1, color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                          _buildThirdPartyLink(
                            context: context,
                            title: 'PusherHub',
                            isSpecial: true,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const PusherHubPrivacyPolicyScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 8. Log Data
              _buildSection(
                context: context,
                title: '8. Log Data',
                icon: Icons.receipt_long_outlined,
                content: policy['logData']!,
              ),

              // 9. Cookies
              _buildSection(
                context: context,
                title: '9. Cookies',
                icon: Icons.cookie_outlined,
                content: policy['cookies']!,
              ),

              // 10. Children's Privacy
              _buildSection(
                context: context,
                title: '10. Children\'s Privacy',
                icon: Icons.child_care_outlined,
                content: policy['children']!,
              ),

              // 11. Changes to This Privacy Policy
              _buildSection(
                context: context,
                title: '11. Changes to This Privacy Policy',
                icon: Icons.update_outlined,
                content: policy['changes']!,
              ),
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }
}
