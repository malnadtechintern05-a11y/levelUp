import 'package:shared_preferences/shared_preferences.dart';

class PrivacyPolicyService {
  static final PrivacyPolicyService instance = PrivacyPolicyService._();
  PrivacyPolicyService._();

  // Keys for LevelUp Privacy Policy
  static const String _kLevelUpLastUpdated = 'pp_levelup_last_updated';
  static const String _kLevelUpIntro = 'pp_levelup_intro';
  static const String _kLevelUpInfoCollected = 'pp_levelup_info_collected';
  static const String _kLevelUpHowWeUse = 'pp_levelup_how_we_use';
  static const String _kLevelUpDataSecurity = 'pp_levelup_data_security';
  static const String _kLevelUpThirdPartyIntro = 'pp_levelup_third_party_intro';
  static const String _kLevelUpLogData = 'pp_levelup_log_data';
  static const String _kLevelUpCookies = 'pp_levelup_cookies';
  static const String _kLevelUpChildren = 'pp_levelup_children';
  static const String _kLevelUpChanges = 'pp_levelup_changes';

  // Keys for PusherHub Privacy Policy
  static const String _kPusherHubLastUpdated = 'pp_pusherhub_last_updated';
  static const String _kPusherHubIntro = 'pp_pusherhub_intro';
  static const String _kPusherHubGrievanceOfficer = 'pp_pusherhub_grievance_officer';
  static const String _kPusherHubGrievanceEmail = 'pp_pusherhub_grievance_email';

  // --- Defaults for LevelUp ---
  static const String defaultLevelUpLastUpdated = '28 September 2026';
  static const String defaultLevelUpIntro =
      'Welcome to LevelUp ("we," "our," or "the app"). LevelUp is designed to turn your daily habits, self-improvement routines, and productivity into an engaging real-life RPG adventure. This Privacy Policy explains how your information is handled when you use the app.';
  static const String defaultLevelUpInfoCollected =
      'LevelUp collects minimal information strictly necessary to power your RPG experience:\n\n'
      '• Profile Data: Hero username and selected avatar profile.\n'
      '• Quest & Habit Data: Quest titles, categories, completion timestamps, countdown timer durations, and daily drinking water logs.\n'
      '• App Preferences: Theme preference (Light/Dark mode) and notification settings.\n\n'
      'The information that we request will be retained by us and used as described in this privacy policy.';
  static const String defaultLevelUpHowWeUse =
      'We use your data exclusively to:\n\n'
      '• Calculate your level, experience points (XP), gold, and skill statistics (Strength, Knowledge, Discipline).\n'
      '• Track daily streak continuity and unlock earned achievements.\n'
      '• Provide hydration tracking and scheduled quest availability.';
  static const String defaultLevelUpDataSecurity =
      'All user profile information, quests, hydration logs, and achievements are stored directly on your physical device using local SQLite database and SharedPreferences storage. You have full offline access at all times, safeguarded by your operating system\'s application sandbox security, device passcode, and biometric protections.';
  static const String defaultLevelUpThirdPartyIntro =
      'The app does use third-party services that may collect information used to identify you.\n\n'
      'Link to the privacy policy of third-party service providers used by the app:';
  static const String defaultLevelUpLogData =
      'We want to inform you that whenever you use our Service, in a case of an error in the app we collect data and information (through third-party products) on your phone called Log Data. This Log Data may include information such as your device Internet Protocol ("IP") address, device name, operating system version, the configuration of the app when utilizing our Service, the time and date of your use of the Service, and other statistics.';
  static const String defaultLevelUpCookies =
      'Cookies are files with a small amount of data that are commonly used as anonymous unique identifiers. These are sent to your browser from the websites that you visit and are stored on your device\'s internal memory.\n\n'
      'This Service does not use these "cookies" explicitly. However, the app may use third-party code and libraries that use "cookies" to collect information and improve their services.';
  static const String defaultLevelUpChildren =
      'LevelUp is safe for users of all ages. We do not knowingly collect personal identifiable information from children under 13. In the case we discover that a child under 13 has provided us with personal information, we immediately delete this from our records.';
  static const String defaultLevelUpChanges =
      'We may update our Privacy Policy periodically. Thus, you are advised to review this page periodically for any changes. We will notify you of any changes by posting the new Privacy Policy on this page.';

  // --- Defaults for PusherHub ---
  static const String defaultPusherHubLastUpdated = '28 September 2026';
  static const String defaultPusherHubIntro =
      'This policy explains what personal data PusherHub collects, why, and what you can do about it. It covers the hosted PusherHub service — the website, the dashboard, the REST API and the SDKs. It doesn\'t cover copies of PusherHub that other people host on their own servers.\n\n'
      'PusherHub is operated by Harsha ("we", "us"), who is responsible for your personal data under India\'s Digital Personal Data Protection Act, 2023.';
  static const String defaultPusherHubGrievanceOfficer = 'Harsha';
  static const String defaultPusherHubGrievanceEmail = 'harsha.malnadtech@gmail.com';

  // --- Getters with Cache ---
  Future<Map<String, String>> getLevelUpPolicy() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'lastUpdated': prefs.getString(_kLevelUpLastUpdated) ?? defaultLevelUpLastUpdated,
      'intro': prefs.getString(_kLevelUpIntro) ?? defaultLevelUpIntro,
      'infoCollected': prefs.getString(_kLevelUpInfoCollected) ?? defaultLevelUpInfoCollected,
      'howWeUse': prefs.getString(_kLevelUpHowWeUse) ?? defaultLevelUpHowWeUse,
      'dataSecurity': prefs.getString(_kLevelUpDataSecurity) ?? defaultLevelUpDataSecurity,
      'thirdPartyIntro': prefs.getString(_kLevelUpThirdPartyIntro) ?? defaultLevelUpThirdPartyIntro,
      'logData': prefs.getString(_kLevelUpLogData) ?? defaultLevelUpLogData,
      'cookies': prefs.getString(_kLevelUpCookies) ?? defaultLevelUpCookies,
      'children': prefs.getString(_kLevelUpChildren) ?? defaultLevelUpChildren,
      'changes': prefs.getString(_kLevelUpChanges) ?? defaultLevelUpChanges,
    };
  }

  Future<Map<String, String>> getPusherHubPolicy() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'lastUpdated': prefs.getString(_kPusherHubLastUpdated) ?? defaultPusherHubLastUpdated,
      'intro': prefs.getString(_kPusherHubIntro) ?? defaultPusherHubIntro,
      'grievanceOfficer': prefs.getString(_kPusherHubGrievanceOfficer) ?? defaultPusherHubGrievanceOfficer,
      'grievanceEmail': prefs.getString(_kPusherHubGrievanceEmail) ?? defaultPusherHubGrievanceEmail,
    };
  }

  // --- Save LevelUp Policy ---
  Future<void> saveLevelUpPolicy({
    required String lastUpdated,
    required String intro,
    required String infoCollected,
    required String howWeUse,
    required String dataSecurity,
    required String thirdPartyIntro,
    required String logData,
    required String cookies,
    required String children,
    required String changes,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLevelUpLastUpdated, lastUpdated);
    await prefs.setString(_kLevelUpIntro, intro);
    await prefs.setString(_kLevelUpInfoCollected, infoCollected);
    await prefs.setString(_kLevelUpHowWeUse, howWeUse);
    await prefs.setString(_kLevelUpDataSecurity, dataSecurity);
    await prefs.setString(_kLevelUpThirdPartyIntro, thirdPartyIntro);
    await prefs.setString(_kLevelUpLogData, logData);
    await prefs.setString(_kLevelUpCookies, cookies);
    await prefs.setString(_kLevelUpChildren, children);
    await prefs.setString(_kLevelUpChanges, changes);
  }

  // --- Save PusherHub Policy ---
  Future<void> savePusherHubPolicy({
    required String lastUpdated,
    required String intro,
    required String grievanceOfficer,
    required String grievanceEmail,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPusherHubLastUpdated, lastUpdated);
    await prefs.setString(_kPusherHubIntro, intro);
    await prefs.setString(_kPusherHubGrievanceOfficer, grievanceOfficer);
    await prefs.setString(_kPusherHubGrievanceEmail, grievanceEmail);
  }

  // --- Reset to default ---
  Future<void> resetToDefaults() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kLevelUpLastUpdated);
    await prefs.remove(_kLevelUpIntro);
    await prefs.remove(_kLevelUpInfoCollected);
    await prefs.remove(_kLevelUpHowWeUse);
    await prefs.remove(_kLevelUpDataSecurity);
    await prefs.remove(_kLevelUpThirdPartyIntro);
    await prefs.remove(_kLevelUpLogData);
    await prefs.remove(_kLevelUpCookies);
    await prefs.remove(_kLevelUpChildren);
    await prefs.remove(_kLevelUpChanges);
    await prefs.remove(_kPusherHubLastUpdated);
    await prefs.remove(_kPusherHubIntro);
    await prefs.remove(_kPusherHubGrievanceOfficer);
    await prefs.remove(_kPusherHubGrievanceEmail);
  }
}
