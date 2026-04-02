// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'InspectSync';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get loginSubtitle => 'Access your field operations dashboard';

  @override
  String get emailAddressLabel => 'EMAIL ADDRESS';

  @override
  String get emailHint => 'name@company.com';

  @override
  String get passwordLabel => 'PASSWORD';

  @override
  String get passwordHint => '••••••••';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get rememberDevice => 'Remember this device';

  @override
  String get loginButton => 'Log In to Dashboard';

  @override
  String get dontHaveAccount => 'Don\'t have an account? ';

  @override
  String get contactAdmin => 'Contact Admin';

  @override
  String get encryptedSyncActive => 'ENCRYPTED SYNC ACTIVE';

  @override
  String get bottomNavDashboard => 'DASHBOARD';

  @override
  String get bottomNavMap => 'MAP';

  @override
  String get bottomNavTasks => 'TASKS';

  @override
  String get bottomNavSettings => 'SETTINGS';

  @override
  String get precisionField => 'Precision Field';

  @override
  String get allLocalDataSynchronized => 'All local data synchronized';

  @override
  String lastUpdate(String time) {
    return 'LAST UPDATE: $time AGO';
  }

  @override
  String get activeOperations => 'ACTIVE OPERATIONS';

  @override
  String taskUnitsRemaining(int count) {
    return '$count Task Units';
  }

  @override
  String get remaining => 'Remaining';

  @override
  String get listTab => 'List';

  @override
  String get mapTab => 'Map';

  @override
  String get synced => 'SYNCED';

  @override
  String get failed => 'FAILED';

  @override
  String get pending => 'PENDING';

  @override
  String get inProgress => 'IN PROGRESS';

  @override
  String get retrySync => 'Retry Sync';

  @override
  String get continueTask => 'Continue Task';

  @override
  String get dailyVelocity => 'Daily Velocity';

  @override
  String get target => 'Target';

  @override
  String get achieved => 'Achieved';

  @override
  String systemHealthy(int minutes) {
    return 'System healthy. Next automated sync cycle in $minutes minutes.';
  }

  @override
  String get searchHint => 'Search tasks or locations...';

  @override
  String get serviceOrder => 'SERVICE ORDER';

  @override
  String get estimatedDist => 'ESTIMATED DIST.';

  @override
  String get timeWindowLabel => 'TIME WINDOW';

  @override
  String get priorityLabel => 'PRIORITY';

  @override
  String get route => 'Route';

  @override
  String get startFieldTask => 'Start Field Task';
}
