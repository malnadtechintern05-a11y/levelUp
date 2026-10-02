import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/privacy_policy_service.dart';

class PusherHubPrivacyPolicyScreen extends StatefulWidget {
  const PusherHubPrivacyPolicyScreen({super.key});

  @override
  State<PusherHubPrivacyPolicyScreen> createState() => _PusherHubPrivacyPolicyScreenState();
}

class _PusherHubPrivacyPolicyScreenState extends State<PusherHubPrivacyPolicyScreen> {
  late Future<Map<String, String>> _policyFuture;

  @override
  void initState() {
    super.initState();
    _policyFuture = PrivacyPolicyService.instance.getPusherHubPolicy();
  }

  Widget _buildSectionCard({
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5B942).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: const Color(0xFFF5B942), size: 18),
              ),
              const SizedBox(width: 12),
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

  Widget _buildBulletItem({
    required BuildContext context,
    required String title,
    required String body,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFFF5B942),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 13,
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
                children: [
                  TextSpan(
                    text: '$title: ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  TextSpan(text: body),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('PusherHub Privacy Policy', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: FutureBuilder<Map<String, String>>(
        future: _policyFuture,
        builder: (context, snapshot) {
          final policy = snapshot.data ?? {
            'lastUpdated': PrivacyPolicyService.defaultPusherHubLastUpdated,
            'intro': PrivacyPolicyService.defaultPusherHubIntro,
            'grievanceOfficer': PrivacyPolicyService.defaultPusherHubGrievanceOfficer,
            'grievanceEmail': PrivacyPolicyService.defaultPusherHubGrievanceEmail,
          };

          final lastUpdated = policy['lastUpdated'] ?? PrivacyPolicyService.defaultPusherHubLastUpdated;
          final intro = policy['intro'] ?? PrivacyPolicyService.defaultPusherHubIntro;
          final officer = policy['grievanceOfficer'] ?? PrivacyPolicyService.defaultPusherHubGrievanceOfficer;
          final email = policy['grievanceEmail'] ?? PrivacyPolicyService.defaultPusherHubGrievanceEmail;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Header
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
                          child: const Icon(Icons.notifications_active_outlined, color: Color(0xFFF5B942), size: 26),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'PusherHub Privacy Policy',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Last updated $lastUpdated',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      intro,
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              // Two kinds of data
              _buildSectionCard(
                context: context,
                title: 'Two Kinds of Data',
                icon: Icons.layers_outlined,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBulletItem(
                      context: context,
                      title: 'Your account data',
                      body: 'About you, as a PusherHub customer. We decide how it\'s used, and this policy explains how.',
                    ),
                    _buildBulletItem(
                      context: context,
                      title: 'Your app users\' data',
                      body: 'About the people who use the apps you connect to PusherHub. You decide what\'s collected and why; we store and process it only to deliver your notifications and messages, on your instructions. If you\'re one of those app users, the app\'s own privacy policy applies, and the app\'s developer is the right person to contact first.',
                    ),
                  ],
                ),
              ),

              // What we collect about you
              _buildSectionCard(
                context: context,
                title: 'What We Collect About You',
                icon: Icons.person_outline,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBulletItem(
                      context: context,
                      title: 'Account details',
                      body: 'Your name, email address and password. Passwords are stored only as a secure hash; we can\'t see them.',
                    ),
                    _buildBulletItem(
                      context: context,
                      title: 'Google sign-in',
                      body: 'If you sign in with Google, we receive your name, email address, Google account ID and profile picture. We don\'t get your Google password or access to anything else in your Google account.',
                    ),
                    _buildBulletItem(
                      context: context,
                      title: 'Sign-in records',
                      body: 'When you last signed in, and the IP address used to ask for a sign-in or password-reset code. The codes themselves are stored only as a hash and deleted once they expire.',
                    ),
                    _buildBulletItem(
                      context: context,
                      title: 'Payments',
                      body: 'The plan you bought, the amount, the date and status, and the Razorpay order and payment IDs. Your card, UPI or bank details go straight to Razorpay; we never receive or store them.',
                    ),
                    _buildBulletItem(
                      context: context,
                      title: 'What you set up in PusherHub',
                      body: 'Your apps, the Firebase service account you connect, API keys, notifications, templates, segments, topics, in-app messages and webhook addresses. Firebase service accounts and API secret keys are stored encrypted.',
                    ),
                    _buildBulletItem(
                      context: context,
                      title: 'Server logs',
                      body: 'Like most websites, our servers record requests (IP address, time, page and browser) for security and troubleshooting.',
                    ),
                  ],
                ),
              ),

              // What PusherHub stores about your app users
              _buildSectionCard(
                context: context,
                title: 'What PusherHub Stores About Your App Users',
                icon: Icons.devices_other_outlined,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'When your app registers a device with PusherHub, through our SDK or API, we store:',
                      style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant, height: 1.4),
                    ),
                    const SizedBox(height: 8),
                    _buildBulletItem(
                      context: context,
                      title: 'Device info',
                      body: 'The device\'s Firebase messaging token, platform, brand and model, app version, language and timezone.',
                    ),
                    _buildBulletItem(
                      context: context,
                      title: 'Notification status',
                      body: 'Whether the user has allowed notifications, and when the device was last active.',
                    ),
                    _buildBulletItem(
                      context: context,
                      title: 'User ID',
                      body: 'A user ID, only if your app sends one.',
                    ),
                    _buildBulletItem(
                      context: context,
                      title: 'Approximate location',
                      body: 'Country, state and city — worked out from the device\'s IP address. The IP address itself isn\'t stored with the device.',
                    ),
                    _buildBulletItem(
                      context: context,
                      title: 'Engagement history',
                      body: 'What happened to each notification and in-app message: delivered, opened, clicked, shown or dismissed.',
                    ),
                  ],
                ),
              ),

              // How we use data
              _buildSectionCard(
                context: context,
                title: 'How We Use Data',
                icon: Icons.psychology_outlined,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBulletItem(
                      context: context,
                      title: 'Service operations',
                      body: 'To run the Service: sign you in, send your notifications and messages, and show your analytics.',
                    ),
                    _buildBulletItem(
                      context: context,
                      title: 'Plans & limits',
                      body: 'To apply your plan\'s limits and features, and to process your payments.',
                    ),
                    _buildBulletItem(
                      context: context,
                      title: 'Communications',
                      body: 'To email you sign-in codes, password-reset codes, and important messages about your account or the Service.',
                    ),
                    _buildBulletItem(
                      context: context,
                      title: 'Security',
                      body: 'To keep PusherHub secure: block abuse, limit repeated sign-in attempts and investigate problems.',
                    ),
                    _buildBulletItem(
                      context: context,
                      title: 'Legal obligations',
                      body: 'To meet our legal, tax and accounting obligations.',
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5B942).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFF5B942).withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        '🛡️ We don\'t sell personal data, we don\'t show ads, and we don\'t use your app users\' data for any purpose of our own.',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),

              // Cookies
              _buildSectionCard(
                context: context,
                title: 'Cookies',
                icon: Icons.cookie_outlined,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'We only use the cookies the site needs to work:',
                      style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 8),
                    _buildBulletItem(
                      context: context,
                      title: 'Session cookie',
                      body: 'Keeps you signed in.',
                    ),
                    _buildBulletItem(
                      context: context,
                      title: 'Security token (XSRF-TOKEN)',
                      body: 'Protects forms against cross-site request forgery.',
                    ),
                    _buildBulletItem(
                      context: context,
                      title: '"Remember me" cookie',
                      body: 'Only if you tick that box when you sign in.',
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'We don\'t use analytics or advertising cookies. Some pages load services from other companies, which may set their own cookies or see your IP address: fonts from Google Fonts on our public pages, Google Sign-In on the sign-in page, and Razorpay Checkout when you pay.',
                      style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant, height: 1.45),
                    ),
                  ],
                ),
              ),

              // Who we share data with
              _buildSectionCard(
                context: context,
                title: 'Who We Share Data With',
                icon: Icons.share_outlined,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'We share personal data only with the service providers that help us run PusherHub, and only what they need:',
                      style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 8),
                    _buildBulletItem(
                      context: context,
                      title: 'Google (Firebase Cloud Messaging)',
                      body: 'To deliver push notifications, through the Firebase project you connect.',
                    ),
                    _buildBulletItem(
                      context: context,
                      title: 'Google (Sign-In)',
                      body: 'If you choose to sign in with Google.',
                    ),
                    _buildBulletItem(
                      context: context,
                      title: 'Razorpay',
                      body: 'To process payments.',
                    ),
                    _buildBulletItem(
                      context: context,
                      title: 'Hosting & Email Providers',
                      body: 'Our hosting provider, which runs the servers PusherHub is on, and our email provider, which delivers sign-in and reset codes.',
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'We may also disclose data where the law requires it — for example, a valid order from a court or government authority — or where it\'s needed to protect the rights, property or safety of our users or the public. Some providers, such as Google, may process data outside India under their own privacy and security commitments.',
                      style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant, height: 1.45),
                    ),
                  ],
                ),
              ),

              // How long we keep data
              _buildSectionCard(
                context: context,
                title: 'How Long We Keep Data',
                icon: Icons.timer_outlined,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBulletItem(
                      context: context,
                      title: 'Account data',
                      body: 'For as long as you have an account. When you ask us to delete your account, we delete your account data together with the apps, devices and messages in it.',
                    ),
                    _buildBulletItem(
                      context: context,
                      title: 'Payment records',
                      body: 'For as long as Indian tax and accounting law requires, even after your account is deleted.',
                    ),
                    _buildBulletItem(
                      context: context,
                      title: 'Sign-in and reset codes',
                      body: 'Deleted once they expire.',
                    ),
                    _buildBulletItem(
                      context: context,
                      title: 'App users\' devices',
                      body: 'Removed after they\'ve been inactive for the period set for each app, or when you delete the app.',
                    ),
                    _buildBulletItem(
                      context: context,
                      title: 'Delivery and engagement records',
                      body: 'Kept while your account exists, so your analytics keep working.',
                    ),
                    _buildBulletItem(
                      context: context,
                      title: 'Server logs',
                      body: 'Kept only as long as they\'re needed for security and troubleshooting.',
                    ),
                  ],
                ),
              ),

              // How we protect data
              _buildSectionCard(
                context: context,
                title: 'How We Protect Data',
                icon: Icons.security_outlined,
                child: Text(
                  'Passwords and sign-in codes are hashed. Firebase service accounts and API secret keys are encrypted. Each customer can see only their own apps and data, and sign-in attempts are rate-limited. No system is perfectly secure, but if a breach affects your personal data, we\'ll tell you and the authorities as the law requires.',
                  style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant, height: 1.5),
                ),
              ),

              // Your rights
              _buildSectionCard(
                context: context,
                title: 'Your Rights',
                icon: Icons.gavel_outlined,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Under India\'s Digital Personal Data Protection Act, 2023, you can:',
                      style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 8),
                    _buildBulletItem(context: context, title: 'Summary', body: 'Ask for a summary of the personal data we hold about you and how we use it.'),
                    _buildBulletItem(context: context, title: 'Correction', body: 'Ask us to correct, complete or update it.'),
                    _buildBulletItem(context: context, title: 'Erasure', body: 'Ask us to delete it, unless the law requires us to keep it.'),
                    _buildBulletItem(context: context, title: 'Consent Withdrawal', body: 'Withdraw your consent — which may mean closing your account.'),
                    _buildBulletItem(context: context, title: 'Nomination', body: 'Nominate someone to exercise these rights for you if you die or can\'t act yourself.'),
                    _buildBulletItem(context: context, title: 'Grievance', body: 'Raise a grievance with us and, if you\'re not satisfied with our answer, complain to the Data Protection Board of India.'),
                    const SizedBox(height: 6),
                    Text(
                      'You can change your password at any time with Forgot password? on the sign-in page. For anything else, contact our Grievance Officer below.',
                      style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant, height: 1.4),
                    ),
                  ],
                ),
              ),

              // Children
              _buildSectionCard(
                context: context,
                title: 'Children\'s Privacy',
                icon: Icons.child_care_outlined,
                child: Text(
                  'PusherHub is a service for businesses and developers, and isn\'t meant for anyone under 18. If you believe a child has created an account, contact us and we\'ll delete it.',
                  style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant, height: 1.5),
                ),
              ),

              // Changes to this policy
              _buildSectionCard(
                context: context,
                title: 'Changes to This Policy',
                icon: Icons.update_outlined,
                child: Text(
                  'When we change this policy, we update the date at the top. If a change is significant, we\'ll tell you by email or in the dashboard before it takes effect.',
                  style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant, height: 1.5),
                ),
              ),

              // Contact and Grievance Officer
              _buildSectionCard(
                context: context,
                title: 'Contact and Grievance Officer',
                icon: Icons.contact_mail_outlined,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'For questions, requests or complaints about your personal data:',
                      style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFF5B942).withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.badge_outlined, color: Color(0xFFF5B942), size: 18),
                              const SizedBox(width: 8),
                              Text('Grievance Officer: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: theme.colorScheme.onSurface)),
                              Text(officer, style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () async {
                              final uri = Uri(
                                scheme: 'mailto',
                                path: email,
                                query: 'subject=PusherHub Privacy & Data Protection Inquiry',
                              );
                              try {
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri);
                                }
                              } catch (_) {}
                            },
                            borderRadius: BorderRadius.circular(6),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.email_outlined, color: Color(0xFFF5B942), size: 18),
                                  const SizedBox(width: 8),
                                  const Text('Email: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFF5B942))),
                                  Text(
                                    email,
                                    style: const TextStyle(fontSize: 13, color: Color(0xFF38BDF8), decoration: TextDecoration.underline),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'We\'ll acknowledge your request and respond within the time limits set by Indian law.',
                      style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }
}
