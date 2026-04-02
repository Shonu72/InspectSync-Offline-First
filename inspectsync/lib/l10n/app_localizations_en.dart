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
  String get bottomNavSync => 'SYNC';

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

  @override
  String get assignmentStatus => 'Assignment Status';

  @override
  String get noTasksAssigned => 'No tasks assigned';

  @override
  String get fieldQueueEmpty =>
      'Your field queue is currently empty. Contact your supervisor or wait for the next scheduled dispatch.';

  @override
  String get refreshTasks => 'Refresh Tasks';

  @override
  String get queueCleared => 'Queue Cleared';

  @override
  String lastCheck(String time) {
    return 'Last check: $time ago';
  }

  @override
  String get queueClearedDesc =>
      'All previous assignments were successfully completed.';

  @override
  String get nextUpdate => 'Next Update';

  @override
  String nextUpdateDesc(String time) {
    return 'Automatic sync scheduled for $time PM local time.';
  }

  @override
  String get noInternet => 'No internet connection';

  @override
  String get offlineDesc =>
      'You\'re currently offline. Field Precision will continue to cache your data locally until a connection is restored.';

  @override
  String get retryConnection => 'Retry Connection';

  @override
  String get workOffline => 'Work Offline';

  @override
  String get offlineModeEnabled => 'Offline Mode Enabled';

  @override
  String get localCacheActive => 'LOCAL CACHE ACTIVE';

  @override
  String get syncFailed => 'Sync failed';

  @override
  String get syncConflictDesc =>
      'We encountered a conflict while uploading your field data to the primary server. Some records require manual review.';

  @override
  String get errorDetails => 'ERROR DETAILS';

  @override
  String get statusCode => 'Status Code';

  @override
  String get timestamp => 'Timestamp';

  @override
  String get reason => 'Reason';

  @override
  String get viewConflicts => 'View Conflicts';

  @override
  String get taskDetails => 'Task Details';

  @override
  String get allChangesCached => 'ALL CHANGES CACHED LOCALLY';

  @override
  String projectIdLabel(String id) {
    return 'PROJECT ID: $id';
  }

  @override
  String siteLocation(String location) {
    return 'Site Location: $location';
  }

  @override
  String get technicalChecklist => 'Technical Checklist';

  @override
  String get fieldDocumentation => 'Field Documentation';

  @override
  String get fieldNotes => 'Field Notes';

  @override
  String get notesHint =>
      'Describe any anomalies or specific adjustments made during the inspection...';

  @override
  String get dictate => 'DICTATE';

  @override
  String get addPhoto => 'ADD PHOTO';

  @override
  String get attachEvidence =>
      'Attach high-resolution evidence of the installation state and completed repairs.';

  @override
  String get timeOnSite => 'TIME ON SITE';

  @override
  String get progress => 'PROGRESS';

  @override
  String get saveSyncTask => 'SAVE & SYNC TASK';
}
