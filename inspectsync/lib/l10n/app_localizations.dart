import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'InspectSync'**
  String get appTitle;

  /// Greeting shown on the login screen
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// Subtitle encouraging user to login
  ///
  /// In en, this message translates to:
  /// **'Access your field operations dashboard'**
  String get loginSubtitle;

  /// Label for the email input field
  ///
  /// In en, this message translates to:
  /// **'EMAIL ADDRESS'**
  String get emailAddressLabel;

  /// Placeholder text for the email input field
  ///
  /// In en, this message translates to:
  /// **'name@company.com'**
  String get emailHint;

  /// Label for the password input field
  ///
  /// In en, this message translates to:
  /// **'PASSWORD'**
  String get passwordLabel;

  /// Placeholder for the password input field
  ///
  /// In en, this message translates to:
  /// **'••••••••'**
  String get passwordHint;

  /// Button text to trigger forgot password flow
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// Label for the remember me checkbox
  ///
  /// In en, this message translates to:
  /// **'Remember this device'**
  String get rememberDevice;

  /// Text inside the login button
  ///
  /// In en, this message translates to:
  /// **'Log In to Dashboard'**
  String get loginButton;

  /// Prompt for users without an account
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get dontHaveAccount;

  /// Button to contact admin for creating an account
  ///
  /// In en, this message translates to:
  /// **'Contact Admin'**
  String get contactAdmin;

  /// Indicator state showing that sync is active and encrypted
  ///
  /// In en, this message translates to:
  /// **'ENCRYPTED SYNC ACTIVE'**
  String get encryptedSyncActive;

  /// No description provided for @bottomNavDashboard.
  ///
  /// In en, this message translates to:
  /// **'DASHBOARD'**
  String get bottomNavDashboard;

  /// No description provided for @bottomNavMap.
  ///
  /// In en, this message translates to:
  /// **'MAP'**
  String get bottomNavMap;

  /// No description provided for @bottomNavTasks.
  ///
  /// In en, this message translates to:
  /// **'TASKS'**
  String get bottomNavTasks;

  /// No description provided for @bottomNavSync.
  ///
  /// In en, this message translates to:
  /// **'SYNC'**
  String get bottomNavSync;

  /// No description provided for @bottomNavSettings.
  ///
  /// In en, this message translates to:
  /// **'SETTINGS'**
  String get bottomNavSettings;

  /// No description provided for @precisionField.
  ///
  /// In en, this message translates to:
  /// **'Precision Field'**
  String get precisionField;

  /// No description provided for @allLocalDataSynchronized.
  ///
  /// In en, this message translates to:
  /// **'All local data synchronized'**
  String get allLocalDataSynchronized;

  /// No description provided for @lastUpdate.
  ///
  /// In en, this message translates to:
  /// **'LAST UPDATE: {time} AGO'**
  String lastUpdate(String time);

  /// No description provided for @activeOperations.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE OPERATIONS'**
  String get activeOperations;

  /// No description provided for @taskUnitsRemaining.
  ///
  /// In en, this message translates to:
  /// **'{count} Task Units'**
  String taskUnitsRemaining(int count);

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remaining;

  /// No description provided for @listTab.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get listTab;

  /// No description provided for @mapTab.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get mapTab;

  /// No description provided for @synced.
  ///
  /// In en, this message translates to:
  /// **'SYNCED'**
  String get synced;

  /// No description provided for @failed.
  ///
  /// In en, this message translates to:
  /// **'FAILED'**
  String get failed;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'PENDING'**
  String get pending;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'IN PROGRESS'**
  String get inProgress;

  /// No description provided for @retrySync.
  ///
  /// In en, this message translates to:
  /// **'Retry Sync'**
  String get retrySync;

  /// No description provided for @continueTask.
  ///
  /// In en, this message translates to:
  /// **'Continue Task'**
  String get continueTask;

  /// No description provided for @dailyVelocity.
  ///
  /// In en, this message translates to:
  /// **'Daily Velocity'**
  String get dailyVelocity;

  /// No description provided for @target.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get target;

  /// No description provided for @achieved.
  ///
  /// In en, this message translates to:
  /// **'Achieved'**
  String get achieved;

  /// No description provided for @systemHealthy.
  ///
  /// In en, this message translates to:
  /// **'System healthy. Next automated sync cycle in {minutes} minutes.'**
  String systemHealthy(int minutes);

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search tasks or locations...'**
  String get searchHint;

  /// No description provided for @serviceOrder.
  ///
  /// In en, this message translates to:
  /// **'SERVICE ORDER'**
  String get serviceOrder;

  /// No description provided for @estimatedDist.
  ///
  /// In en, this message translates to:
  /// **'ESTIMATED DIST.'**
  String get estimatedDist;

  /// No description provided for @timeWindowLabel.
  ///
  /// In en, this message translates to:
  /// **'TIME WINDOW'**
  String get timeWindowLabel;

  /// No description provided for @priorityLabel.
  ///
  /// In en, this message translates to:
  /// **'PRIORITY'**
  String get priorityLabel;

  /// No description provided for @route.
  ///
  /// In en, this message translates to:
  /// **'Route'**
  String get route;

  /// No description provided for @startFieldTask.
  ///
  /// In en, this message translates to:
  /// **'Start Field Task'**
  String get startFieldTask;

  /// No description provided for @assignmentStatus.
  ///
  /// In en, this message translates to:
  /// **'Assignment Status'**
  String get assignmentStatus;

  /// No description provided for @noTasksAssigned.
  ///
  /// In en, this message translates to:
  /// **'No tasks assigned'**
  String get noTasksAssigned;

  /// No description provided for @fieldQueueEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your field queue is currently empty. Contact your supervisor or wait for the next scheduled dispatch.'**
  String get fieldQueueEmpty;

  /// No description provided for @refreshTasks.
  ///
  /// In en, this message translates to:
  /// **'Refresh Tasks'**
  String get refreshTasks;

  /// No description provided for @queueCleared.
  ///
  /// In en, this message translates to:
  /// **'Queue Cleared'**
  String get queueCleared;

  /// No description provided for @lastCheck.
  ///
  /// In en, this message translates to:
  /// **'Last check: {time} ago'**
  String lastCheck(String time);

  /// No description provided for @queueClearedDesc.
  ///
  /// In en, this message translates to:
  /// **'All previous assignments were successfully completed.'**
  String get queueClearedDesc;

  /// No description provided for @nextUpdate.
  ///
  /// In en, this message translates to:
  /// **'Next Update'**
  String get nextUpdate;

  /// No description provided for @nextUpdateDesc.
  ///
  /// In en, this message translates to:
  /// **'Automatic sync scheduled for {time} PM local time.'**
  String nextUpdateDesc(String time);

  /// No description provided for @noInternet.
  ///
  /// In en, this message translates to:
  /// **'Offline Mode — All changes will sync later'**
  String get noInternet;

  /// No description provided for @offlineDesc.
  ///
  /// In en, this message translates to:
  /// **'You\'re currently offline. Field Precision will continue to cache your data locally until a connection is restored.'**
  String get offlineDesc;

  /// No description provided for @retryConnection.
  ///
  /// In en, this message translates to:
  /// **'Retry Connection'**
  String get retryConnection;

  /// No description provided for @workOffline.
  ///
  /// In en, this message translates to:
  /// **'Work Offline'**
  String get workOffline;

  /// No description provided for @offlineModeEnabled.
  ///
  /// In en, this message translates to:
  /// **'Offline Mode Enabled'**
  String get offlineModeEnabled;

  /// No description provided for @localCacheActive.
  ///
  /// In en, this message translates to:
  /// **'LOCAL CACHE ACTIVE'**
  String get localCacheActive;

  /// No description provided for @syncFailed.
  ///
  /// In en, this message translates to:
  /// **'Sync failed'**
  String get syncFailed;

  /// No description provided for @syncConflictDesc.
  ///
  /// In en, this message translates to:
  /// **'We encountered a conflict while uploading your field data to the primary server. Some records require manual review.'**
  String get syncConflictDesc;

  /// No description provided for @errorDetails.
  ///
  /// In en, this message translates to:
  /// **'ERROR DETAILS'**
  String get errorDetails;

  /// No description provided for @statusCode.
  ///
  /// In en, this message translates to:
  /// **'Status Code'**
  String get statusCode;

  /// No description provided for @timestamp.
  ///
  /// In en, this message translates to:
  /// **'Timestamp'**
  String get timestamp;

  /// No description provided for @reason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get reason;

  /// No description provided for @viewConflicts.
  ///
  /// In en, this message translates to:
  /// **'View Conflicts'**
  String get viewConflicts;

  /// No description provided for @taskDetails.
  ///
  /// In en, this message translates to:
  /// **'Task Details'**
  String get taskDetails;

  /// No description provided for @allChangesCached.
  ///
  /// In en, this message translates to:
  /// **'ALL CHANGES CACHED LOCALLY'**
  String get allChangesCached;

  /// No description provided for @projectIdLabel.
  ///
  /// In en, this message translates to:
  /// **'PROJECT ID: {id}'**
  String projectIdLabel(String id);

  /// No description provided for @siteLocation.
  ///
  /// In en, this message translates to:
  /// **'Site Location: {location}'**
  String siteLocation(String location);

  /// No description provided for @technicalChecklist.
  ///
  /// In en, this message translates to:
  /// **'Technical Checklist'**
  String get technicalChecklist;

  /// No description provided for @fieldDocumentation.
  ///
  /// In en, this message translates to:
  /// **'Field Documentation'**
  String get fieldDocumentation;

  /// No description provided for @fieldNotes.
  ///
  /// In en, this message translates to:
  /// **'Field Notes'**
  String get fieldNotes;

  /// No description provided for @notesHint.
  ///
  /// In en, this message translates to:
  /// **'Describe any anomalies or specific adjustments made during the inspection...'**
  String get notesHint;

  /// No description provided for @dictate.
  ///
  /// In en, this message translates to:
  /// **'DICTATE'**
  String get dictate;

  /// No description provided for @addPhoto.
  ///
  /// In en, this message translates to:
  /// **'ADD PHOTO'**
  String get addPhoto;

  /// No description provided for @attachEvidence.
  ///
  /// In en, this message translates to:
  /// **'Attach high-resolution evidence of the installation state and completed repairs.'**
  String get attachEvidence;

  /// No description provided for @timeOnSite.
  ///
  /// In en, this message translates to:
  /// **'TIME ON SITE'**
  String get timeOnSite;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'PROGRESS'**
  String get progress;

  /// No description provided for @saveSyncTask.
  ///
  /// In en, this message translates to:
  /// **'SAVE & SYNC TASK'**
  String get saveSyncTask;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
