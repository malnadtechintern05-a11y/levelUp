import 'package:flutter/material.dart';
import '../../services/privacy_policy_service.dart';
import '../pusherhub_privacy_policy_screen.dart';

class AdminPrivacyPolicyScreen extends StatefulWidget {
  const AdminPrivacyPolicyScreen({super.key});

  @override
  State<AdminPrivacyPolicyScreen> createState() => _AdminPrivacyPolicyScreenState();
}

class _AdminPrivacyPolicyScreenState extends State<AdminPrivacyPolicyScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  bool _isEditing = false;

  // LevelUp Controllers
  final _levelUpLastUpdatedController = TextEditingController();
  final _levelUpIntroController = TextEditingController();
  final _levelUpInfoCollectedController = TextEditingController();
  final _levelUpHowWeUseController = TextEditingController();
  final _levelUpDataSecurityController = TextEditingController();
  final _levelUpThirdPartyIntroController = TextEditingController();
  final _levelUpLogDataController = TextEditingController();
  final _levelUpCookiesController = TextEditingController();
  final _levelUpChildrenController = TextEditingController();
  final _levelUpChangesController = TextEditingController();

  // PusherHub Controllers
  final _pusherHubLastUpdatedController = TextEditingController();
  final _pusherHubIntroController = TextEditingController();
  final _pusherHubGrievanceOfficerController = TextEditingController();
  final _pusherHubGrievanceEmailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadPolicyData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _levelUpLastUpdatedController.dispose();
    _levelUpIntroController.dispose();
    _levelUpInfoCollectedController.dispose();
    _levelUpHowWeUseController.dispose();
    _levelUpDataSecurityController.dispose();
    _levelUpThirdPartyIntroController.dispose();
    _levelUpLogDataController.dispose();
    _levelUpCookiesController.dispose();
    _levelUpChildrenController.dispose();
    _levelUpChangesController.dispose();

    _pusherHubLastUpdatedController.dispose();
    _pusherHubIntroController.dispose();
    _pusherHubGrievanceOfficerController.dispose();
    _pusherHubGrievanceEmailController.dispose();
    super.dispose();
  }

  Future<void> _loadPolicyData() async {
    setState(() => _isLoading = true);
    final levelUp = await PrivacyPolicyService.instance.getLevelUpPolicy();
    final pusherHub = await PrivacyPolicyService.instance.getPusherHubPolicy();

    _levelUpLastUpdatedController.text = levelUp['lastUpdated']!;
    _levelUpIntroController.text = levelUp['intro']!;
    _levelUpInfoCollectedController.text = levelUp['infoCollected']!;
    _levelUpHowWeUseController.text = levelUp['howWeUse']!;
    _levelUpDataSecurityController.text = levelUp['dataSecurity']!;
    _levelUpThirdPartyIntroController.text = levelUp['thirdPartyIntro']!;
    _levelUpLogDataController.text = levelUp['logData']!;
    _levelUpCookiesController.text = levelUp['cookies']!;
    _levelUpChildrenController.text = levelUp['children']!;
    _levelUpChangesController.text = levelUp['changes']!;

    _pusherHubLastUpdatedController.text = pusherHub['lastUpdated']!;
    _pusherHubIntroController.text = pusherHub['intro']!;
    _pusherHubGrievanceOfficerController.text = pusherHub['grievanceOfficer']!;
    _pusherHubGrievanceEmailController.text = pusherHub['grievanceEmail']!;

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveAll() async {
    setState(() => _isLoading = true);

    await PrivacyPolicyService.instance.saveLevelUpPolicy(
      lastUpdated: _levelUpLastUpdatedController.text.trim(),
      intro: _levelUpIntroController.text.trim(),
      infoCollected: _levelUpInfoCollectedController.text.trim(),
      howWeUse: _levelUpHowWeUseController.text.trim(),
      dataSecurity: _levelUpDataSecurityController.text.trim(),
      thirdPartyIntro: _levelUpThirdPartyIntroController.text.trim(),
      logData: _levelUpLogDataController.text.trim(),
      cookies: _levelUpCookiesController.text.trim(),
      children: _levelUpChildrenController.text.trim(),
      changes: _levelUpChangesController.text.trim(),
    );

    await PrivacyPolicyService.instance.savePusherHubPolicy(
      lastUpdated: _pusherHubLastUpdatedController.text.trim(),
      intro: _pusherHubIntroController.text.trim(),
      grievanceOfficer: _pusherHubGrievanceOfficerController.text.trim(),
      grievanceEmail: _pusherHubGrievanceEmailController.text.trim(),
    );

    setState(() {
      _isLoading = false;
      _isEditing = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Privacy Policies updated and published successfully!'),
          backgroundColor: Color(0xFF16A34A),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _resetDefaults() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text('Reset Policies?', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: const Text(
          'Are you sure you want to revert all changes back to the default Privacy Policy templates?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Reset All'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await PrivacyPolicyService.instance.resetToDefaults();
      await _loadPolicyData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🔄 Reverted to default Privacy Policy templates.')),
        );
      }
    }
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
    String? helper,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.amber, fontSize: 13, fontWeight: FontWeight.bold),
          ),
          if (helper != null) ...[
            const SizedBox(height: 2),
            Text(helper, style: const TextStyle(color: Colors.white54, fontSize: 11)),
          ],
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            maxLines: maxLines,
            style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF1E293B),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF334155)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF334155)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.amber),
              ),
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewSection(String title, String content, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.amber, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.5),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.amber));
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1C),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Privacy Policy Management',
                      style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Review, modify and publish application privacy policies in real-time.',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
                Wrap(
                  spacing: 12,
                  children: [
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: const BorderSide(color: Color(0xFF334155)),
                      ),
                      onPressed: _resetDefaults,
                      icon: const Icon(Icons.restore, size: 16),
                      label: const Text('Reset Defaults'),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isEditing ? const Color(0xFF16A34A) : Colors.amber,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        if (_isEditing) {
                          _saveAll();
                        } else {
                          setState(() => _isEditing = true);
                        }
                      },
                      icon: Icon(_isEditing ? Icons.save_rounded : Icons.edit_note_rounded, size: 18),
                      label: Text(
                        _isEditing ? 'Save & Publish' : 'Edit Policy',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Tab Bar
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorColor: Colors.amber,
                labelColor: Colors.amber,
                unselectedLabelColor: Colors.grey,
                tabs: const [
                  Tab(icon: Icon(Icons.shield_outlined), text: 'LevelUp Privacy Policy'),
                  Tab(icon: Icon(Icons.notifications_active_outlined), text: 'PusherHub Privacy Policy'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tab Contents
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: LevelUp Privacy Policy
                  _isEditing ? _buildLevelUpEditForm() : _buildLevelUpPreview(),

                  // Tab 2: PusherHub Privacy Policy
                  _isEditing ? _buildPusherHubEditForm() : _buildPusherHubPreview(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelUpPreview() {
    return ListView(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.verified, color: Colors.amber, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Live LevelUp Policy', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    Text('Last Updated: ${_levelUpLastUpdatedController.text}', style: const TextStyle(color: Colors.amber, fontSize: 12)),
                  ],
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.amber),
                onPressed: () => setState(() => _isEditing = true),
                icon: const Icon(Icons.edit, size: 14),
                label: const Text('Edit'),
              ),
            ],
          ),
        ),
        _buildPreviewSection('1. Introduction', _levelUpIntroController.text, Icons.info_outline),
        _buildPreviewSection('2. Information We Collect', _levelUpInfoCollectedController.text, Icons.folder_open_outlined),
        _buildPreviewSection('3. How We Use Your Information', _levelUpHowWeUseController.text, Icons.psychology_outlined),
        _buildPreviewSection('4. Data Storage & Security', _levelUpDataSecurityController.text, Icons.lock_outline),
        _buildPreviewSection('5. Third-Party Services Included',
            '• Google Play Services\n• AdMob\n• Google Analytics for Firebase\n• Firebase Crashlytics\n• Facebook\n• PusherHub (Interactive In-App Link)', Icons.public_outlined),
        _buildPreviewSection('6. Log Data', _levelUpLogDataController.text, Icons.receipt_long_outlined),
        _buildPreviewSection('7. Cookies', _levelUpCookiesController.text, Icons.cookie_outlined),
        _buildPreviewSection('8. Children\'s Privacy', _levelUpChildrenController.text, Icons.child_care_outlined),
        _buildPreviewSection('9. Changes to This Policy', _levelUpChangesController.text, Icons.update_outlined),
      ],
    );
  }

  Widget _buildLevelUpEditForm() {
    return ListView(
      children: [
        _buildTextField(label: 'Last Updated Date String', controller: _levelUpLastUpdatedController, helper: 'e.g. 28 September 2026'),
        _buildTextField(label: '1. Introduction', controller: _levelUpIntroController, maxLines: 4),
        _buildTextField(label: '2. Information We Collect', controller: _levelUpInfoCollectedController, maxLines: 5),
        _buildTextField(label: '3. How We Use Your Information', controller: _levelUpHowWeUseController, maxLines: 5),
        _buildTextField(label: '4. Data Storage & Security', controller: _levelUpDataSecurityController, maxLines: 4),
        _buildTextField(label: '5. Third-Party Services Header Description', controller: _levelUpThirdPartyIntroController, maxLines: 3),
        _buildTextField(label: '6. Log Data Policy', controller: _levelUpLogDataController, maxLines: 4),
        _buildTextField(label: '7. Cookies Policy', controller: _levelUpCookiesController, maxLines: 4),
        _buildTextField(label: '8. Children\'s Privacy', controller: _levelUpChildrenController, maxLines: 3),
        _buildTextField(label: '9. Changes to This Policy', controller: _levelUpChangesController, maxLines: 3),
      ],
    );
  }

  Widget _buildPusherHubPreview() {
    return ListView(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.notifications_active, color: Colors.amber, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('PusherHub Privacy Policy', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    Text('Last Updated: ${_pusherHubLastUpdatedController.text}', style: const TextStyle(color: Colors.amber, fontSize: 12)),
                  ],
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.amber),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const PusherHubPrivacyPolicyScreen()));
                },
                icon: const Icon(Icons.visibility, size: 14),
                label: const Text('View Full Screen'),
              ),
            ],
          ),
        ),
        _buildPreviewSection('PusherHub Scope & DPDP Act 2023', _pusherHubIntroController.text, Icons.info_outline),
        _buildPreviewSection('Grievance Officer Name', _pusherHubGrievanceOfficerController.text, Icons.badge_outlined),
        _buildPreviewSection('Grievance Officer Email', _pusherHubGrievanceEmailController.text, Icons.email_outlined),
        _buildPreviewSection('Two Kinds of Data',
            '• Your account data: Customer account info.\n• App users\' data: Processed strictly to deliver notifications.', Icons.layers_outlined),
        _buildPreviewSection('What We Collect & Store',
            '• Account details (hashed passwords)\n• Google Sign-in\n• Device FCM token, platform, app version\n• Encrypted credentials', Icons.devices_other_outlined),
        _buildPreviewSection('Third-Party Service Sharing',
            '• Google (FCM & Sign-in)\n• Razorpay payment gateway\n• Secure hosting & email servers', Icons.share_outlined),
        _buildPreviewSection('User Rights under India DPDP Act 2023',
            '• Summary, Correction, Erasure, Consent Withdrawal, Nomination, Grievance Officer', Icons.gavel_outlined),
      ],
    );
  }

  Widget _buildPusherHubEditForm() {
    return ListView(
      children: [
        _buildTextField(label: 'Last Updated Date String', controller: _pusherHubLastUpdatedController, helper: 'e.g. 28 September 2026'),
        _buildTextField(label: 'Scope, Operator & DPDP Act 2023 Overview', controller: _pusherHubIntroController, maxLines: 5),
        _buildTextField(label: 'Grievance Officer Name', controller: _pusherHubGrievanceOfficerController, helper: 'e.g. Harsha'),
        _buildTextField(label: 'Grievance Officer Email', controller: _pusherHubGrievanceEmailController, helper: 'e.g. harsha.malnadtech@gmail.com'),
      ],
    );
  }
}
