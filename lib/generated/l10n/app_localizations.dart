import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_uk.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('uk'),
  ];

  /// Application title
  ///
  /// In en, this message translates to:
  /// **'PartyBar'**
  String get appTitle;

  /// Home navigation item
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navigationHome;

  /// Explore navigation item
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get navigationExplore;

  /// Party navigation item
  ///
  /// In en, this message translates to:
  /// **'Party'**
  String get navigationParty;

  /// Flow 04 - My bar. Bottom nav label for the My bar tab
  ///
  /// In en, this message translates to:
  /// **'My bar'**
  String get navigationMyBar;

  /// Settings navigation item
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navigationSettings;

  /// Profile navigation item
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navigationProfile;

  /// Language setting label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Skip button text
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// Button to start using the app
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// Next button
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Previous button
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// First onboarding screen title
  ///
  /// In en, this message translates to:
  /// **'Discover Amazing Cocktails'**
  String get onboardingTitle1;

  /// First onboarding screen description
  ///
  /// In en, this message translates to:
  /// **'Browse through hundreds of cocktail recipes with detailed instructions and ingredients.'**
  String get onboardingDescription1;

  /// Second onboarding screen title
  ///
  /// In en, this message translates to:
  /// **'Join Party Events'**
  String get onboardingTitle2;

  /// Second onboarding screen description
  ///
  /// In en, this message translates to:
  /// **'Enter party codes to join events and order cocktails directly from the host.'**
  String get onboardingDescription2;

  /// Third onboarding screen title
  ///
  /// In en, this message translates to:
  /// **'Create Your Own Parties'**
  String get onboardingTitle3;

  /// Third onboarding screen description
  ///
  /// In en, this message translates to:
  /// **'Host your own cocktail parties and manage orders from your guests.'**
  String get onboardingDescription3;

  /// Fourth onboarding screen title
  ///
  /// In en, this message translates to:
  /// **'Build Your Collection'**
  String get onboardingTitle4;

  /// Fourth onboarding screen description
  ///
  /// In en, this message translates to:
  /// **'Create personal cocktail bars and save your favorite recipes.'**
  String get onboardingDescription4;

  /// Loading indicator text
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Profile screen title
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Settings screen title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Authentication screen title
  ///
  /// In en, this message translates to:
  /// **'Authentication'**
  String get authentication;

  /// Ingredients section header
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get ingredients;

  /// Equipment section header
  ///
  /// In en, this message translates to:
  /// **'Equipment'**
  String get equipment;

  /// Preparation steps section header
  ///
  /// In en, this message translates to:
  /// **'Preparation Steps'**
  String get preparationSteps;

  /// Categories section header
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// Page indicator
  ///
  /// In en, this message translates to:
  /// **'{current} of {total}'**
  String pageOfPages(int current, int total);

  /// Explore screen title
  ///
  /// In en, this message translates to:
  /// **'Explore Cocktails'**
  String get exploreCocktails;

  /// Bottom sheet title to filter cocktails
  ///
  /// In en, this message translates to:
  /// **'Filter Cocktails'**
  String get filterCocktails;

  /// Button text to apply selected filters
  ///
  /// In en, this message translates to:
  /// **'Apply filters'**
  String get filtersApply;

  /// Button text to clear selected filters
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get filtersClear;

  /// Hint text in the search field
  ///
  /// In en, this message translates to:
  /// **'Search cocktails...'**
  String get searchCocktailsHint;

  /// Button to clear all active filters
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// Number of cocktails in search results
  ///
  /// In en, this message translates to:
  /// **'{count} cocktails found'**
  String cocktailsFound(int count);

  /// Empty state title when no cocktails match the search
  ///
  /// In en, this message translates to:
  /// **'No cocktails found'**
  String get noCocktailsFound;

  /// Empty state subtitle suggesting to modify filters
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search or filters'**
  String get tryAdjustingFilters;

  /// Button to clear filters in empty state
  ///
  /// In en, this message translates to:
  /// **'Clear Filters'**
  String get clearFilters;

  /// Error state title
  ///
  /// In en, this message translates to:
  /// **'Error Loading Cocktails'**
  String get errorLoadingCocktails;

  /// Fallback error message
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get unknownError;

  /// Button to retry a failed operation
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Error message when refresh fails
  ///
  /// In en, this message translates to:
  /// **'Failed to refresh: {error}'**
  String failedToRefresh(String error);

  /// Login button text
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get login;

  /// Logout button text
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Success message after logout
  ///
  /// In en, this message translates to:
  /// **'Successfully logged out'**
  String get logoutSuccess;

  /// Error message when logout fails
  ///
  /// In en, this message translates to:
  /// **'Failed to logout. Please try again.'**
  String get logoutError;

  /// Sign in tab and button text
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// Sign up tab and button text
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// Success message after sign in
  ///
  /// In en, this message translates to:
  /// **'Successfully signed in'**
  String get signInSuccess;

  /// Success message after sign up
  ///
  /// In en, this message translates to:
  /// **'Account created successfully'**
  String get signUpSuccess;

  /// Email field hint
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get emailHint;

  /// Email validation error
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// Email validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get emailInvalid;

  /// Password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Password field hint
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get passwordHint;

  /// Password validation error
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// Password validation error
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShort;

  /// Confirm password field label
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// Confirm password field hint
  ///
  /// In en, this message translates to:
  /// **'Re-enter your password'**
  String get confirmPasswordHint;

  /// Confirm password validation error
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get confirmPasswordRequired;

  /// Password match validation error
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// Sign up page title
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// Sign in page title
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// Sign up page subtitle
  ///
  /// In en, this message translates to:
  /// **'Create a new account to get started'**
  String get signUpSubtitle;

  /// Sign in page subtitle
  ///
  /// In en, this message translates to:
  /// **'Sign in to your account'**
  String get signInSubtitle;

  /// Divider text for social login
  ///
  /// In en, this message translates to:
  /// **'Or continue with'**
  String get orContinueWith;

  /// Google sign in button text
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// Title for authentication barrier screen
  ///
  /// In en, this message translates to:
  /// **'Authentication Required'**
  String get authenticationRequired;

  /// Message explaining authentication requirement
  ///
  /// In en, this message translates to:
  /// **'This feature is available only for authenticated users. Please sign in to continue.'**
  String get authenticationRequiredMessage;

  /// Button text to navigate to login
  ///
  /// In en, this message translates to:
  /// **'Sign In to Continue'**
  String get signInToContinue;

  /// Party Hub screen title
  ///
  /// In en, this message translates to:
  /// **'Party Hub'**
  String get partyHub;

  /// Welcome message on Party Hub screen
  ///
  /// In en, this message translates to:
  /// **'Welcome to PartyBar!'**
  String get welcomeToPartyBar;

  /// Subtitle on Party Hub screen
  ///
  /// In en, this message translates to:
  /// **'Join a party or create your own cocktail experience'**
  String get joinOrCreateParty;

  /// Join party button title
  ///
  /// In en, this message translates to:
  /// **'Join Party'**
  String get joinParty;

  /// Join party button subtitle
  ///
  /// In en, this message translates to:
  /// **'Enter a party code to join the fun'**
  String get joinPartySubtitle;

  /// Create party button title
  ///
  /// In en, this message translates to:
  /// **'Create Party'**
  String get createParty;

  /// Create party button subtitle
  ///
  /// In en, this message translates to:
  /// **'Host your own cocktail party'**
  String get createPartySubtitle;

  /// Quick info message about party features
  ///
  /// In en, this message translates to:
  /// **'Hosts can manage orders and guests can browse cocktails in real-time!'**
  String get partyQuickInfo;

  /// Create party screen title
  ///
  /// In en, this message translates to:
  /// **'Create Party'**
  String get createPartyTitle;

  /// Create party screen header title
  ///
  /// In en, this message translates to:
  /// **'Create Your Party'**
  String get createYourParty;

  /// Create party screen header description
  ///
  /// In en, this message translates to:
  /// **'Set up your cocktail party and invite guests'**
  String get createPartyDescription;

  /// Party details section header
  ///
  /// In en, this message translates to:
  /// **'Party Details'**
  String get partyDetails;

  /// Party name input field label
  ///
  /// In en, this message translates to:
  /// **'Party Name *'**
  String get partyNameLabel;

  /// Party name input field hint
  ///
  /// In en, this message translates to:
  /// **'e.g., Sarah\'s Birthday Bash'**
  String get partyNameHint;

  /// Party description input field label
  ///
  /// In en, this message translates to:
  /// **'Description (Optional)'**
  String get partyDescriptionLabel;

  /// Party description input field hint
  ///
  /// In en, this message translates to:
  /// **'Tell guests about your party...'**
  String get partyDescriptionHint;

  /// Cocktails selection section header
  ///
  /// In en, this message translates to:
  /// **'Select Available Cocktails *'**
  String get selectAvailableCocktails;

  /// Number of selected cocktails
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String selectedCount(int count);

  /// Quick select button for classic cocktails
  ///
  /// In en, this message translates to:
  /// **'All Classic'**
  String get allClassic;

  /// Quick select button for tiki and frozen cocktails
  ///
  /// In en, this message translates to:
  /// **'Tiki & Frozen'**
  String get tikiAndFrozen;

  /// Create party button text
  ///
  /// In en, this message translates to:
  /// **'Create Party'**
  String get createPartyButton;

  /// Validation error for empty party name
  ///
  /// In en, this message translates to:
  /// **'Please enter a party name'**
  String get pleaseEnterPartyName;

  /// Validation error for no cocktails selected
  ///
  /// In en, this message translates to:
  /// **'Please select at least one cocktail'**
  String get pleaseSelectCocktail;

  /// Generic cocktail label
  ///
  /// In en, this message translates to:
  /// **'Cocktail'**
  String get cocktail;

  /// Label for party invitation code
  ///
  /// In en, this message translates to:
  /// **'Invitation Code'**
  String get invitationCode;

  /// Button to share invitation code
  ///
  /// In en, this message translates to:
  /// **'Share Code'**
  String get shareCode;

  /// Button to copy invitation code
  ///
  /// In en, this message translates to:
  /// **'Copy Code'**
  String get copyCode;

  /// Confirmation message after copying code
  ///
  /// In en, this message translates to:
  /// **'Code copied to clipboard!'**
  String get codeCopied;

  /// Header for party cocktails list
  ///
  /// In en, this message translates to:
  /// **'Party Cocktails'**
  String get partyCocktails;

  /// Button to add new cocktails to party
  ///
  /// In en, this message translates to:
  /// **'Add Cocktails'**
  String get addCocktails;

  /// Button to remove cocktail from party
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeCocktail;

  /// Empty state message for cocktail list
  ///
  /// In en, this message translates to:
  /// **'No cocktails added yet'**
  String get noCocktailsAdded;

  /// Button to edit party information
  ///
  /// In en, this message translates to:
  /// **'Edit Party Info'**
  String get editPartyInfo;

  /// Button to save changes
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// Cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Label for party status section
  ///
  /// In en, this message translates to:
  /// **'Party Status'**
  String get partyStatus;

  /// Button to start the party
  ///
  /// In en, this message translates to:
  /// **'Start Party'**
  String get startParty;

  /// Button to pause the party
  ///
  /// In en, this message translates to:
  /// **'Pause Party'**
  String get pauseParty;

  /// Button to resume the party
  ///
  /// In en, this message translates to:
  /// **'Resume Party'**
  String get resumeParty;

  /// Button to end the party
  ///
  /// In en, this message translates to:
  /// **'End Party'**
  String get endParty;

  /// Status label for active party
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get partyActive;

  /// Status label for paused party
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get partyPaused;

  /// Status label for ended party
  ///
  /// In en, this message translates to:
  /// **'Ended'**
  String get partyEnded;

  /// Status label for idle party
  ///
  /// In en, this message translates to:
  /// **'Not started'**
  String get partyIdle;

  /// Confirmation dialog for ending party
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to end the party?'**
  String get confirmEndParty;

  /// Confirmation dialog message for ending party
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone. All party data will be archived.'**
  String get confirmEndPartyMessage;

  /// Button to navigate to host dashboard for active party
  ///
  /// In en, this message translates to:
  /// **'Go to Host Dashboard'**
  String get goToHostDashboard;

  /// Button to navigate to party menu for guests
  ///
  /// In en, this message translates to:
  /// **'Go to Party Menu'**
  String get goToPartyMenu;

  /// Header for party admin panel
  ///
  /// In en, this message translates to:
  /// **'Party Admin'**
  String get partyAdminPanel;

  /// Title for hosted parties bottom sheet
  ///
  /// In en, this message translates to:
  /// **'My Hosted Parties'**
  String get myHostedParties;

  /// Button text to view hosted parties
  ///
  /// In en, this message translates to:
  /// **'View My Parties'**
  String get viewMyParties;

  /// Message when user has no hosted parties
  ///
  /// In en, this message translates to:
  /// **'You haven\'t hosted any parties yet'**
  String get noHostedParties;

  /// Encouragement message to create first party
  ///
  /// In en, this message translates to:
  /// **'Create your first party to get started!'**
  String get createFirstParty;

  /// Button text to view party details
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// Message showing number of selected cocktails
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 cocktail selected} other{{count} cocktails selected}}'**
  String cocktailsSelected(int count);

  /// Button text when no cocktails are selected
  ///
  /// In en, this message translates to:
  /// **'Select Cocktails'**
  String get selectCocktails;

  /// Button text to confirm adding selected cocktails
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Save 1 Cocktail} other{Save {count} Cocktails}}'**
  String addSelectedCocktails(int count);

  /// Message when user tries to add cocktails that are already in the party
  ///
  /// In en, this message translates to:
  /// **'All selected cocktails are already added'**
  String get cocktailsAlreadyAdded;

  /// Success message after adding cocktails
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 cocktail added successfully} other{{count} cocktails added successfully}}'**
  String cocktailsAddedSuccess(int count);

  /// Error message when adding cocktails fails
  ///
  /// In en, this message translates to:
  /// **'Failed to add cocktails: {error}'**
  String failedToAddCocktails(String error);

  /// Empty state title when there are no pending orders
  ///
  /// In en, this message translates to:
  /// **'No pending orders'**
  String get noPendingOrders;

  /// Empty state message for orders placeholder
  ///
  /// In en, this message translates to:
  /// **'Orders will appear here as guests place them'**
  String get ordersWillAppear;

  /// Fallback text when cocktail name is not found
  ///
  /// In en, this message translates to:
  /// **'Unknown Cocktail'**
  String get unknownCocktail;

  /// Label showing which guest the order is for
  ///
  /// In en, this message translates to:
  /// **'For: {guestName}'**
  String forGuest(String guestName);

  /// Label showing when the order was placed
  ///
  /// In en, this message translates to:
  /// **'Ordered: {time}'**
  String ordered(String time);

  /// Time indicator for very recent actions
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// Time indicator for minutes ago
  ///
  /// In en, this message translates to:
  /// **'{minutes}m ago'**
  String minutesAgo(int minutes);

  /// Time indicator for hours ago
  ///
  /// In en, this message translates to:
  /// **'{hours}h ago'**
  String hoursAgo(int hours);

  /// Button to start preparing an order
  ///
  /// In en, this message translates to:
  /// **'Start Preparing'**
  String get startPreparing;

  /// Button to mark order as ready for pickup
  ///
  /// In en, this message translates to:
  /// **'Mark Ready'**
  String get markReady;

  /// Button to mark order as delivered
  ///
  /// In en, this message translates to:
  /// **'Mark Delivered'**
  String get markDelivered;

  /// Section title for new/pending orders
  ///
  /// In en, this message translates to:
  /// **'New Orders'**
  String get newOrders;

  /// Section title for orders being prepared
  ///
  /// In en, this message translates to:
  /// **'Preparing'**
  String get preparing;

  /// Section title for orders ready for pickup
  ///
  /// In en, this message translates to:
  /// **'Ready for Pickup'**
  String get readyForPickup;

  /// Orders tab label
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders;

  /// Orders tab label with count
  ///
  /// In en, this message translates to:
  /// **'Orders ({count})'**
  String ordersCount(int count);

  /// Stats tab label
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get stats;

  /// Menu tab label
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// Label for total orders statistic
  ///
  /// In en, this message translates to:
  /// **'Total Orders'**
  String get totalOrders;

  /// Label for completed orders statistic
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// Label for pending orders statistic
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// Label for party active time statistic
  ///
  /// In en, this message translates to:
  /// **'Active Time'**
  String get activeTime;

  /// Title for party statistics overview section
  ///
  /// In en, this message translates to:
  /// **'Party Overview'**
  String get partyOverview;

  /// Title for popular cocktails section
  ///
  /// In en, this message translates to:
  /// **'Popular Cocktails'**
  String get popularCocktails;

  /// Message when there are no orders in statistics
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get noOrdersYet;

  /// Title for available cocktails list with count
  ///
  /// In en, this message translates to:
  /// **'Available Cocktails ({count})'**
  String availableCocktails(int count);

  /// Empty state title when no cocktails are available
  ///
  /// In en, this message translates to:
  /// **'No cocktails available'**
  String get noCocktailsAvailable;

  /// Empty state message suggesting to add cocktails
  ///
  /// In en, this message translates to:
  /// **'Add cocktails to the party menu'**
  String get addCocktailsToMenu;

  /// Error message when cocktails fail to load
  ///
  /// In en, this message translates to:
  /// **'Error loading cocktails'**
  String get errorLoadingCocktailsList;

  /// Success message when party code is copied
  ///
  /// In en, this message translates to:
  /// **'Party code copied to clipboard!'**
  String get partyCopiedToClipboard;

  /// Title for QR code dialog
  ///
  /// In en, this message translates to:
  /// **'Party QR Code'**
  String get partyQRCode;

  /// Mock placeholder for QR code
  ///
  /// In en, this message translates to:
  /// **'QR CODE\n(Mock)'**
  String get qrCodeMock;

  /// Label showing party code
  ///
  /// In en, this message translates to:
  /// **'Code: {code}'**
  String code(String code);

  /// Close button text
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Success message when party is resumed
  ///
  /// In en, this message translates to:
  /// **'Party resumed'**
  String get partyResumed;

  /// Success message when party is paused
  ///
  /// In en, this message translates to:
  /// **'Party paused'**
  String get partyPausedMessage;

  /// Error message when order update fails
  ///
  /// In en, this message translates to:
  /// **'Failed to update order: {error}'**
  String failedToUpdateOrder(String error);

  /// Error message when party status update fails
  ///
  /// In en, this message translates to:
  /// **'Failed to update party status: {error}'**
  String failedToUpdatePartyStatus(String error);

  /// Success message when order status is updated
  ///
  /// In en, this message translates to:
  /// **'{cocktail} for {guest} marked as {status}'**
  String orderMarkedAs(String cocktail, String guest, String status);

  /// Generic error message with details
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String errorWithMessage(String message);

  /// Join party screen title
  ///
  /// In en, this message translates to:
  /// **'Join Party'**
  String get joinPartyTitle;

  /// Join party screen header title
  ///
  /// In en, this message translates to:
  /// **'Join the Party!'**
  String get joinTheParty;

  /// Join party screen header description
  ///
  /// In en, this message translates to:
  /// **'Enter the party code to start ordering cocktails'**
  String get enterPartyCodeToOrder;

  /// Guest name input field label
  ///
  /// In en, this message translates to:
  /// **'Your Name'**
  String get yourName;

  /// Guest name input field hint
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get enterYourName;

  /// Party code input field label
  ///
  /// In en, this message translates to:
  /// **'Party Code'**
  String get partyCode;

  /// Party code input field hint
  ///
  /// In en, this message translates to:
  /// **'Enter 6-digit party code'**
  String get enterPartyCode;

  /// Button to scan QR code
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code'**
  String get scanQRCode;

  /// Success message after scanning QR code
  ///
  /// In en, this message translates to:
  /// **'QR Code scanned successfully!'**
  String get qrCodeScannedSuccess;

  /// Validation error for missing name or code
  ///
  /// In en, this message translates to:
  /// **'Please enter both party code and your name'**
  String get pleaseEnterNameAndCode;

  /// Help text explaining how to get party code
  ///
  /// In en, this message translates to:
  /// **'Ask the party host for the 6-digit party code or scan their QR code'**
  String get askHostForCode;

  /// Error message when party doesn't exist
  ///
  /// In en, this message translates to:
  /// **'Party not found. Please check the code and try again.'**
  String get partyNotFound;

  /// Loading message while joining party
  ///
  /// In en, this message translates to:
  /// **'Joining party...'**
  String get joiningParty;

  /// Button to order a cocktail
  ///
  /// In en, this message translates to:
  /// **'Order Cocktail'**
  String get orderCocktail;

  /// Label for special requests field
  ///
  /// In en, this message translates to:
  /// **'Special Requests'**
  String get specialRequests;

  /// Hint text for special requests field
  ///
  /// In en, this message translates to:
  /// **'e.g., extra lime, no sugar...'**
  String get specialRequestsHint;

  /// Indicator that a field is optional
  ///
  /// In en, this message translates to:
  /// **'(optional)'**
  String get optional;

  /// Order confirmation dialog title
  ///
  /// In en, this message translates to:
  /// **'Order {cocktailName}'**
  String orderConfirmation(String cocktailName);

  /// Order confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to order {cocktailName}?'**
  String orderConfirmMessage(String cocktailName);

  /// Success message after ordering a cocktail
  ///
  /// In en, this message translates to:
  /// **'{cocktailName} ordered successfully!'**
  String cocktailOrderedSuccess(String cocktailName);

  /// Error message when ordering fails
  ///
  /// In en, this message translates to:
  /// **'Failed to order cocktail: {error}'**
  String failedToOrderCocktail(String error);

  /// Title for guest's personal orders section
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get myOrders;

  /// Title for guest's personal statistics
  ///
  /// In en, this message translates to:
  /// **'My Stats'**
  String get myStats;

  /// Label for number of orders placed by guest
  ///
  /// In en, this message translates to:
  /// **'Orders Placed'**
  String get ordersPlaced;

  /// Label for number of different cocktails tried
  ///
  /// In en, this message translates to:
  /// **'Cocktails Tried'**
  String get cocktailsTried;

  /// Label for guest's most ordered cocktail
  ///
  /// In en, this message translates to:
  /// **'Favorite Cocktail'**
  String get favoriteCocktail;

  /// Message when guest hasn't ordered anything
  ///
  /// In en, this message translates to:
  /// **'No favorite yet'**
  String get noFavoriteYet;

  /// Empty state message for guest with no orders
  ///
  /// In en, this message translates to:
  /// **'You haven\'t ordered any cocktails yet'**
  String get youHaventOrderedYet;

  /// Encouragement message to order cocktails
  ///
  /// In en, this message translates to:
  /// **'Start ordering from the menu!'**
  String get startOrderingFromMenu;

  /// Label for cocktails the guest has already ordered
  ///
  /// In en, this message translates to:
  /// **'Already tried'**
  String get alreadyTried;

  /// Welcome message for guest
  ///
  /// In en, this message translates to:
  /// **'Welcome, {name}!'**
  String welcome(String name);

  /// Button to view cocktail recipe
  ///
  /// In en, this message translates to:
  /// **'View Recipe'**
  String get viewRecipe;

  /// Button to order a cocktail
  ///
  /// In en, this message translates to:
  /// **'Order Now'**
  String get orderNow;

  /// Defer action in the top-right of onboarding step 05
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// Advance button on the vibe picker
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// Two-line tagline under the wordmark on the splash
  ///
  /// In en, this message translates to:
  /// **'Your shelf. Their orders.\nOne bar, all night.'**
  String get splashTagline;

  /// Overline on onboarding step 02
  ///
  /// In en, this message translates to:
  /// **'What you own'**
  String get onboardingBarEyebrow;

  /// Headline on onboarding step 02
  ///
  /// In en, this message translates to:
  /// **'Your shelf\nbecomes a menu'**
  String get onboardingBarTitle;

  /// Body copy on onboarding step 02
  ///
  /// In en, this message translates to:
  /// **'Tell PartyBar which bottles you have. It works out every cocktail you can already pour — and the one lime that unlocks eleven more.'**
  String get onboardingBarBody;

  /// Example shelf contents row on onboarding step 02
  ///
  /// In en, this message translates to:
  /// **'Gin, vodka, tonic'**
  String get onboardingBarStatShelf;

  /// Example pourable-drinks row on onboarding step 02
  ///
  /// In en, this message translates to:
  /// **'You can pour'**
  String get onboardingBarStatPourable;

  /// Example unlock suggestion row on onboarding step 02
  ///
  /// In en, this message translates to:
  /// **'Add one lime'**
  String get onboardingBarStatUnlock;

  /// Overline on onboarding step 03
  ///
  /// In en, this message translates to:
  /// **'What they do'**
  String get onboardingOrdersEyebrow;

  /// Headline on onboarding step 03
  ///
  /// In en, this message translates to:
  /// **'They order.\nYou get a queue.'**
  String get onboardingOrdersTitle;

  /// Body copy on onboarding step 03
  ///
  /// In en, this message translates to:
  /// **'Guests scan a code and order from their own phone. No app, no account. You just work down the list.'**
  String get onboardingOrdersBody;

  /// Advance button on onboarding step 03
  ///
  /// In en, this message translates to:
  /// **'Set up my bar'**
  String get onboardingOrdersCta;

  /// Sample cocktail name in the onboarding order illustration
  ///
  /// In en, this message translates to:
  /// **'Gin & Tonic'**
  String get onboardingSampleGinTonic;

  /// Sample cocktail name in the onboarding order illustration
  ///
  /// In en, this message translates to:
  /// **'Cosmopolitan'**
  String get onboardingSampleCosmopolitan;

  /// Sample guest and note in the onboarding order illustration
  ///
  /// In en, this message translates to:
  /// **'Marta · heavy on the lime'**
  String get onboardingSampleOrderNote;

  /// Sample guest and wait time in the onboarding order illustration
  ///
  /// In en, this message translates to:
  /// **'Danylo · waiting 2 min'**
  String get onboardingSampleOrderWaiting;

  /// Status chip on a newly placed order
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get orderStatusNew;

  /// Status chip on an order waiting its turn
  ///
  /// In en, this message translates to:
  /// **'Queued'**
  String get orderStatusQueued;

  /// Headline on onboarding step 04
  ///
  /// In en, this message translates to:
  /// **'What do you\ndrink like?'**
  String get onboardingVibeTitle;

  /// Body copy on onboarding step 04
  ///
  /// In en, this message translates to:
  /// **'Pick two or three. It only sorts your feed — nothing gets hidden.'**
  String get onboardingVibeBody;

  /// Flavour direction: bright, sour, citrus-forward drinks
  ///
  /// In en, this message translates to:
  /// **'Sharp & citrus'**
  String get vibeSharpCitrus;

  /// Flavour direction: spirit-forward stirred drinks
  ///
  /// In en, this message translates to:
  /// **'Dark & stirred'**
  String get vibeDarkStirred;

  /// Flavour direction: tall carbonated drinks
  ///
  /// In en, this message translates to:
  /// **'Long & fizzy'**
  String get vibeLongFizzy;

  /// Flavour direction: drinks with heat
  ///
  /// In en, this message translates to:
  /// **'Spicy'**
  String get vibeSpicy;

  /// Flavour direction: drinks without alcohol
  ///
  /// In en, this message translates to:
  /// **'Zero proof'**
  String get vibeZeroProof;

  /// Flavour direction: short, simple recipes
  ///
  /// In en, this message translates to:
  /// **'Three ingredients max'**
  String get vibeThreeIngredients;

  /// Headline on onboarding step 05
  ///
  /// In en, this message translates to:
  /// **'Five bottles\nand you\'re open'**
  String get onboardingBottlesTitle;

  /// Body copy on onboarding step 05
  ///
  /// In en, this message translates to:
  /// **'Tap what\'s actually on your shelf. Everything else can wait.'**
  String get onboardingBottlesBody;

  /// Placeholder in the bottle search field
  ///
  /// In en, this message translates to:
  /// **'Search bottles & mixers'**
  String get onboardingBottlesSearchHint;

  /// Section label above the suggested starter bottles
  ///
  /// In en, this message translates to:
  /// **'Most home bars have these'**
  String get onboardingBottlesSection;

  /// Empty state when a bottle search returns nothing
  ///
  /// In en, this message translates to:
  /// **'Nothing matched that search.'**
  String get onboardingBottlesNoMatch;

  /// Button that finishes onboarding and opens Explore
  ///
  /// In en, this message translates to:
  /// **'Open my bar'**
  String get onboardingOpenBar;

  /// How many cocktails a bottle appears in
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{in {count} cocktail} other{in {count} cocktails}}'**
  String bottleInCocktails(int count);

  /// How many extra drinks a bottle would unlock
  ///
  /// In en, this message translates to:
  /// **'unlocks {count} more'**
  String bottleUnlocksMore(int count);

  /// Progress towards the starter shelf target
  ///
  /// In en, this message translates to:
  /// **'{count} of {total} added'**
  String onboardingBottlesAdded(int count, int total);

  /// Drinks the current shelf can already make
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} drink unlocked} other{{count} drinks unlocked}}'**
  String onboardingDrinksUnlocked(int count);

  /// Starter bottle name in the onboarding shelf picker
  ///
  /// In en, this message translates to:
  /// **'Gin'**
  String get bottleGin;

  /// Starter bottle name in the onboarding shelf picker
  ///
  /// In en, this message translates to:
  /// **'Vodka'**
  String get bottleVodka;

  /// Starter bottle name in the onboarding shelf picker
  ///
  /// In en, this message translates to:
  /// **'Tonic water'**
  String get bottleTonic;

  /// Starter bottle name in the onboarding shelf picker
  ///
  /// In en, this message translates to:
  /// **'Lime'**
  String get bottleLime;

  /// Starter bottle name in the onboarding shelf picker
  ///
  /// In en, this message translates to:
  /// **'White rum'**
  String get bottleWhiteRum;

  /// Starter bottle name in the onboarding shelf picker
  ///
  /// In en, this message translates to:
  /// **'Sweet vermouth'**
  String get bottleSweetVermouth;

  /// Starter bottle name in the onboarding shelf picker
  ///
  /// In en, this message translates to:
  /// **'Whiskey'**
  String get bottleWhiskey;

  /// Starter bottle name in the onboarding shelf picker
  ///
  /// In en, this message translates to:
  /// **'Tequila'**
  String get bottleTequila;

  /// Starter bottle name in the onboarding shelf picker
  ///
  /// In en, this message translates to:
  /// **'Triple sec'**
  String get bottleTripleSec;

  /// Starter bottle name in the onboarding shelf picker
  ///
  /// In en, this message translates to:
  /// **'Lemon'**
  String get bottleLemon;

  /// Starter bottle name in the onboarding shelf picker
  ///
  /// In en, this message translates to:
  /// **'Simple syrup'**
  String get bottleSimpleSyrup;

  /// Starter bottle name in the onboarding shelf picker
  ///
  /// In en, this message translates to:
  /// **'Soda water'**
  String get bottleSodaWater;

  /// Starter bottle name in the onboarding shelf picker
  ///
  /// In en, this message translates to:
  /// **'Angostura bitters'**
  String get bottleAngostura;

  /// Starter bottle name in the onboarding shelf picker
  ///
  /// In en, this message translates to:
  /// **'Mint'**
  String get bottleMint;

  /// Flow 04 - My bar. Label for the shaker starter row on the empty shelf
  ///
  /// In en, this message translates to:
  /// **'Shaker'**
  String get bottleShaker;

  /// Flow 02 - Explore. Explore feed headline
  ///
  /// In en, this message translates to:
  /// **'Pour tonight'**
  String get exploreFeedTitle;

  /// Flow 02 - Explore. Subtitle under the Explore headline when the bar has bottles
  ///
  /// In en, this message translates to:
  /// **'{makeable} of {total} drinks match your shelf'**
  String exploreShelfMatch(int makeable, int total);

  /// Flow 02 - Explore. Subtitle under the Explore headline when the shelf is empty
  ///
  /// In en, this message translates to:
  /// **'{total} drinks. Add a bottle to see what you can pour.'**
  String exploreNoShelfYet(int total);

  /// Flow 02 - Explore. Explore feed section of short recipes
  ///
  /// In en, this message translates to:
  /// **'Two bottles, one drink'**
  String get exploreSectionTwoBottles;

  /// Flow 02 - Explore. Explore feed section of non-alcoholic drinks
  ///
  /// In en, this message translates to:
  /// **'Zero proof'**
  String get exploreSectionZeroProof;

  /// Flow 02 - Explore. Explore feed section of drinks the shelf can already pour
  ///
  /// In en, this message translates to:
  /// **'Ready on your shelf'**
  String get exploreSectionMakeableNow;

  /// Flow 02 - Explore. Link at the end of an Explore feed section header
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get exploreSeeAll;

  /// Flow 02 - Explore. Badge on a cocktail the shelf can fully make
  ///
  /// In en, this message translates to:
  /// **'{count} on your shelf'**
  String exploreAllOnShelf(int count);

  /// Flow 02 - Explore. Badge on a cocktail card counting ingredients the shelf lacks
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 missing} other{{count} missing}}'**
  String exploreMissingBadge(int count);

  /// Flow 02 - Explore. Meta line on a card that is exactly one ingredient short
  ///
  /// In en, this message translates to:
  /// **'needs {ingredient}'**
  String exploreNeedsIngredient(String ingredient);

  /// Flow 02 - Explore. Explore feed empty state title
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get exploreEmptyTitle;

  /// Flow 02 - Explore. Explore feed empty state body
  ///
  /// In en, this message translates to:
  /// **'The catalogue could not be loaded. Pull to try again.'**
  String get exploreEmptyBody;

  /// Flow 02 - Explore. Preparation time on a cocktail card
  ///
  /// In en, this message translates to:
  /// **'{count} min'**
  String cocktailMinutes(int count);

  /// Flow 02 - Explore. Alcohol by volume on a cocktail card
  ///
  /// In en, this message translates to:
  /// **'{value}% ABV'**
  String cocktailAbv(String value);

  /// Flow 02 - Explore. Cocktail build technique
  ///
  /// In en, this message translates to:
  /// **'built'**
  String get methodBuilt;

  /// Flow 02 - Explore. Cocktail build technique
  ///
  /// In en, this message translates to:
  /// **'stirred'**
  String get methodStirred;

  /// Flow 02 - Explore. Cocktail build technique
  ///
  /// In en, this message translates to:
  /// **'shaken'**
  String get methodShaken;

  /// Flow 02 - Explore. Cocktail build technique
  ///
  /// In en, this message translates to:
  /// **'blended'**
  String get methodBlended;

  /// Flow 02 - Explore. Cocktail build technique
  ///
  /// In en, this message translates to:
  /// **'layered'**
  String get methodLayered;

  /// Flow 02 - Explore. Base spirit name
  ///
  /// In en, this message translates to:
  /// **'Gin'**
  String get spiritGin;

  /// Flow 02 - Explore. Base spirit name
  ///
  /// In en, this message translates to:
  /// **'Vodka'**
  String get spiritVodka;

  /// Flow 02 - Explore. Base spirit name
  ///
  /// In en, this message translates to:
  /// **'Rum'**
  String get spiritRum;

  /// Flow 02 - Explore. Base spirit name
  ///
  /// In en, this message translates to:
  /// **'Whisky'**
  String get spiritWhisky;

  /// Flow 02 - Explore. Base spirit name
  ///
  /// In en, this message translates to:
  /// **'Tequila'**
  String get spiritTequila;

  /// Flow 02 - Explore. Base spirit name
  ///
  /// In en, this message translates to:
  /// **'Brandy'**
  String get spiritBrandy;

  /// Flow 02 - Explore. Base spirit name
  ///
  /// In en, this message translates to:
  /// **'Zero proof'**
  String get spiritZeroProof;

  /// Flow 02 - Explore. Base spirit name
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get spiritOther;

  /// Flow 02 - Explore. Cocktail flavour profile
  ///
  /// In en, this message translates to:
  /// **'Citrus'**
  String get flavorCitrus;

  /// Flow 02 - Explore. Cocktail flavour profile
  ///
  /// In en, this message translates to:
  /// **'Bitter'**
  String get flavorBitter;

  /// Flow 02 - Explore. Cocktail flavour profile
  ///
  /// In en, this message translates to:
  /// **'Sweet'**
  String get flavorSweet;

  /// Flow 02 - Explore. Cocktail flavour profile
  ///
  /// In en, this message translates to:
  /// **'Herbal'**
  String get flavorHerbal;

  /// Flow 02 - Explore. Cocktail flavour profile
  ///
  /// In en, this message translates to:
  /// **'Spicy'**
  String get flavorSpicy;

  /// Flow 02 - Explore. Cocktail flavour profile
  ///
  /// In en, this message translates to:
  /// **'Fruity'**
  String get flavorFruity;

  /// Flow 02 - Explore. Cocktail flavour profile
  ///
  /// In en, this message translates to:
  /// **'Dry'**
  String get flavorDry;

  /// Flow 02 - Explore. Cocktail flavour profile
  ///
  /// In en, this message translates to:
  /// **'Creamy'**
  String get flavorCreamy;

  /// Flow 02 - Explore. Measure unit
  ///
  /// In en, this message translates to:
  /// **'ml'**
  String get unitMl;

  /// Flow 02 - Explore. Measure unit
  ///
  /// In en, this message translates to:
  /// **'cl'**
  String get unitCl;

  /// Flow 02 - Explore. Measure unit
  ///
  /// In en, this message translates to:
  /// **'oz'**
  String get unitOz;

  /// Flow 02 - Explore. Measure unit
  ///
  /// In en, this message translates to:
  /// **'dash'**
  String get unitDash;

  /// Flow 02 - Explore. Measure unit
  ///
  /// In en, this message translates to:
  /// **'bar spoon'**
  String get unitBarspoon;

  /// Flow 02 - Explore. Measure unit
  ///
  /// In en, this message translates to:
  /// **'pc'**
  String get unitPiece;

  /// Flow 02 - Explore. Measure unit, used without an amount
  ///
  /// In en, this message translates to:
  /// **'splash'**
  String get unitSplash;

  /// Flow 02 - Explore. Measure unit, used without an amount
  ///
  /// In en, this message translates to:
  /// **'top up'**
  String get unitTopUp;

  /// Flow 02 - Explore. An ingredient quantity — amount followed by its unit
  ///
  /// In en, this message translates to:
  /// **'{amount} {unit}'**
  String measureAmount(String amount, String unit);

  /// Flow 02 - Explore. Placeholder in the Explore search field
  ///
  /// In en, this message translates to:
  /// **'Cocktail, spirit, or mood'**
  String get searchHint;

  /// Flow 02 - Explore. Dismisses the search overlay
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get searchCancel;

  /// Flow 02 - Explore. Section header over recent search terms
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get searchRecent;

  /// Flow 02 - Explore. Clears the recent search list
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get searchClearRecent;

  /// Flow 02 - Explore. Section header over trending cocktails
  ///
  /// In en, this message translates to:
  /// **'Popular this week'**
  String get searchPopularThisWeek;

  /// Flow 02 - Explore. Section header over the base-spirit tiles
  ///
  /// In en, this message translates to:
  /// **'Browse by spirit'**
  String get searchBrowseBySpirit;

  /// Flow 02 - Explore. Accessibility label for the button that empties the search field
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get searchClearQuery;

  /// Flow 02 - Explore. Title of the Explore filter sheet
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filterSheetTitle;

  /// Flow 02 - Explore. Clears every filter in the sheet
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get filterReset;

  /// Flow 02 - Explore. Accessibility label for the button that opens the filter sheet
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filterOpen;

  /// Flow 02 - Explore. The headline filter — only drinks the shelf can already pour
  ///
  /// In en, this message translates to:
  /// **'Makeable with my bar'**
  String get filterMakeableTitle;

  /// Flow 02 - Explore. Subtitle under the makeable filter, counting the shelf and what it pours
  ///
  /// In en, this message translates to:
  /// **'{bottles, plural, =1{1 bottle on the shelf} other{{bottles} bottles on the shelf}} · {drinks} drinks'**
  String filterMakeableSubtitle(int bottles, int drinks);

  /// Flow 02 - Explore. Subtitle under the makeable filter when the shelf is empty
  ///
  /// In en, this message translates to:
  /// **'No bottles on the shelf yet'**
  String get filterMakeableEmptyBar;

  /// Flow 02 - Explore. Section header over the sort control
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get filterSectionSort;

  /// Flow 02 - Explore. Section header over the base-spirit chips
  ///
  /// In en, this message translates to:
  /// **'Base spirit'**
  String get filterSectionBaseSpirit;

  /// Flow 02 - Explore. Section header over the effort toggles
  ///
  /// In en, this message translates to:
  /// **'Effort'**
  String get filterSectionEffort;

  /// Flow 02 - Explore. Sort option — drinks the shelf can pour come first
  ///
  /// In en, this message translates to:
  /// **'Makeable'**
  String get sortMakeable;

  /// Flow 02 - Explore. Sort option — most popular first
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get sortPopular;

  /// Flow 02 - Explore. Sort option — best fit for the season first
  ///
  /// In en, this message translates to:
  /// **'Seasonal'**
  String get sortSeasonal;

  /// Flow 02 - Explore. Effort filter — quick drinks only
  ///
  /// In en, this message translates to:
  /// **'Under 3 minutes'**
  String get filterUnderThreeMinutes;

  /// Flow 02 - Explore. Effort filter — drops anything that has to be shaken
  ///
  /// In en, this message translates to:
  /// **'No shaker needed'**
  String get filterNoShaker;

  /// Flow 02 - Explore. Effort filter — short ingredient lists only
  ///
  /// In en, this message translates to:
  /// **'Three ingredients max'**
  String get filterThreeIngredients;

  /// Flow 02 - Explore. Primary button at the bottom of the filter sheet
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No drinks match} =1{Show 1 drink} other{Show {count} drinks}}'**
  String filterShowDrinks(int count);

  /// Flow 02 - Explore. Removable chip for the makeable filter
  ///
  /// In en, this message translates to:
  /// **'Makeable'**
  String get filterChipMakeable;

  /// Flow 02 - Explore. Removable chip for the no-shaker filter
  ///
  /// In en, this message translates to:
  /// **'No shaker'**
  String get filterChipNoShaker;

  /// Flow 02 - Explore. Removable chip for the quick filter
  ///
  /// In en, this message translates to:
  /// **'Under 3 min'**
  String get filterChipUnderThree;

  /// Flow 02 - Explore. Removable chip for the three-ingredients filter
  ///
  /// In en, this message translates to:
  /// **'Max 3 parts'**
  String get filterChipThreeIngredients;

  /// Flow 02 - Explore. Accessibility label on a removable filter chip
  ///
  /// In en, this message translates to:
  /// **'Remove {filter}'**
  String filterRemove(String filter);

  /// Flow 02 - Explore. Result count above the Explore results grid
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No drinks} =1{1 drink} other{{count} drinks}}'**
  String resultsCount(int count);

  /// Flow 02 - Explore. Note beside the result count when the makeable sort is on
  ///
  /// In en, this message translates to:
  /// **'makeable first'**
  String get resultsMakeableFirst;

  /// Flow 02 - Explore. Note beside the result count when the popular sort is on
  ///
  /// In en, this message translates to:
  /// **'popular first'**
  String get resultsPopularFirst;

  /// Flow 02 - Explore. Note beside the result count when the seasonal sort is on
  ///
  /// In en, this message translates to:
  /// **'seasonal first'**
  String get resultsSeasonalFirst;

  /// Flow 02 - Explore. Zero-results headline when no single filter is to blame
  ///
  /// In en, this message translates to:
  /// **'Nothing matches that yet'**
  String get zeroResultsTitle;

  /// Flow 02 - Explore. Zero-results headline naming the one filter that emptied the list
  ///
  /// In en, this message translates to:
  /// **'{filter} is what is in the way'**
  String zeroResultsBlockedTitle(String filter);

  /// Flow 02 - Explore. Zero-results body when one filter is to blame
  ///
  /// In en, this message translates to:
  /// **'Nothing matches “{query}” with {filter} on. Drop that filter, or try one of these.'**
  String zeroResultsBody(String query, String filter);

  /// Flow 02 - Explore. Zero-results body when one filter is to blame and nothing was typed
  ///
  /// In en, this message translates to:
  /// **'Nothing matches with {filter} on. Drop that filter, or try one of these.'**
  String zeroResultsBodyNoQuery(String filter);

  /// Flow 02 - Explore. Zero-results body when the query alone found nothing
  ///
  /// In en, this message translates to:
  /// **'Nothing matches “{query}”. Try another word, or one of these.'**
  String zeroResultsBodyPlain(String query);

  /// Flow 02 - Explore. Button that removes the one filter blocking the results
  ///
  /// In en, this message translates to:
  /// **'Drop “{filter}”'**
  String zeroResultsDropFilter(String filter);

  /// Flow 02 - Explore. Button that removes every active filter
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get zeroResultsClearAll;

  /// Flow 02 - Explore. Section header over drinks the shelf is a single ingredient short of
  ///
  /// In en, this message translates to:
  /// **'One bottle away'**
  String get zeroResultsOneBottleAway;

  /// Flow 02 - Explore. Subtitle on a near-miss row: the missing bottle and what it opens up
  ///
  /// In en, this message translates to:
  /// **'add {ingredient} · unlocks {count}'**
  String zeroResultsUnlocks(String ingredient, int count);

  /// Flow 02 - Explore. Subtitle on a near-miss row when the unlock count is unknown
  ///
  /// In en, this message translates to:
  /// **'add {ingredient}'**
  String zeroResultsUnlocksUnknown(String ingredient);

  /// Flow 02 - Explore. Section header over drinks the shelf can still make
  ///
  /// In en, this message translates to:
  /// **'You can pour these tonight'**
  String get zeroResultsPourable;

  /// Flow 02 - Explore. Accessibility label on the button that puts a bottle on the shelf
  ///
  /// In en, this message translates to:
  /// **'Add to my bar'**
  String get addToBar;

  /// Flow 02 - Explore. Confirmation after adding a bottle to the shelf
  ///
  /// In en, this message translates to:
  /// **'{ingredient} is on your shelf'**
  String addedToBar(String ingredient);

  /// Flow 02 - Explore. Bookmarks a cocktail — the first thing that needs an account
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get cocktailSave;

  /// Flow 02 - Explore. Shares a cocktail recipe
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get cocktailShare;

  /// Flow 02 - Explore. Accessibility label for the back button over a cocktail photo
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get cocktailBack;

  /// Flow 02 - Explore. Trailing note on an ingredient row the shelf does not hold
  ///
  /// In en, this message translates to:
  /// **'not on your shelf'**
  String get cocktailNotOnShelf;

  /// Flow 02 - Explore. Prompt under the ingredient list on a cocktail one bottle short
  ///
  /// In en, this message translates to:
  /// **'Add {ingredient} to your bar — unlocks {count} more'**
  String cocktailAddUnlocks(String ingredient, int count);

  /// Flow 02 - Explore. Prompt under the ingredient list when the unlock count is unknown
  ///
  /// In en, this message translates to:
  /// **'Add {ingredient} to your bar'**
  String cocktailAddToBarPlain(String ingredient);

  /// Flow 02 - Explore. Primary action on the cocktail detail screen
  ///
  /// In en, this message translates to:
  /// **'Make it now'**
  String get cocktailMakeItNow;

  /// Flow 02 - Explore. Secondary action on the cocktail detail screen
  ///
  /// In en, this message translates to:
  /// **'Add to a party'**
  String get cocktailAddToParty;

  /// Flow 02 - Explore. Section header over the ingredient list
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get cocktailIngredientsTitle;

  /// Flow 02 - Explore. Confirmation after sharing a recipe
  ///
  /// In en, this message translates to:
  /// **'Recipe copied to clipboard'**
  String get cocktailRecipeCopied;

  /// Flow 02 - Explore. Eyebrow above the current step of the guided pour
  ///
  /// In en, this message translates to:
  /// **'Step {step} of {total} · {cocktail}'**
  String pourStepCounter(int step, int total, String cocktail);

  /// Flow 02 - Explore. Hint under the countdown on a timed pour step
  ///
  /// In en, this message translates to:
  /// **'Tap to run the timer'**
  String get pourTimerHint;

  /// Flow 02 - Explore. Hint under the countdown while it is counting down
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get pourTimerRunning;

  /// Flow 02 - Explore. Hint under the countdown once it reaches zero
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get pourTimerDone;

  /// Flow 02 - Explore. Advances the guided pour
  ///
  /// In en, this message translates to:
  /// **'Next step'**
  String get pourNext;

  /// Flow 02 - Explore. Finishes the guided pour on the last step
  ///
  /// In en, this message translates to:
  /// **'Poured it'**
  String get pourFinish;

  /// Flow 02 - Explore. Accessibility label for going back a step
  ///
  /// In en, this message translates to:
  /// **'Previous step'**
  String get pourBack;

  /// Flow 02 - Explore. Accessibility label for leaving the guided pour
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get pourExit;

  /// Flow 02 - Explore. Reveals the full recipe over the guided pour
  ///
  /// In en, this message translates to:
  /// **'Recipe'**
  String get pourShowRecipe;

  /// Flow 02 - Explore. Confirmation after the last step of the guided pour
  ///
  /// In en, this message translates to:
  /// **'{cocktail} poured. Enjoy.'**
  String pourFinished(String cocktail);

  /// Flow 02 - Explore. Shown when a cocktail has no preparation steps at all
  ///
  /// In en, this message translates to:
  /// **'This one has no steps written down yet.'**
  String get pourNoSteps;

  /// Flow 02 - Explore. Title of the sheet shown when saving needs an account
  ///
  /// In en, this message translates to:
  /// **'Keep the {cocktail}'**
  String authGateSaveTitle(String cocktail);

  /// Flow 02 - Explore. Body of the auth sheet triggered by saving a cocktail
  ///
  /// In en, this message translates to:
  /// **'Saved drinks live in your account, so they survive a new phone. Your shelf and everything you have browsed comes with you.'**
  String get authGateSaveBody;

  /// Flow 02 - Explore. Benefit row in the auth sheet
  ///
  /// In en, this message translates to:
  /// **'Lists that sync'**
  String get authGateLists;

  /// Flow 02 - Explore. Benefit row in the auth sheet
  ///
  /// In en, this message translates to:
  /// **'Host a party, take orders'**
  String get authGateHost;

  /// Flow 02 - Explore. Benefit row in the auth sheet, naming what the shelf already holds
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Your shelf carries over} =1{Your 1 bottle carries over} other{Your {count} bottles carry over}}'**
  String authGateShelf(int count);

  /// Flow 02 - Explore. Sign-in option in the auth sheet
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get authGateApple;

  /// Flow 02 - Explore. Sign-in option in the auth sheet
  ///
  /// In en, this message translates to:
  /// **'Use an email address'**
  String get authGateEmail;

  /// Flow 02 - Explore. Dismisses the auth sheet without signing in
  ///
  /// In en, this message translates to:
  /// **'Keep browsing without an account'**
  String get authGateKeepBrowsing;

  /// Flow 03 - Auth. Google sign-in button
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get authContinueGoogle;

  /// Flow 03 - Auth. Apple sign-in button, dark until Apple sign-in ships
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get authContinueApple;

  /// Flow 03 - Auth. Badge on the Apple button while it is not wired yet
  ///
  /// In en, this message translates to:
  /// **'Soon'**
  String get authAppleSoon;

  /// Flow 03 - Auth. Legal footnote under the provider buttons. Both placeholders are rendered as links
  ///
  /// In en, this message translates to:
  /// **'By continuing you agree to the {terms} and {privacy}.'**
  String authLegalLine(String terms, String privacy);

  /// Flow 03 - Auth. Name of the terms document, used as a link inside authLegalLine
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get authTerms;

  /// Flow 03 - Auth. Name of the privacy document, used as a link inside authLegalLine
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get authPrivacy;

  /// Flow 03 - Auth. Screen 01. Overline on the barrier sheet, rendered uppercase
  ///
  /// In en, this message translates to:
  /// **'One step left'**
  String get authBarrierEyebrow;

  /// Flow 03 - Auth. Screen 01. Barrier title when the interrupted action was creating a party
  ///
  /// In en, this message translates to:
  /// **'Parties need an owner'**
  String get authBarrierHostTitle;

  /// Flow 03 - Auth. Screen 01. Barrier body for creating a party
  ///
  /// In en, this message translates to:
  /// **'So guests can join from your link, and the menu is still here next Saturday. Your draft is saved either way.'**
  String get authBarrierHostBody;

  /// Flow 03 - Auth. Screen 01. Barrier title when the interrupted action was editing the shelf. Flow 04 turned this into a one-time nudge rather than a gate.
  ///
  /// In en, this message translates to:
  /// **'Don’t lose this shelf'**
  String get authBarrierBarTitle;

  /// Flow 03 - Auth. Screen 01. Barrier body for editing the shelf. Flow 04 turned this into a one-time nudge rather than a gate.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google and it follows you to the next phone. It keeps working on this one either way.'**
  String get authBarrierBarBody;

  /// Flow 03 - Auth. Screen 01. Dismisses the barrier without signing in
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get authNotNow;

  /// Flow 03 - Auth. Screen 02. Chip above the headline, rendered uppercase
  ///
  /// In en, this message translates to:
  /// **'Your bar, everywhere'**
  String get authProvidersEyebrow;

  /// Flow 03 - Auth. Screen 02. Headline on the cold sign-in screen
  ///
  /// In en, this message translates to:
  /// **'One account.\nEvery party.'**
  String get authProvidersTitle;

  /// Flow 03 - Auth. Screen 02. Body under the headline
  ///
  /// In en, this message translates to:
  /// **'Your shelf, your saved drinks and every party you have hosted, on any phone you pick up.'**
  String get authProvidersBody;

  /// Flow 03 - Auth. Screen 02. Reassurance line under the provider buttons
  ///
  /// In en, this message translates to:
  /// **'18+ only · we never post anything'**
  String get authAgeNote;

  /// Flow 03 - Auth. Screen 05. Confirmation chip at the top, rendered uppercase
  ///
  /// In en, this message translates to:
  /// **'Signed in'**
  String get authSignedInBadge;

  /// Flow 03 - Auth. Screen 05. Headline of the display-name screen
  ///
  /// In en, this message translates to:
  /// **'How should\nguests see you?'**
  String get authNameTitle;

  /// Flow 03 - Auth. Screen 05. Body of the display-name screen
  ///
  /// In en, this message translates to:
  /// **'This is the only thing other people at a party see next to your orders.'**
  String get authNameBody;

  /// Flow 03 - Auth. Screen 05. Optional avatar action
  ///
  /// In en, this message translates to:
  /// **'Add a photo'**
  String get authAddPhoto;

  /// Flow 03 - Auth. Screen 05. Note under the avatar action
  ///
  /// In en, this message translates to:
  /// **'Optional. Your initial works fine.'**
  String get authAddPhotoNote;

  /// Flow 03 - Auth. Screen 05. Field label, rendered uppercase
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get authDisplayNameLabel;

  /// Flow 03 - Auth. Screen 05. Placeholder in the display-name field
  ///
  /// In en, this message translates to:
  /// **'Marta'**
  String get authDisplayNameHint;

  /// Flow 03 - Auth. Screen 05. The one age gate in the product, on the commit
  ///
  /// In en, this message translates to:
  /// **'I’m 18 or over'**
  String get authAgeConfirm;

  /// Flow 03 - Auth. Screen 05. Legal note under the age gate. Both placeholders are rendered as links
  ///
  /// In en, this message translates to:
  /// **'PartyBar is for people of legal drinking age. See the {terms} and {privacy}.'**
  String authAgeLegal(String terms, String privacy);

  /// Flow 03 - Auth. Screen 05. Validation message under the display-name field
  ///
  /// In en, this message translates to:
  /// **'Pick something guests will recognise.'**
  String get authNameRequired;

  /// Flow 03 - Auth. Screen 05. Shown when the age gate has not been ticked
  ///
  /// In en, this message translates to:
  /// **'Confirm you are 18 or over to continue.'**
  String get authAgeRequired;

  /// Flow 03 - Auth. Screen 05. Commit button when a party was waiting
  ///
  /// In en, this message translates to:
  /// **'Create my party'**
  String get authFinishHost;

  /// Flow 03 - Auth. Screen 05. Commit button when the shelf was waiting
  ///
  /// In en, this message translates to:
  /// **'Open my bar'**
  String get authFinishBar;

  /// Flow 03 - Auth. Screen 05. Commit button when a cocktail was waiting
  ///
  /// In en, this message translates to:
  /// **'Save the drink'**
  String get authFinishSave;

  /// Flow 03 - Auth. Screen 05. Commit button with nothing particular waiting
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get authFinishGeneric;

  /// Flow 03 - Auth. Screen 06. Glass chip shown on returning to the interrupted screen
  ///
  /// In en, this message translates to:
  /// **'Signed in as {name}'**
  String authSignedInAs(String name);

  /// Flow 03 - Auth. Screen 06. Row confirming nothing was lost
  ///
  /// In en, this message translates to:
  /// **'Draft kept while you signed in'**
  String get authDraftKept;

  /// Flow 03 - Auth. Screen 06. Trailing status on the draft row, rendered uppercase
  ///
  /// In en, this message translates to:
  /// **'Restored'**
  String get authDraftRestored;

  /// Flow 03 - Auth. Screen 08. Glass chip naming the party a guest has arrived at, rendered uppercase
  ///
  /// In en, this message translates to:
  /// **'Live · {party}'**
  String guestLiveAt(String party);

  /// Flow 03 - Auth. Screen 08. Headline of the guest arrival screen
  ///
  /// In en, this message translates to:
  /// **'You’re at the bar'**
  String get guestTitle;

  /// Flow 03 - Auth. Screen 08. Body of the guest arrival screen
  ///
  /// In en, this message translates to:
  /// **'No account needed. {host} just needs to know whose drink is whose.'**
  String guestBody(String host);

  /// Flow 03 - Auth. Screen 08. Body of the guest arrival screen when the host name is unknown
  ///
  /// In en, this message translates to:
  /// **'No account needed. The host just needs to know whose drink is whose.'**
  String get guestBodyNoHost;

  /// Flow 03 - Auth. Screen 08. Field label, rendered uppercase
  ///
  /// In en, this message translates to:
  /// **'What should we call you?'**
  String get guestNameLabel;

  /// Flow 03 - Auth. Screen 08. Placeholder in the guest name field
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get guestNameHint;

  /// Flow 03 - Auth. Screen 08. Validation message under the guest name field
  ///
  /// In en, this message translates to:
  /// **'A name is all we need.'**
  String get guestNameRequired;

  /// Flow 03 - Auth. Screen 08. Enters the party menu as a guest
  ///
  /// In en, this message translates to:
  /// **'Start ordering'**
  String get guestStartOrdering;

  /// Flow 03 - Auth. Screen 08. The age gate in the guest lane, one line rather than a checkbox
  ///
  /// In en, this message translates to:
  /// **'By ordering you confirm you’re 18 or over'**
  String get guestAgeNote;

  /// Flow 03 - Auth. Screen 08. Optional route to the full sign-in for guests
  ///
  /// In en, this message translates to:
  /// **'Have an account? Sign in'**
  String get guestHaveAccount;

  /// Flow 03 - Auth. Screen 09. Headline behind the claim sheet, after a party ends
  ///
  /// In en, this message translates to:
  /// **'That was a night'**
  String get claimHeadline;

  /// Flow 03 - Auth. Screen 09. What the night amounted to, under the headline
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 drink · {party}} other{{count} drinks · {party}}}'**
  String claimSubline(int count, String party);

  /// Flow 03 - Auth. Screen 09. Title of the claim sheet
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Keep tonight’s drink?} other{Keep tonight’s {count}?}}'**
  String claimTitle(int count);

  /// Flow 03 - Auth. Screen 09. Body of the claim sheet
  ///
  /// In en, this message translates to:
  /// **'An account saves what you drank, so next time the bar already knows your taste. Skip it and nothing is lost tonight.'**
  String get claimBody;

  /// Flow 03 - Auth. Screen 09. Overflow tile when more drinks were poured than fit the row
  ///
  /// In en, this message translates to:
  /// **'+{count}'**
  String claimMore(int count);

  /// Flow 03 - Auth. Screen 09. Claims the night with Google
  ///
  /// In en, this message translates to:
  /// **'Save with Google'**
  String get claimWithGoogle;

  /// Flow 03 - Auth. Screen 09. Claims the night with Apple
  ///
  /// In en, this message translates to:
  /// **'Apple'**
  String get claimWithApple;

  /// Flow 03 - Auth. Screen 09. Dismisses the claim sheet, which does not come back
  ///
  /// In en, this message translates to:
  /// **'No thanks'**
  String get claimNoThanks;

  /// Flow 03 - Auth. Error copy. The address exists under another provider; a button under this continues with it
  ///
  /// In en, this message translates to:
  /// **'You already use Google for {email}.'**
  String authErrorDifferentProvider(String email);

  /// Flow 03 - Auth. Error copy. Same as authErrorDifferentProvider when the address did not come back with the error
  ///
  /// In en, this message translates to:
  /// **'You already use Google for that address.'**
  String get authErrorDifferentProviderNoEmail;

  /// Flow 03 - Auth. Error copy. Offline during a sign-in attempt
  ///
  /// In en, this message translates to:
  /// **'No connection. Your draft is on this phone — we’ll sign you in when you’re back.'**
  String get authErrorOffline;

  /// Flow 03 - Auth. Error copy. Anything not worth a sentence of its own
  ///
  /// In en, this message translates to:
  /// **'Sign-in did not go through. Try again.'**
  String get authErrorGeneric;

  /// Flow 03 - Auth. Error copy. Retries the failed attempt
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get authErrorRetry;

  /// Flow 03 - Auth. Accessibility label for the back affordance
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get authBack;

  /// Flow 03 - Auth. Accessibility label for the close affordance
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get authClose;

  /// Flow 04 - My bar. Screen title
  ///
  /// In en, this message translates to:
  /// **'My bar'**
  String get barTitle;

  /// Flow 04 - My bar. Screen 01. Subtitle under the My bar title when signed out and the shelf is empty
  ///
  /// In en, this message translates to:
  /// **'Nothing on the shelf yet. Tap what you own — it stays on this phone until you sign in.'**
  String get barEmptyBody;

  /// Flow 04 - My bar. Screen 01. Subtitle under the My bar title when signed in and the shelf is empty
  ///
  /// In en, this message translates to:
  /// **'Nothing on the shelf yet. Tap what you own.'**
  String get barEmptyBodySignedIn;

  /// Flow 04 - My bar. Placeholder in the My bar search field
  ///
  /// In en, this message translates to:
  /// **'Bottles, mixers, tools…'**
  String get barSearchHint;

  /// Flow 04 - My bar. Screen 01. Eyebrow above the starter rows
  ///
  /// In en, this message translates to:
  /// **'Most bars start here'**
  String get barStartersSection;

  /// Flow 04 - My bar. Screen 01. Adds every starter row to the shelf at once
  ///
  /// In en, this message translates to:
  /// **'Add all'**
  String get barAddAll;

  /// Flow 04 - My bar. Screen 01. Footnote under the starter rows
  ///
  /// In en, this message translates to:
  /// **'Twelve suggestions, then search for the rest'**
  String get barStartersFooter;

  /// Flow 04 - My bar. Catalogue-wide drink count on a row not yet on the shelf
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{In 1 drink} other{In {count} drinks}}'**
  String barInDrinks(int count);

  /// Flow 04 - My bar. Screen 02. Lowercase, mid-sentence drink count appended to a search result's subtitle ("Spirits · in 22 drinks")
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{in 1 drink} other{in {count} drinks}}'**
  String barInDrinksInline(int count);

  /// Flow 04 - My bar. Catalogue-wide drink count on an equipment row not yet on the shelf
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Needed for 1 drink} other{Needed for {count} drinks}}'**
  String barNeededForDrinks(int count);

  /// Flow 04 - My bar. Subtitle on a stocked row that has nothing more specific to say
  ///
  /// In en, this message translates to:
  /// **'On your shelf'**
  String get barOnYourShelf;

  /// Flow 04 - My bar. Screen 03. Part of the header subtitle counting stocked items
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 on the shelf} other{{count} on the shelf}}'**
  String barShelfCount(int count);

  /// Flow 04 - My bar. Screen 03. Part of the header subtitle counting makeable drinks
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 drink you can make} other{{count} drinks you can make}}'**
  String barMakeableCount(int count);

  /// Flow 04 - My bar. Screen 04. Header subtitle counting fresh, tools and ice items
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 thing} other{{count} things}}'**
  String barThingsCount(int count);

  /// Flow 04 - My bar. Filter chip that clears the section filter
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get barFilterAll;

  /// Flow 04 - My bar. Filter chip label for the spirits section
  ///
  /// In en, this message translates to:
  /// **'Spirits'**
  String get barSectionSpirits;

  /// Flow 04 - My bar. Filter chip label for the mixers section
  ///
  /// In en, this message translates to:
  /// **'Mixers'**
  String get barSectionMixers;

  /// Flow 04 - My bar. Filter chip label for the fresh section
  ///
  /// In en, this message translates to:
  /// **'Fresh'**
  String get barSectionFresh;

  /// Flow 04 - My bar. Filter chip label for the syrups section
  ///
  /// In en, this message translates to:
  /// **'Syrups'**
  String get barSectionSyrups;

  /// Flow 04 - My bar. Filter chip label for the tools section
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get barSectionTools;

  /// Flow 04 - My bar. Filter chip label for the ice section
  ///
  /// In en, this message translates to:
  /// **'Ice'**
  String get barSectionIce;

  /// Flow 04 - My bar. Filter chip label for the other section
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get barSectionOther;

  /// Flow 04 - My bar. Group header label for the spirits section
  ///
  /// In en, this message translates to:
  /// **'Spirits & liqueurs'**
  String get barGroupSpirits;

  /// Flow 04 - My bar. Group header label for the mixers section
  ///
  /// In en, this message translates to:
  /// **'Mixers'**
  String get barGroupMixers;

  /// Flow 04 - My bar. Group header label for the fresh section
  ///
  /// In en, this message translates to:
  /// **'Fresh'**
  String get barGroupFresh;

  /// Flow 04 - My bar. Group header label for the syrups section
  ///
  /// In en, this message translates to:
  /// **'Syrups & bitters'**
  String get barGroupSyrups;

  /// Flow 04 - My bar. Group header label for the tools section
  ///
  /// In en, this message translates to:
  /// **'Tools & glassware'**
  String get barGroupTools;

  /// Flow 04 - My bar. Group header label for the ice section
  ///
  /// In en, this message translates to:
  /// **'Ice'**
  String get barGroupIce;

  /// Flow 04 - My bar. Group header label for the other section
  ///
  /// In en, this message translates to:
  /// **'Everything else'**
  String get barGroupOther;

  /// Flow 04 - My bar. Subtitle on a stocked row naming how many of the shelf's own makeable drinks use it
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{In 1 of your drinks} other{In {count} of your drinks}}'**
  String barInYourDrinks(int count);

  /// Flow 04 - My bar. Subtitle on a stocked equipment row naming how many of the shelf's own makeable drinks need it
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Needed for 1 of your drinks} other{Needed for {count} of your drinks}}'**
  String barNeededForYourDrinks(int count);

  /// Flow 04 - My bar. Subtitle on a row added within the last few minutes
  ///
  /// In en, this message translates to:
  /// **'Added just now'**
  String get barAddedJustNow;

  /// Flow 04 - My bar. Subtitle on a fresh/tools/ice row that has never been added
  ///
  /// In en, this message translates to:
  /// **'Not in your bar'**
  String get barNotInYourBar;

  /// Flow 04 - My bar. Group header label for the ran-out group at the end of the shelf
  ///
  /// In en, this message translates to:
  /// **'Ran out'**
  String get barRanOutGroup;

  /// Flow 04 - My bar. Action beside the ran-out group header that adds every ran-out item to the shopping list
  ///
  /// In en, this message translates to:
  /// **'Add all to list'**
  String get barAddAllToList;

  /// Flow 04 - My bar. Subtitle on a ran-out row naming how many makeable drinks it is blocking
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Blocks 1 drink} other{Blocks {count} drinks}}'**
  String barBlocksDrinks(int count);

  /// Flow 04 - My bar. Suffix noting a ran-out item is already on the shopping list
  ///
  /// In en, this message translates to:
  /// **'On your list'**
  String get barOnYourList;

  /// Flow 04 - My bar. Pill action that adds a single item to the shopping list
  ///
  /// In en, this message translates to:
  /// **'Add to list'**
  String get barAddToList;

  /// Flow 04 - My bar. Screen 04. Explainer note under the fresh/tools/ice list
  ///
  /// In en, this message translates to:
  /// **'Fresh things go off, so we ask what ran out when a party ends — never in the middle of one.'**
  String get barFreshInfo;

  /// Flow 04 - My bar. Link that opens the shopping list screen
  ///
  /// In en, this message translates to:
  /// **'Shopping list'**
  String get barOpenList;

  /// Flow 04 - My bar. Accessibility label for a search result row's add action
  ///
  /// In en, this message translates to:
  /// **'Add to my bar'**
  String get barAddItem;

  /// Flow 04 - My bar. Accessibility label for the action that moves a stocked item to ran out
  ///
  /// In en, this message translates to:
  /// **'Mark {item} as ran out'**
  String barMarkRanOut(String item);

  /// Flow 04 - My bar. Accessibility label for the action that restocks a ran-out item
  ///
  /// In en, this message translates to:
  /// **'Put {item} back on the shelf'**
  String barPutBack(String item);

  /// Flow 04 - My bar. Screen 05. Item sheet toggle row label
  ///
  /// In en, this message translates to:
  /// **'On the shelf'**
  String get barSheetOnShelf;

  /// Flow 04 - My bar. Screen 05. Item sheet row that marks the item ran out
  ///
  /// In en, this message translates to:
  /// **'Ran out — put it on my list'**
  String get barSheetRanOut;

  /// Flow 04 - My bar. Screen 05. Item sheet note row label
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get barSheetNote;

  /// Flow 04 - My bar. Screen 05. Placeholder in the item note field
  ///
  /// In en, this message translates to:
  /// **'Brand, bottle, where it lives…'**
  String get barSheetNoteHint;

  /// Flow 04 - My bar. Screen 05. Item sheet note row trailing action when there is no note yet
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get barSheetNoteAdd;

  /// Flow 04 - My bar. Screen 05. Saves the note being edited
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get barSheetNoteSave;

  /// Flow 04 - My bar. Screen 05. Item sheet row that removes the item entirely
  ///
  /// In en, this message translates to:
  /// **'Remove from my bar'**
  String get barSheetRemove;

  /// Flow 04 - My bar. Screen 05. Eyebrow above the cocktails this item unlocks
  ///
  /// In en, this message translates to:
  /// **'Unlocks for you'**
  String get barSheetUnlocks;

  /// Flow 04 - My bar. Screen 05. Label on the '+N' tile after the first two unlock tiles
  ///
  /// In en, this message translates to:
  /// **'more'**
  String get barSheetMore;

  /// Flow 04 - My bar. Screen 05. Closes the item sheet
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get barSheetDone;

  /// Flow 04 - My bar. Snackbar confirming an item was removed from the bar
  ///
  /// In en, this message translates to:
  /// **'{item} removed'**
  String barRemoved(String item);

  /// Flow 04 - My bar. Snackbar action that reverses the last removal
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get barUndo;

  /// Flow 04 - My bar. Screen 02. Cancels the search and returns to the shelf
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get barSearchCancel;

  /// Flow 04 - My bar. Screen 02. Eyebrow above the search results
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No matches} =1{1 match} other{{count} matches}}'**
  String barSearchMatches(int count);

  /// Flow 04 - My bar. Screen 02. Subtitle on a search result already stocked
  ///
  /// In en, this message translates to:
  /// **'Already on your shelf'**
  String get barAlreadyOnShelf;

  /// Flow 04 - My bar. Screen 02. Subtitle on a search result that ran out
  ///
  /// In en, this message translates to:
  /// **'Ran out · tap to put it back'**
  String get barRanOutTapRestock;

  /// Flow 04 - My bar. Screen 02. Offer to add the typed query as a custom bar item
  ///
  /// In en, this message translates to:
  /// **'Not here? Add “{query}” as your own bottle'**
  String barAddCustom(String query);

  /// Flow 04 - My bar. Screen 06 search. Offer to add the typed query to the shopping list as a custom item
  ///
  /// In en, this message translates to:
  /// **'Not here? Add “{query}” to your list'**
  String barAddCustomToList(String query);

  /// Flow 04 - My bar. Subtitle used for a custom item with no catalogue data of its own
  ///
  /// In en, this message translates to:
  /// **'Your own bottle'**
  String get barCustomItem;

  /// Flow 04 - My bar. Placeholder in the search field when adding to the shopping list
  ///
  /// In en, this message translates to:
  /// **'What do you need?'**
  String get barSearchListHint;

  /// Flow 04 - My bar. Subtitle on a search result already on the shopping list
  ///
  /// In en, this message translates to:
  /// **'Already on your list'**
  String get barAlreadyOnList;

  /// Flow 04 - My bar. Notice shown when the catalogue failed to load and only starters are searchable
  ///
  /// In en, this message translates to:
  /// **'Only the starter list for now — the full catalogue needs a connection.'**
  String get barCatalogueOffline;

  /// Flow 04 - Shopping list. Screen 06. Screen title
  ///
  /// In en, this message translates to:
  /// **'Shopping list'**
  String get shoppingListTitle;

  /// Flow 04 - Shopping list. Screen 06. Subtitle under the title
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Nothing to buy} =1{1 thing · tick it and it goes on the shelf} other{{count} things · tick one and it goes on the shelf}}'**
  String shoppingListSubtitle(int count);

  /// Flow 04 - Shopping list. Screen 06. Group header for items blocking a makeable drink
  ///
  /// In en, this message translates to:
  /// **'Blocking your drinks'**
  String get shoppingListBlockingHeader;

  /// Flow 04 - Shopping list. Screen 06. Subtitle explaining why an item is blocking
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 drink you could make needs it} other{{count} drinks you could make need it}}'**
  String shoppingListBlockingLine(int count);

  /// Flow 04 - Shopping list. Screen 06. Group header for everything else on the list
  ///
  /// In en, this message translates to:
  /// **'Also added'**
  String get shoppingListAlsoHeader;

  /// Flow 04 - Shopping list. Subtitle naming the party an item ran out at
  ///
  /// In en, this message translates to:
  /// **'Ran out at {party}'**
  String shoppingListRanOutAt(String party);

  /// Flow 04 - Shopping list. Subtitle when an item ran out with no party name recorded
  ///
  /// In en, this message translates to:
  /// **'Ran out'**
  String get shoppingListRanOut;

  /// Flow 04 - Shopping list. Subtitle naming the cocktail an item was added for
  ///
  /// In en, this message translates to:
  /// **'For {cocktail}'**
  String shoppingListForCocktail(String cocktail);

  /// Flow 04 - Shopping list. Subtitle for an item added manually
  ///
  /// In en, this message translates to:
  /// **'Added by you'**
  String get shoppingListAddedByYou;

  /// Flow 04 - Shopping list. Confirmation shown briefly after ticking an item
  ///
  /// In en, this message translates to:
  /// **'Now on your shelf'**
  String get shoppingListNowOnShelf;

  /// Flow 04 - Shopping list. Row that opens search to add another item
  ///
  /// In en, this message translates to:
  /// **'Add something else…'**
  String get shoppingListAddSomething;

  /// Flow 04 - Shopping list. Opens the share-as-text sheet
  ///
  /// In en, this message translates to:
  /// **'Share the list'**
  String get shoppingListShare;

  /// Flow 04 - Shopping list. Overflow menu action that clears ticked entries
  ///
  /// In en, this message translates to:
  /// **'Clear the ticked ones'**
  String get shoppingListClearTicked;

  /// Flow 04 - Shopping list. Overflow menu action that clears every entry
  ///
  /// In en, this message translates to:
  /// **'Clear the whole list'**
  String get shoppingListClearAll;

  /// Flow 04 - Shopping list. Empty state title
  ///
  /// In en, this message translates to:
  /// **'Nothing to buy'**
  String get shoppingListEmptyTitle;

  /// Flow 04 - Shopping list. Empty state body
  ///
  /// In en, this message translates to:
  /// **'Ran-out things land here, and so does anything you add.'**
  String get shoppingListEmptyBody;

  /// Flow 04 - Shopping list. Accessibility label / swipe action that removes an entry
  ///
  /// In en, this message translates to:
  /// **'Remove from list'**
  String get shoppingListRemove;

  /// Flow 04 - Share as text. Screen 07. Sheet title
  ///
  /// In en, this message translates to:
  /// **'Send the list'**
  String get shareListTitle;

  /// Flow 04 - Share as text. Screen 07. Heading line of the shared plain-text list
  ///
  /// In en, this message translates to:
  /// **'PartyBar — shopping list'**
  String get shareListHeading;

  /// Flow 04 - Share as text. Screen 07. Note explaining the share format
  ///
  /// In en, this message translates to:
  /// **'Plain text — whoever gets it needs no app'**
  String get shareListPlainNote;

  /// Flow 04 - Share as text. Screen 07. Opens the platform share sheet
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get shareListShare;

  /// Flow 04 - Share as text. Screen 07. Copies the list text to the clipboard
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get shareListCopy;

  /// Flow 04 - Share as text. Screen 07. Confirmation after copying
  ///
  /// In en, this message translates to:
  /// **'List copied'**
  String get shareListCopied;

  /// Flow 04 - Share as text. Screen 07. Toggle that appends the reason to each line
  ///
  /// In en, this message translates to:
  /// **'Include why each one is needed'**
  String get shareListIncludeWhy;

  /// Flow 04 - What ran out. Screen 08. Subtitle summarising drinks poured this party
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 drink poured} other{{count} drinks poured}}'**
  String ranOutDrinksPoured(int count);

  /// Flow 04 - What ran out. Screen 08. Headline
  ///
  /// In en, this message translates to:
  /// **'Anything run out?'**
  String get ranOutTitle;

  /// Flow 04 - What ran out. Screen 08. Body copy
  ///
  /// In en, this message translates to:
  /// **'Tap what is gone. Everything you skip stays on the shelf — we never guess from what was poured.'**
  String get ranOutBody;

  /// Flow 04 - What ran out. Screen 08. Subtitle on a row tapped as ran out
  ///
  /// In en, this message translates to:
  /// **'Gone · going on your list'**
  String get ranOutGone;

  /// Flow 04 - What ran out. Screen 08. Subtitle noting how many times an item was poured tonight
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Poured once tonight} other{Poured {count} times tonight}}'**
  String ranOutPoured(int count);

  /// Flow 04 - What ran out. Screen 08. Primary button label
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Update my bar} other{Update my bar · {count} gone}}'**
  String ranOutUpdate(int count);

  /// Flow 04 - What ran out. Screen 08. Ghost action that skips the screen with nothing marked
  ///
  /// In en, this message translates to:
  /// **'Nothing ran out'**
  String get ranOutNothing;

  /// Flow 04 - What ran out. Screen 08. Empty state when the shelf has nothing stocked
  ///
  /// In en, this message translates to:
  /// **'Nothing on the shelf to check.'**
  String get ranOutEmpty;

  /// Flow 04 - Two away. Screen 09. Eyebrow above the headline
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =2{Two things short} other{{count} things short}}'**
  String twoAwayEyebrow(int count);

  /// Flow 04 - Two away. Screen 09. Headline naming how many required ingredients the shelf already has
  ///
  /// In en, this message translates to:
  /// **'You have {have} of the {total}'**
  String twoAwayTitle(int have, int total);

  /// Flow 04 - Two away. Screen 09. Body copy under the headline
  ///
  /// In en, this message translates to:
  /// **'Everything else is on your shelf already.'**
  String get twoAwayBody;

  /// Flow 04 - Two away. Screen 09. Suffix on a missing ingredient naming how many other drinks it also blocks
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{only this one} =1{also blocks 1 more} other{also blocks {count} more}}'**
  String twoAwayAlsoBlocks(int count);

  /// Flow 04 - Two away. Screen 09. Primary button adding every missing ingredient to the shopping list
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =2{Add both to my list} other{Add all {count} to my list}}'**
  String twoAwayAddToList(int count);

  /// Flow 04 - Two away. Screen 09. Secondary action that stocks the missing ingredients instead
  ///
  /// In en, this message translates to:
  /// **'I actually have these'**
  String get twoAwayHaveThese;

  /// Flow 04 - Two away. Screen 09. Footnote explaining the secondary action
  ///
  /// In en, this message translates to:
  /// **'“I have these” adds them to your bar — the only place stock is ever corrected.'**
  String get twoAwayFootnote;

  /// Flow 04 - Two away. Prompt elsewhere in Explore that opens the two-away sheet
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 thing short · see what} other{{count} things short · see what}}'**
  String twoAwayPrompt(int count);

  /// Flow 04 - Two away. Screen 09. Confirmation state after adding an ingredient to the shopping list
  ///
  /// In en, this message translates to:
  /// **'On your list'**
  String get twoAwayAddedToList;

  /// Flow 04 - Two away. Screen 09. Confirmation state after adding an ingredient to the bar
  ///
  /// In en, this message translates to:
  /// **'On your shelf'**
  String get twoAwayAddedToBar;

  /// Flow 05 - Host. Screen 01. Status pill over the hero when the host has no live party
  ///
  /// In en, this message translates to:
  /// **'Bar closed'**
  String get hostBarClosed;

  /// Flow 05 - Host. Screen 01. Headline over the hero photo; keep the line break
  ///
  /// In en, this message translates to:
  /// **'Nothing\npouring yet'**
  String get hostNothingPouring;

  /// Flow 05 - Host. Screen 01. Body under the headline
  ///
  /// In en, this message translates to:
  /// **'Set a name and a menu. Two minutes, and your kitchen takes orders.'**
  String get hostNothingPouringBody;

  /// Flow 05 - Host. Screen 01. Primary action that starts the draft
  ///
  /// In en, this message translates to:
  /// **'Host a party'**
  String get hostPartyCta;

  /// Flow 05 - Host. Screen 01. Secondary action into Flow 07
  ///
  /// In en, this message translates to:
  /// **'Join with a code'**
  String get hostJoinWithCode;

  /// Flow 05 - Host. Screen 01. Meta line on a draft party card
  ///
  /// In en, this message translates to:
  /// **'Draft · {count} on the menu · saved {time}'**
  String hostDraftMeta(int count, String time);

  /// Flow 05 - Host. Screen 01. Meta line on the card of a party that is still live
  ///
  /// In en, this message translates to:
  /// **'Live now · {count} on the menu'**
  String hostLiveMeta(int count);

  /// Flow 05 - Host. Screen 01. Meta line on the card of an ended party
  ///
  /// In en, this message translates to:
  /// **'{count} poured'**
  String hostEndedMeta(int count);

  /// Flow 05 - Host. Screen 01. Pill on a draft card
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get hostResume;

  /// Flow 05 - Host. Screen 01. Pill on an ended party card
  ///
  /// In en, this message translates to:
  /// **'Recap'**
  String get hostRecap;

  /// Flow 05 - Host. Screen 01. Pill on a live party card
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get hostOpen;

  /// Flow 05 - Host. Screen 02. Step 1 headline; keep the line break
  ///
  /// In en, this message translates to:
  /// **'What are we\ncalling it?'**
  String get hostNameTitle;

  /// Flow 05 - Host. Screen 02. Body under the headline
  ///
  /// In en, this message translates to:
  /// **'Guests see this when they join. You can change it any time.'**
  String get hostNameBody;

  /// Flow 05 - Host. Screen 02. Placeholder in the empty name field
  ///
  /// In en, this message translates to:
  /// **'Party name'**
  String get hostNameHint;

  /// Flow 05 - Host. Screen 02. Name suggestion chip
  ///
  /// In en, this message translates to:
  /// **'Friday Night'**
  String get hostNameIdeaFriday;

  /// Flow 05 - Host. Screen 02. Name suggestion chip
  ///
  /// In en, this message translates to:
  /// **'Housewarming'**
  String get hostNameIdeaHousewarming;

  /// Flow 05 - Host. Screen 02. Name suggestion chip
  ///
  /// In en, this message translates to:
  /// **'Just Us Two'**
  String get hostNameIdeaJustUs;

  /// Flow 05 - Host. Screen 02. Eyebrow above the when toggles
  ///
  /// In en, this message translates to:
  /// **'When'**
  String get hostWhenLabel;

  /// Flow 05 - Host. Screen 02. When toggle: the party is tonight, open-ended
  ///
  /// In en, this message translates to:
  /// **'Tonight'**
  String get hostWhenTonight;

  /// Flow 05 - Host. Screen 02. When toggle that opens a date picker
  ///
  /// In en, this message translates to:
  /// **'Pick a date'**
  String get hostWhenPickDate;

  /// Flow 05 - Host. Screen 02. Info card explaining the code is dead until Go live
  ///
  /// In en, this message translates to:
  /// **'Nobody can join until you go live — take your time with the menu.'**
  String get hostCodeDeadNote;

  /// Flow 05 - Host. Screen 02. Button that advances to step 2
  ///
  /// In en, this message translates to:
  /// **'Next · the menu'**
  String get hostNextMenu;

  /// Flow 05 - Host. Snackbar when creating or saving a draft party fails
  ///
  /// In en, this message translates to:
  /// **'Couldn’t save the draft. Try again.'**
  String get hostDraftSaveFailed;

  /// Flow 05 - Host. Screen 03. Step 2 headline
  ///
  /// In en, this message translates to:
  /// **'What are you pouring?'**
  String get hostMenuTitle;

  /// Flow 05 - Host. Screen 03. Body under the headline; count is how many fetched cocktails the shelf can pour
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Nothing here is pourable from your bar yet — search, or see everything.} =1{One of these needs nothing you don’t already have.} other{{count} of these need nothing you don’t already have.}}'**
  String hostMenuBody(int count);

  /// Flow 05 - Host. Screen 03. Search field placeholder
  ///
  /// In en, this message translates to:
  /// **'Search cocktails'**
  String get hostMenuSearchHint;

  /// Flow 05 - Host. Screen 03. Selected chip: the grid shows only pourable cocktails
  ///
  /// In en, this message translates to:
  /// **'Can make {count}'**
  String hostMenuFilterCanMake(int count);

  /// Flow 05 - Host. Screen 03. Chip that opens the full labelled list (screen 05)
  ///
  /// In en, this message translates to:
  /// **'All cocktails'**
  String get hostMenuFilterAll;

  /// Flow 05 - Host. Screens 03 and 05. How many cocktails the draft menu holds
  ///
  /// In en, this message translates to:
  /// **'{count} on the menu'**
  String hostMenuCount(int count);

  /// Flow 05 - Host. Screen 03. Footer reassurance under the count
  ///
  /// In en, this message translates to:
  /// **'Add more later — even mid-party'**
  String get hostMenuAddLater;

  /// Flow 05 - Host. Screen 03. Button that saves the draft and opens it
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get hostMenuReview;

  /// Flow 05 - Host. Screens 03-05. Semantics label for adding a cocktail
  ///
  /// In en, this message translates to:
  /// **'Add {name} to the menu'**
  String hostMenuAdd(String name);

  /// Flow 05 - Host. Screens 03-05. Semantics label for removing a cocktail
  ///
  /// In en, this message translates to:
  /// **'Remove {name} from the menu'**
  String hostMenuRemove(String name);

  /// Flow 05 - Host. Screens 03-05. Error when the cocktail list fails to load
  ///
  /// In en, this message translates to:
  /// **'Couldn’t load cocktails.'**
  String get hostMenuLoadFailed;

  /// Flow 05 - Host. Retry action
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get hostRetry;

  /// Flow 05 - Host. Screen 04. Closes menu search
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get hostSearchDone;

  /// Flow 05 - Host. Screen 04. Eyebrow above the results; rendered uppercase
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 match} other{{count} matches}}'**
  String hostSearchMatches(int count);

  /// Flow 05 - Host. Screen 04. Label of the makeable-only switch
  ///
  /// In en, this message translates to:
  /// **'Only what I can make'**
  String get hostSearchOnlyMakeable;

  /// Flow 05 - Host. Screen 04. Badge when exactly one ingredient is missing; rendered uppercase
  ///
  /// In en, this message translates to:
  /// **'No {ingredient}'**
  String hostBadgeNo(String ingredient);

  /// Flow 05 - Host. Screen 04. Badge when several ingredients are missing; rendered uppercase
  ///
  /// In en, this message translates to:
  /// **'Missing {count}'**
  String hostBadgeMissing(int count);

  /// Flow 05 - Host. Screen 04. Badge when the shelf holds every required ingredient; rendered uppercase
  ///
  /// In en, this message translates to:
  /// **'All in stock'**
  String get hostBadgeAllInStock;

  /// Flow 05 - Host. Screen 04. Tip under results when some are short an ingredient
  ///
  /// In en, this message translates to:
  /// **'Add one anyway and {ingredient} goes on tonight’s shopping list.'**
  String hostSearchShoppingTip(String ingredient);

  /// Flow 05 - Host. Screen 04. Empty results
  ///
  /// In en, this message translates to:
  /// **'Nothing matches “{query}”.'**
  String hostSearchNoResults(String query);

  /// Flow 05 - Host. Screen 05. Header title
  ///
  /// In en, this message translates to:
  /// **'All cocktails'**
  String get hostAllTitle;

  /// Flow 05 - Host. Screen 05. Spirit filter chip that clears the filter
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get hostAllFilterAll;

  /// Flow 05 - Host. Screen 05. Section eyebrow for makeable cocktails; rendered uppercase
  ///
  /// In en, this message translates to:
  /// **'Ready to pour · {count}'**
  String hostAllReady(int count);

  /// Flow 05 - Host. Screen 05. Section eyebrow for cocktails the shelf cannot pour; rendered uppercase
  ///
  /// In en, this message translates to:
  /// **'Needs shopping · {count}'**
  String hostAllNeedsShopping(int count);

  /// Flow 05 - Host. Screen 05. Note beside the needs-shopping eyebrow
  ///
  /// In en, this message translates to:
  /// **'Sorted by what’s closest'**
  String get hostAllClosestFirst;

  /// Flow 05 - Host. Screen 05. Subtitle part on a ready row
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 ingredient} other{{count} ingredients}}'**
  String hostAllIngredientCount(int count);

  /// Flow 05 - Host. Screen 05. Subtitle on a needs-shopping row
  ///
  /// In en, this message translates to:
  /// **'{count} short · {ingredients}'**
  String hostAllShort(int count, String ingredients);

  /// Flow 05 - Host. Screen 05. Bottom button that returns to the menu step
  ///
  /// In en, this message translates to:
  /// **'Done · {count} on the menu'**
  String hostAllDone(int count);

  /// Flow 05 - Host. Screen 06. Sheet headline when one ingredient is missing; ingredient is lowercase
  ///
  /// In en, this message translates to:
  /// **'You’re one {ingredient} short'**
  String hostMissingOneTitle(String ingredient);

  /// Flow 05 - Host. Screen 06. Sheet headline when several ingredients are missing
  ///
  /// In en, this message translates to:
  /// **'You’re {count} things short'**
  String hostMissingManyTitle(int count);

  /// Flow 05 - Host. Screen 06. Sheet body
  ///
  /// In en, this message translates to:
  /// **'Put it on the menu anyway — guests can still order it, and you’ll see the shortage on your own screen, not theirs.'**
  String get hostMissingBody;

  /// Flow 05 - Host. Screen 06. Trailing label on a missing ingredient row
  ///
  /// In en, this message translates to:
  /// **'out of stock'**
  String get hostMissingOutOfStock;

  /// Flow 05 - Host. Screen 06. Primary action: add to the menu and put the missing ingredient on the shopping list
  ///
  /// In en, this message translates to:
  /// **'Add it & buy {ingredient}'**
  String hostMissingAddAndBuyOne(String ingredient);

  /// Flow 05 - Host. Screen 06. Primary action when several ingredients are missing
  ///
  /// In en, this message translates to:
  /// **'Add it & buy all {count}'**
  String hostMissingAddAndBuyMany(int count);

  /// Flow 05 - Host. Screen 06. Secondary action back to the pourable grid
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Show what I can make} =1{Show me 1 I can make} other{Show me {count} I can make}}'**
  String hostMissingShowMakeable(int count);

  /// Flow 05 - Host. Screen 06. Footnote under the actions
  ///
  /// In en, this message translates to:
  /// **'Guests only see a “limited” note if you run dry mid-party.'**
  String get hostMissingFootnote;

  /// Flow 05 - Host. Screen 07. Status pill over the hero; rendered uppercase
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get hostDraftPill;

  /// Flow 05 - Host. Screen 07. Line under the party name when it is tonight
  ///
  /// In en, this message translates to:
  /// **'Tonight · {count} on the menu · you’re the bartender'**
  String hostDraftMetaTonight(int count);

  /// Flow 05 - Host. Screen 07. Line under the party name when it has a date
  ///
  /// In en, this message translates to:
  /// **'{date} · {count} on the menu · you’re the bartender'**
  String hostDraftMetaDate(String date, int count);

  /// Flow 05 - Host. Screen 07. Row that edits the menu
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get hostDraftMenuRow;

  /// Flow 05 - Host. Screens 07 and 11. Trailing count on the menu row
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 drink} other{{count} drinks}}'**
  String hostDraftDrinks(int count);

  /// Flow 05 - Host. Screen 07. Row that edits the date
  ///
  /// In en, this message translates to:
  /// **'When'**
  String get hostDraftWhenRow;

  /// Flow 05 - Host. Screen 07. Trailing value on the when row
  ///
  /// In en, this message translates to:
  /// **'Tonight, open-ended'**
  String get hostDraftTonightOpen;

  /// Flow 05 - Host. Screen 07. Dimmed row showing the not-yet-working code
  ///
  /// In en, this message translates to:
  /// **'Invite code'**
  String get hostDraftInviteRow;

  /// Flow 05 - Host. Screen 07. Tag on the invite code until the party goes live; rendered uppercase
  ///
  /// In en, this message translates to:
  /// **'Dead'**
  String get hostDraftDead;

  /// Flow 05 - Host. Screen 07. Shopping card title
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 thing to buy} other{{count} things to buy}}'**
  String hostDraftToBuy(int count);

  /// Flow 05 - Host. Screen 07. Shopping card body; both placeholders are comma-separated lists
  ///
  /// In en, this message translates to:
  /// **'{ingredients}. Until then you’ll be improvising {cocktails}.'**
  String hostDraftToBuyBody(String ingredients, String cocktails);

  /// Flow 05 - Host. Screen 07. Stat tile eyebrow; rendered uppercase
  ///
  /// In en, this message translates to:
  /// **'Can pour now'**
  String get hostDraftCanPour;

  /// Flow 05 - Host. Screen 07. Stat tile value
  ///
  /// In en, this message translates to:
  /// **'{ready} of {total}'**
  String hostDraftCanPourValue(int ready, int total);

  /// Flow 05 - Host. Screen 07. Primary action into the go-live confirmation
  ///
  /// In en, this message translates to:
  /// **'Go live & open the code'**
  String get hostGoLiveCta;

  /// Flow 05 - Host. Screen 07. Quiet action back to the Party tab
  ///
  /// In en, this message translates to:
  /// **'Save the draft for later'**
  String get hostSaveForLater;

  /// Flow 05 - Host. Screen 07. Error when the draft cannot be loaded
  ///
  /// In en, this message translates to:
  /// **'Couldn’t load this party.'**
  String get hostDraftLoadFailed;

  /// Flow 05 - Host. Screen 08. Go-live sheet headline
  ///
  /// In en, this message translates to:
  /// **'Open the bar?'**
  String get hostGoLiveTitle;

  /// Flow 05 - Host. Screen 08. Go-live sheet body
  ///
  /// In en, this message translates to:
  /// **'Here’s exactly what changes the moment you tap.'**
  String get hostGoLiveBody;

  /// Flow 05 - Host. Screen 08. First consequence row
  ///
  /// In en, this message translates to:
  /// **'{code} starts working'**
  String hostGoLiveCodeWorks(String code);

  /// Flow 05 - Host. Screen 08. First consequence row detail
  ///
  /// In en, this message translates to:
  /// **'Anyone with the code or QR can join'**
  String get hostGoLiveCodeWorksSub;

  /// Flow 05 - Host. Screen 08. Second consequence row
  ///
  /// In en, this message translates to:
  /// **'Orders start hitting your phone'**
  String get hostGoLiveOrders;

  /// Flow 05 - Host. Screen 08. Second consequence row detail
  ///
  /// In en, this message translates to:
  /// **'The queue lives behind Open the bar'**
  String get hostGoLiveOrdersSub;

  /// Flow 05 - Host. Screen 08. Third consequence row
  ///
  /// In en, this message translates to:
  /// **'Nothing here is final'**
  String get hostGoLiveUndo;

  /// Flow 05 - Host. Screen 08. Third consequence row detail
  ///
  /// In en, this message translates to:
  /// **'Pause the bar or edit the menu any time'**
  String get hostGoLiveUndoSub;

  /// Flow 05 - Host. Screen 08. The commit
  ///
  /// In en, this message translates to:
  /// **'Go live'**
  String get hostGoLive;

  /// Flow 05 - Host. Screen 08. Dismisses the go-live sheet
  ///
  /// In en, this message translates to:
  /// **'Not yet'**
  String get hostNotYet;

  /// Flow 05 - Host. Screen 08. Footnote
  ///
  /// In en, this message translates to:
  /// **'One live party at a time'**
  String get hostOneLiveParty;

  /// Flow 05 - Host. Edge state. Sheet when another party is live
  ///
  /// In en, this message translates to:
  /// **'{name} is still live'**
  String hostSecondLiveTitle(String name);

  /// Flow 05 - Host. Edge state. Second-party sheet body
  ///
  /// In en, this message translates to:
  /// **'One bar at a time — end that party and its recap is saved before the new one opens.'**
  String get hostSecondLiveBody;

  /// Flow 05 - Host. Edge state. Opens the party that is still live
  ///
  /// In en, this message translates to:
  /// **'Go to {name}'**
  String hostGoToParty(String name);

  /// Flow 05 - Host. Edge state. Ends the live party, then opens this one
  ///
  /// In en, this message translates to:
  /// **'End it and start fresh'**
  String get hostEndAndStartFresh;

  /// Flow 05 - Host. Edge state. Sheet before going live with no drinks
  ///
  /// In en, this message translates to:
  /// **'Open with nothing on the menu?'**
  String get hostEmptyMenuTitle;

  /// Flow 05 - Host. Edge state. Empty-menu sheet body
  ///
  /// In en, this message translates to:
  /// **'Guests can still join and ask for whatever they like — you just take requests instead of orders.'**
  String get hostEmptyMenuBody;

  /// Flow 05 - Host. Edge state. Continues to go live with an empty menu
  ///
  /// In en, this message translates to:
  /// **'Open as a request bar'**
  String get hostOpenAsRequestBar;

  /// Flow 05 - Host. Edge state. Opens the menu instead
  ///
  /// In en, this message translates to:
  /// **'Add a couple first'**
  String get hostAddACoupleFirst;

  /// Flow 05 - Host. Screens 09-11. Live pill; elapsed is like 1h12m; rendered uppercase
  ///
  /// In en, this message translates to:
  /// **'Live · {elapsed}'**
  String hostLivePill(String elapsed);

  /// Flow 05 - Host. Screen 09. Headline above the QR
  ///
  /// In en, this message translates to:
  /// **'The bar is open'**
  String get hostBarOpenTitle;

  /// Flow 05 - Host. Screen 09. Body above the QR
  ///
  /// In en, this message translates to:
  /// **'Point a camera at this. No app, no account — just a name.'**
  String get hostBarOpenBody;

  /// Flow 05 - Host. Screen 09. Semantics for the code chip
  ///
  /// In en, this message translates to:
  /// **'Copy code'**
  String get hostCopyCode;

  /// Flow 05 - Host. Screen 09. Snackbar after copying the code
  ///
  /// In en, this message translates to:
  /// **'Code copied'**
  String get hostCodeCopied;

  /// Flow 05 - Host. Screen 09. Primary action: system share sheet
  ///
  /// In en, this message translates to:
  /// **'Share the link'**
  String get hostShareLink;

  /// Flow 05 - Host. Screen 09. Secondary action to the live hub
  ///
  /// In en, this message translates to:
  /// **'Go to the party'**
  String get hostGoToTheParty;

  /// Flow 05 - Host. Screen 09. Text handed to the share sheet
  ///
  /// In en, this message translates to:
  /// **'Join {name} on PartyBar with code {code}'**
  String hostShareText(String name, String code);

  /// Flow 05 - Host. Screen 10. Line above the party name; here counts distinct guests who ordered
  ///
  /// In en, this message translates to:
  /// **'{here} here · {poured} poured'**
  String hostHereAndPoured(int here, int poured);

  /// Flow 05 - Host. Screen 10. Primary action into the order queue; a badge shows waiting orders
  ///
  /// In en, this message translates to:
  /// **'Open the bar'**
  String get hostOpenTheBar;

  /// Flow 05 - Host. Screen 10. Rail title
  ///
  /// In en, this message translates to:
  /// **'On the menu tonight'**
  String get hostOnTheMenuTonight;

  /// Flow 05 - Host. Screens 10 and 12. Quiet edit link
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get hostEdit;

  /// Flow 05 - Host. Screen 10. Semantics for the QR button
  ///
  /// In en, this message translates to:
  /// **'Show the QR code'**
  String get hostShowQr;

  /// Flow 05 - Host. Screen 10. Semantics for the share button
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get hostShare;

  /// Flow 05 - Host. Screens 10-12. Manage button semantics and the manage sheet title
  ///
  /// In en, this message translates to:
  /// **'Manage the party'**
  String get hostManage;

  /// Flow 05 - Host. Screen 10. Shown instead of the rail when the menu is empty
  ///
  /// In en, this message translates to:
  /// **'Nothing on the menu — guests send requests.'**
  String get hostMenuEmptyRequests;

  /// Flow 05 - Host. Screen 10. Badge on a menu tile the shelf can no longer pour; rendered uppercase
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get hostLowBadge;

  /// Flow 05 - Host. Screen 11. Line under the manage sheet title
  ///
  /// In en, this message translates to:
  /// **'Live {elapsed} · {guests} here · {waiting} waiting'**
  String hostManageSub(String elapsed, int guests, int waiting);

  /// Flow 05 - Host. Screen 11. Chip beside the manage sheet title; rendered uppercase
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get hostLiveChip;

  /// Flow 05 - Host. Screens 11 and 13. The panic button
  ///
  /// In en, this message translates to:
  /// **'Pause the bar'**
  String get hostPauseBar;

  /// Flow 05 - Host. Screen 11. Caption under the pause button
  ///
  /// In en, this message translates to:
  /// **'Stops new orders. Guests see “back in a minute”.'**
  String get hostPauseCaption;

  /// Flow 05 - Host. Screen 11. Row that opens the menu editor
  ///
  /// In en, this message translates to:
  /// **'Edit tonight’s menu'**
  String get hostEditTonightsMenu;

  /// Flow 05 - Host. Screen 11. Row that opens the QR screen
  ///
  /// In en, this message translates to:
  /// **'Invite more people'**
  String get hostInviteMore;

  /// Flow 05 - Host. Screen 11. Row with the guest count
  ///
  /// In en, this message translates to:
  /// **'Who’s here'**
  String get hostWhosHere;

  /// Flow 05 - Host. Screen 11. Disabled row, a seam for later
  ///
  /// In en, this message translates to:
  /// **'Add a co-host'**
  String get hostAddCoHost;

  /// Flow 05 - Host. Screen 11. Tag on the co-host row; rendered uppercase
  ///
  /// In en, this message translates to:
  /// **'Soon'**
  String get hostSoon;

  /// Flow 05 - Host. Screen 11. Row that opens the end confirmation
  ///
  /// In en, this message translates to:
  /// **'End the party'**
  String get hostEndParty;

  /// Flow 05 - Host. Screen 11. Trailing hint on the end row: ending opens the ran-out checklist
  ///
  /// In en, this message translates to:
  /// **'then what ran out'**
  String get hostEndPartyHint;

  /// Flow 05 - Host. Snackbar when a change to a live party fails
  ///
  /// In en, this message translates to:
  /// **'Couldn’t save that. Try again.'**
  String get hostSaveFailed;

  /// Flow 05 - Host. Screen 12. Amber pill; elapsed is like 6m or 1h05m; rendered uppercase
  ///
  /// In en, this message translates to:
  /// **'Bar paused · {elapsed}'**
  String hostPausedPill(String elapsed);

  /// Flow 05 - Host. Screen 12. Headline over the photo; keep the line break
  ///
  /// In en, this message translates to:
  /// **'Bar’s shut\nfor a minute'**
  String get hostPausedTitle;

  /// Flow 05 - Host. Screen 12. Body; count is orders still waiting
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Nobody can order, and your queue is empty.} =1{Nobody can order. The 1 order already in your queue is still yours to pour.} other{Nobody can order. The {count} orders already in your queue are still yours to pour.}}'**
  String hostPausedBody(int count);

  /// Flow 05 - Host. Screen 12. Primary action back to live
  ///
  /// In en, this message translates to:
  /// **'Reopen the bar'**
  String get hostReopenBar;

  /// Flow 05 - Host. Screen 12. Card title
  ///
  /// In en, this message translates to:
  /// **'Guests are seeing'**
  String get hostGuestsSeeing;

  /// Flow 05 - Host. Screen 12. The message guests see while paused
  ///
  /// In en, this message translates to:
  /// **'Back in a minute'**
  String get hostBackInAMinute;

  /// Flow 05 - Host. Screen 12. Detail under the guest message
  ///
  /// In en, this message translates to:
  /// **'Menu is visible · ordering is off'**
  String get hostMenuVisibleOrderingOff;

  /// Flow 05 - Host. Screen 12. Stat eyebrow; rendered uppercase
  ///
  /// In en, this message translates to:
  /// **'In queue'**
  String get hostInQueue;

  /// Flow 05 - Host. Screen 12. Stat value
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 order} other{{count} orders}}'**
  String hostOrdersCount(int count);

  /// Flow 05 - Host. Screen 12. Stat eyebrow; rendered uppercase
  ///
  /// In en, this message translates to:
  /// **'Still here'**
  String get hostStillHere;

  /// Flow 05 - Host. Screens 12 and 13. Guest count
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 guest} other{{count} guests}}'**
  String hostGuestsCount(int count);

  /// Flow 05 - Host. Screen 13. End sheet headline
  ///
  /// In en, this message translates to:
  /// **'Call it a night?'**
  String get hostEndTitle;

  /// Flow 05 - Host. Screen 13. End sheet body
  ///
  /// In en, this message translates to:
  /// **'The code stops working and the queue closes. This one can’t be undone.'**
  String get hostEndBody;

  /// Flow 05 - Host. Screen 13. Warning when orders are still in the queue
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 order is still waiting} other{{count} orders are still waiting}}'**
  String hostEndWaiting(int count);

  /// Flow 05 - Host. Screen 13. Detail under the waiting warning
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{It will be marked unserved} other{They will be marked unserved}}'**
  String hostEndWaitingDetail(int count);

  /// Flow 05 - Host. Screen 13. Stat eyebrow; rendered uppercase
  ///
  /// In en, this message translates to:
  /// **'Poured'**
  String get hostEndPoured;

  /// Flow 05 - Host. Screen 13. Stat eyebrow; rendered uppercase
  ///
  /// In en, this message translates to:
  /// **'Guests'**
  String get hostEndGuests;

  /// Flow 05 - Host. Screen 13. Stat eyebrow; rendered uppercase
  ///
  /// In en, this message translates to:
  /// **'Open for'**
  String get hostEndOpenFor;

  /// Flow 05 - Host. Screen 13. The one-way commit; opens the ran-out checklist
  ///
  /// In en, this message translates to:
  /// **'End & check what ran out'**
  String get hostEndConfirm;

  /// Flow 05 - Host. Screen 13. Dismisses the end sheet
  ///
  /// In en, this message translates to:
  /// **'Keep pouring'**
  String get hostKeepPouring;

  /// Flow 05 - Host. Screen 13. Footnote lead-in
  ///
  /// In en, this message translates to:
  /// **'Just need a break?'**
  String get hostJustNeedBreak;

  /// Flow 05 - Host. Screen 13. Footnote link that pauses instead of ending
  ///
  /// In en, this message translates to:
  /// **'Pause the bar instead'**
  String get hostPauseInstead;

  /// Flow 06 - Order & pour. Screens 09/11. The queue screen's title
  ///
  /// In en, this message translates to:
  /// **'The bar'**
  String get queueBarTitle;

  /// Flow 06 - Order & pour. Screens 09/11. Semantics for the header back button
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get queueBack;

  /// Flow 06 - Order & pour. Screens 09/11. Semantics/tooltip for the pause icon while the bar is active
  ///
  /// In en, this message translates to:
  /// **'Pause the bar'**
  String get queuePause;

  /// Flow 06 - Order & pour. Screen 09. Header subline when nothing is on the counter
  ///
  /// In en, this message translates to:
  /// **'{inLine} in line · {poured} poured tonight'**
  String queueSublineInLine(int inLine, int poured);

  /// Flow 06 - Order & pour. Screen 11. Header subline once something is ready
  ///
  /// In en, this message translates to:
  /// **'{onCounter} on the counter · {inLine} in line'**
  String queueSublineOnCounter(int onCounter, int inLine);

  /// Flow 06 - Order & pour. Screens 09/11. Amber paused row title
  ///
  /// In en, this message translates to:
  /// **'Guests can\'t order right now'**
  String get queuePausedRowTitle;

  /// Flow 06 - Order & pour. Screens 09/11. Amber paused row body
  ///
  /// In en, this message translates to:
  /// **'The bar is paused — reopen it whenever you\'re ready.'**
  String get queuePausedRowBody;

  /// Flow 06 - Order & pour. Screen 11. Section eyebrow
  ///
  /// In en, this message translates to:
  /// **'On the counter'**
  String get queueOnTheCounterEyebrow;

  /// Flow 06 - Order & pour. Screen 11. On-the-counter row, drink is for the sender
  ///
  /// In en, this message translates to:
  /// **'{guest} · buzzed {wait} ago'**
  String queueGuestBuzzed(String guest, String wait);

  /// Flow 06 - Order & pour. Screen 11. On-the-counter row, drink is for a friend
  ///
  /// In en, this message translates to:
  /// **'{guest}, for {forName} · buzzed {wait} ago'**
  String queueGuestBuzzedForFriend(String guest, String forName, String wait);

  /// Flow 06 - Order & pour. Screen 11. Primary button that marks an order served
  ///
  /// In en, this message translates to:
  /// **'Handed it over'**
  String get queueHandedOver;

  /// Flow 06 - Order & pour. Screen 11. Re-sends the ready notification
  ///
  /// In en, this message translates to:
  /// **'Buzz again'**
  String get queueBuzzAgain;

  /// Flow 06 - Order & pour. Screen 11. Undoes a ready put up by mistake
  ///
  /// In en, this message translates to:
  /// **'Back to mixing'**
  String get queueBackToMixing;

  /// Flow 06 - Order & pour. Screen 11. Snackbar after Buzz again
  ///
  /// In en, this message translates to:
  /// **'Buzzed {guest} again'**
  String queueBuzzedAgainSnack(String guest);

  /// Flow 06 - Order & pour. Screens 09/11. Section eyebrow for orders being poured
  ///
  /// In en, this message translates to:
  /// **'Pouring now'**
  String get queuePouringEyebrow;

  /// Flow 06 - Order & pour. Screen 09. Section eyebrow
  ///
  /// In en, this message translates to:
  /// **'Next up'**
  String get queueNextUpEyebrow;

  /// Flow 06 - Order & pour. Screens 09/11. Next up / in line row, drink is for the sender
  ///
  /// In en, this message translates to:
  /// **'{guest} · waiting {wait}'**
  String queueGuestWaiting(String guest, String wait);

  /// Flow 06 - Order & pour. Screens 09/11. Next up / in line row, drink is for a friend
  ///
  /// In en, this message translates to:
  /// **'{guest}, for {forName} · waiting {wait}'**
  String queueGuestWaitingForFriend(String guest, String forName, String wait);

  /// Flow 06 - Order & pour. Screen 09. Next up primary button
  ///
  /// In en, this message translates to:
  /// **'Start pouring'**
  String get queueStartPouring;

  /// Flow 06 - Order & pour. Screens 09/11/10. Skips an order; reused as the row sheet and skip-confirm actions
  ///
  /// In en, this message translates to:
  /// **'Skip · can\'t make it'**
  String get queueSkipCantMake;

  /// Flow 06 - Order & pour. Screen 09. Next up chip: ingredient count and build method
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 ingredient} other{{count} ingredients}} · {method}'**
  String queueIngredientsMethodChip(int count, String method);

  /// Flow 06 - Order & pour. Screens 08/09/10/11. Short pour action label, reused as the pour eyebrow
  ///
  /// In en, this message translates to:
  /// **'Pour'**
  String get queuePourPill;

  /// Flow 06 - Order & pour. Screen 09. In line section eyebrow
  ///
  /// In en, this message translates to:
  /// **'In line · {count}'**
  String queueInLineHeader(int count);

  /// Flow 06 - Order & pour. Screen 09. In line section's sort note
  ///
  /// In en, this message translates to:
  /// **'Oldest first'**
  String get queueOldestFirst;

  /// Flow 06 - Order & pour. Screen 09. Tag on an order under a minute old
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get queueNewTag;

  /// Flow 06 - Order & pour. Screen 09. In line row's tap sheet, primary action
  ///
  /// In en, this message translates to:
  /// **'Pour now'**
  String get queueRowSheetPourNow;

  /// Flow 06 - Order & pour. Screen 09. Skip confirmation sheet title
  ///
  /// In en, this message translates to:
  /// **'Skip {name}?'**
  String queueSkipConfirmTitle(String name);

  /// Flow 06 - Order & pour. Screen 09. Skip confirmation sheet body
  ///
  /// In en, this message translates to:
  /// **'They\'ll be told it\'s not coming. This can\'t be undone.'**
  String get queueSkipConfirmBody;

  /// Flow 06 - Order & pour. Screen 09. Skip confirmation sheet dismiss
  ///
  /// In en, this message translates to:
  /// **'Never mind'**
  String get queueSkipConfirmCancel;

  /// Flow 06 - Order & pour. Screen 11. Stats card label
  ///
  /// In en, this message translates to:
  /// **'Poured'**
  String get queueStatPoured;

  /// Flow 06 - Order & pour. Screen 11. Stats card label
  ///
  /// In en, this message translates to:
  /// **'Avg wait'**
  String get queueStatAvgWait;

  /// Flow 06 - Order & pour. Screen 11. Stats card label
  ///
  /// In en, this message translates to:
  /// **'Top drink'**
  String get queueStatTopDrink;

  /// Flow 06 - Order & pour. Screen 11. Stats card value before there is one to show
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get queueStatEmpty;

  /// Flow 06 - Order & pour. Screens 09/11. Empty queue message
  ///
  /// In en, this message translates to:
  /// **'Nobody\'s waiting — orders land here the second they\'re sent.'**
  String get queueEmptyBody;

  /// Flow 06 - Order & pour. Screens 09/11. Empty queue button that opens the invite QR
  ///
  /// In en, this message translates to:
  /// **'Show the QR'**
  String get queueEmptyShowQr;

  /// Flow 06 - Order & pour. Screen 10. Header pill with the running stopwatch
  ///
  /// In en, this message translates to:
  /// **'Pouring · {time}'**
  String queuePouringPill(String time);

  /// Flow 06 - Order & pour. Screen 10. Header line, drink is for the sender
  ///
  /// In en, this message translates to:
  /// **'for {guest} · #{position} in line'**
  String queueForGuestPosition(String guest, int position);

  /// Flow 06 - Order & pour. Screen 10. Header line, drink is for a friend
  ///
  /// In en, this message translates to:
  /// **'for {forName} · from {guest}'**
  String queueForGuestFromSender(String forName, String guest);

  /// Flow 06 - Order & pour. Screen 10. Amber note callout eyebrow
  ///
  /// In en, this message translates to:
  /// **'{guest} asked for'**
  String queueNoteLabel(String guest);

  /// Flow 06 - Order & pour. Screen 10. Row that opens the method sheet
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{How {host} makes it · 1 step} other{How {host} makes it · {count} steps}}'**
  String queueHowHostMakesItRow(String host, int count);

  /// Flow 06 - Order & pour. Screens 10/10b. Primary button that marks an order ready
  ///
  /// In en, this message translates to:
  /// **'Ready — buzz {guest}'**
  String queueReadyBuzz(String guest);

  /// Flow 06 - Order & pour. Screen 10. Opens the out-of-stock flow
  ///
  /// In en, this message translates to:
  /// **'Out of something'**
  String get queueOutOfSomething;

  /// Flow 06 - Order & pour. Screen 10. Cancels the order being poured; reused as the confirm sheet's action
  ///
  /// In en, this message translates to:
  /// **'Cancel order'**
  String get queueCancelOrder;

  /// Flow 06 - Order & pour. Screen 10. Cancel confirmation sheet title
  ///
  /// In en, this message translates to:
  /// **'Cancel {name}?'**
  String queueCancelOrderConfirmTitle(String name);

  /// Flow 06 - Order & pour. Screen 10. Cancel confirmation sheet body
  ///
  /// In en, this message translates to:
  /// **'{guest} will be told it\'s cancelled. This can\'t be undone.'**
  String queueCancelOrderConfirmBody(String guest);

  /// Flow 06 - Order & pour. Screen 10. Cancel confirmation sheet dismiss
  ///
  /// In en, this message translates to:
  /// **'Keep pouring'**
  String get queueCancelOrderConfirmKeep;

  /// Flow 06 - Order & pour. Screen 10b. Sheet title
  ///
  /// In en, this message translates to:
  /// **'How {host} makes it'**
  String queueMethodSheetTitle(String host);

  /// Flow 06 - Order & pour. Screen 10b. Sheet subtitle
  ///
  /// In en, this message translates to:
  /// **'{cocktail} · {method}'**
  String queueMethodSubtitle(String cocktail, String method);

  /// Flow 06 - Order & pour. Screen 10b. Prep time chip
  ///
  /// In en, this message translates to:
  /// **'~{minutes} min'**
  String queueMethodMinutes(int minutes);

  /// Flow 06 - Order & pour. Screen 10b. Countdown chip on a timed step
  ///
  /// In en, this message translates to:
  /// **'{seconds} s'**
  String queueMethodTimerSeconds(int seconds);

  /// Flow 06 - Order & pour. Screen 12. First sheet's title, for a multi-ingredient drink
  ///
  /// In en, this message translates to:
  /// **'What ran out?'**
  String get queueWhatRanOutTitle;

  /// Flow 06 - Order & pour. Screen 12. Out-of sheet title
  ///
  /// In en, this message translates to:
  /// **'Out of {ingredient}?'**
  String queueOutOfTitle(String ingredient);

  /// Flow 06 - Order & pour. Screen 12. Out-of sheet subtitle
  ///
  /// In en, this message translates to:
  /// **'Bottle\'s empty · {count, plural, =1{1 drink uses it} other{{count} drinks use it}}'**
  String queueOutOfSubtitle(int count);

  /// Flow 06 - Order & pour. Screen 12. Per-drink row detail
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{nobody waiting} =1{1 waiting in the queue} other{{count} waiting in the queue}}'**
  String queueWaitingInQueue(int count);

  /// Flow 06 - Order & pour. Screen 12. Amber aside title, naming the first affected guest
  ///
  /// In en, this message translates to:
  /// **'{guest} gets told, with options'**
  String queueGuestsToldTitle(String guest);

  /// Flow 06 - Order & pour. Screen 12. Amber aside title when nobody is waiting yet
  ///
  /// In en, this message translates to:
  /// **'Guests get told, with options'**
  String get queueGuestsToldGeneric;

  /// Flow 06 - Order & pour. Screen 12. Amber aside detail
  ///
  /// In en, this message translates to:
  /// **'“{host} ran out of {ingredient}” — plus drinks still pourable, one tap to swap.'**
  String queueGuestsToldBody(String host, String ingredient);

  /// Flow 06 - Order & pour. Screen 12. Primary button
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Pull 1 drink from the menu} other{Pull {count} drinks from the menu}}'**
  String queuePullDrinks(int count);

  /// Flow 06 - Order & pour. Screen 12. Ghost button that pulls just the order being poured
  ///
  /// In en, this message translates to:
  /// **'Only this order — keep them on the menu'**
  String get queueKeepOnMenu;

  /// Flow 06 - Order & pour. Screen 08. Landed-order banner title
  ///
  /// In en, this message translates to:
  /// **'{guest} ordered {count, plural, =1{1 drink} other{{count} drinks}}'**
  String queueOrderLandedTitle(String guest, int count);

  /// Flow 06 - Order & pour. Screen 08. Suffix naming who a drink in the landed banner is for
  ///
  /// In en, this message translates to:
  /// **'for {name}'**
  String queueForFriend(String name);

  /// Flow 06 - Order & pour. Screen 08. Card title replacing the menu rail once orders are queued
  ///
  /// In en, this message translates to:
  /// **'Waiting on you'**
  String get queueWaitingOnYouTitle;

  /// Flow 06 - Order & pour. Screen 08. Waiting-on-you card's mono count
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 in line} other{{count} in line}}'**
  String queueInLineBadge(int count);

  /// Flow 06 - Order & pour. Screen 08. Waiting-on-you row
  ///
  /// In en, this message translates to:
  /// **'{drink} · {guest}'**
  String queueDrinkForGuest(String drink, String guest);

  /// Flow 06 - Order & pour. Guest shell. Bottom nav label for the arrival/round tab.
  ///
  /// In en, this message translates to:
  /// **'Tonight'**
  String get roundNavTonight;

  /// Flow 06 - Order & pour. Guest shell. Bottom nav label for the guest's own orders tab.
  ///
  /// In en, this message translates to:
  /// **'Your round'**
  String get roundNavYourRound;

  /// Flow 06 - Order & pour. Guest shell. Floating pill above the nav bar while a round is being built; reopens screen 02
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Your round · 1} other{Your round · {count}}}'**
  String roundPill(int count);

  /// Flow 06 - Order & pour. Guest shell. Title of the minimal paused notice
  ///
  /// In en, this message translates to:
  /// **'The bar\'s paused'**
  String get roundPausedTitle;

  /// Flow 06 - Order & pour. Guest shell. Body of the paused notice
  ///
  /// In en, this message translates to:
  /// **'{host} isn\'t pouring right now — you can browse the menu, but sending is off until it reopens.'**
  String roundPausedBody(String host);

  /// Flow 06 - Order & pour. Guest shell. Title of the calm ended state
  ///
  /// In en, this message translates to:
  /// **'The bar\'s closed'**
  String get roundEndedTitle;

  /// Flow 06 - Order & pour. Guest shell. Body of the ended state
  ///
  /// In en, this message translates to:
  /// **'{party} has ended. Thanks for stopping by.'**
  String roundEndedBody(String party);

  /// Flow 06 - Order & pour. Guest shell. Way out of the ended state; pops the screen
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get roundEndedLeave;

  /// Flow 06 - Order & pour. Screens 01, Tonight arrival. Glass pill over the hero photo
  ///
  /// In en, this message translates to:
  /// **'Bar open'**
  String get roundBarOpenPill;

  /// Flow 06 - Order & pour. Tonight tab, arrival view. Who is here, counted by distinct guest name
  ///
  /// In en, this message translates to:
  /// **'{host} is pouring · {count, plural, =1{1 here tonight} other{{count} here tonight}}'**
  String roundHostPouring(String host, int count);

  /// Flow 06 - Order & pour. Tonight tab, arrival view. Section heading over the menu tiles
  ///
  /// In en, this message translates to:
  /// **'On the menu tonight'**
  String get roundOnMenuTonight;

  /// Flow 06 - Order & pour. Tonight tab, arrival view. Link that opens the Menu tab
  ///
  /// In en, this message translates to:
  /// **'All {count}'**
  String roundSeeAll(int count);

  /// Flow 06 - Order & pour. Screen 04/05. Header line under the party name
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Bar open · 1 here} other{Bar open · {count} here}}'**
  String roundPartyOpenGuests(int count);

  /// Flow 06 - Order & pour. Screen 04. Uppercase eyebrow on the round card
  ///
  /// In en, this message translates to:
  /// **'Your round'**
  String get roundYourRoundEyebrow;

  /// Flow 06 - Order & pour. Screen 04. Timestamp on the round card, rendered mono/uppercase
  ///
  /// In en, this message translates to:
  /// **'Sent {time}'**
  String roundSentAt(String time);

  /// Flow 06 - Order & pour. Screen 04. Shown when the guest's lead order is #1 in line
  ///
  /// In en, this message translates to:
  /// **'your turn — {drink}'**
  String roundYoureNext(String drink);

  /// Flow 06 - Order & pour. Screen 04. Shown when the guest's lead order is not yet #1
  ///
  /// In en, this message translates to:
  /// **'in line — {drink}'**
  String roundInLine(String drink);

  /// Flow 06 - Order & pour. Screens 04/05. Progress bar segment label
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get roundStageSent;

  /// Flow 06 - Order & pour. Screens 04/05. Progress bar segment label
  ///
  /// In en, this message translates to:
  /// **'In line'**
  String get roundStageInLine;

  /// Flow 06 - Order & pour. Screens 04/05. Progress bar segment label
  ///
  /// In en, this message translates to:
  /// **'Mixing'**
  String get roundStageMixing;

  /// Flow 06 - Order & pour. Screens 04/05. Progress bar segment label
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get roundStageReady;

  /// Flow 06 - Order & pour. Screen 04 round-mate row, and the Your round tab status chip
  ///
  /// In en, this message translates to:
  /// **'#{n} in line'**
  String roundOrderPositionInLine(int n);

  /// Flow 06 - Order & pour. Screen 04/05 round-mate row trailing text, and the screen 05 pill
  ///
  /// In en, this message translates to:
  /// **'Mixing now'**
  String get roundMixingNow;

  /// Flow 06 - Order & pour. Your round tab. Bare status chip label
  ///
  /// In en, this message translates to:
  /// **'Mixing'**
  String get roundStatusMixing;

  /// Flow 06 - Order & pour. Round-mate rows and the Your round tab. Status label
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get roundStatusReady;

  /// Flow 06 - Order & pour. Round-mate rows and the Your round tab. Status label
  ///
  /// In en, this message translates to:
  /// **'Served'**
  String get roundStatusServed;

  /// Flow 06 - Order & pour. Round-mate rows and the Your round tab. Status label
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get roundStatusCancelled;

  /// Flow 06 - Order & pour. Round-mate rows and the Your round tab. Status label for a stock pull
  ///
  /// In en, this message translates to:
  /// **'Pulled'**
  String get roundStatusPulled;

  /// Flow 06 - Order & pour. Screen 04. Heading over the menu rail
  ///
  /// In en, this message translates to:
  /// **'While you wait'**
  String get roundWhileYouWait;

  /// Flow 06 - Order & pour. Screen 04. Link that opens the Menu tab
  ///
  /// In en, this message translates to:
  /// **'Full menu'**
  String get roundFullMenu;

  /// Flow 06 - Order & pour. Screen 05. Headline when the mixing order is the guest's own
  ///
  /// In en, this message translates to:
  /// **'{host}\'s pouring your {drink}'**
  String roundMixingHeadlineMine(String host, String drink);

  /// Flow 06 - Order & pour. Screen 05. Headline when the mixing order is for a friend
  ///
  /// In en, this message translates to:
  /// **'{host}\'s pouring {friend}\'s {drink}'**
  String roundMixingHeadlineFriend(String host, String friend, String drink);

  /// Flow 06 - Order & pour. Screen 05. Lock aside under the mixing card
  ///
  /// In en, this message translates to:
  /// **'Too late to cancel — it\'s already in the glass.'**
  String get roundCancelLocked;

  /// Flow 06 - Order & pour. Screen 05. Reassurance aside
  ///
  /// In en, this message translates to:
  /// **'Pocket it — we\'ll buzz you when it hits the counter.'**
  String get roundPocketIt;

  /// Flow 06 - Order & pour. Screen 07. Ticking pill, rendered uppercase
  ///
  /// In en, this message translates to:
  /// **'Ready · {elapsed} ago'**
  String roundReadySince(String elapsed);

  /// Flow 06 - Order & pour. Screen 07. The big headline
  ///
  /// In en, this message translates to:
  /// **'Grab it\nwhile it\'s cold'**
  String get roundGrabIt;

  /// Flow 06 - Order & pour. Screen 07. Body line when the order carries a note
  ///
  /// In en, this message translates to:
  /// **'{drink}, {note} — on the counter with your name on it.'**
  String roundReadyLineWithNote(String drink, String note);

  /// Flow 06 - Order & pour. Screen 07. Body line when the order carries no note
  ///
  /// In en, this message translates to:
  /// **'{drink} — on the counter with your name on it.'**
  String roundReadyLineNoNote(String drink);

  /// Flow 06 - Order & pour. Screen 07. Primary button; acknowledges locally only
  ///
  /// In en, this message translates to:
  /// **'On my way'**
  String get roundOnMyWay;

  /// Flow 06 - Order & pour. Screen 07. Footnote under the primary button
  ///
  /// In en, this message translates to:
  /// **'{host} marks it served when it\'s handed over.'**
  String roundServedFootnote(String host);

  /// Flow 06 - Order & pour. Screen 13. Uppercase pill on the amber card
  ///
  /// In en, this message translates to:
  /// **'Pulled from the menu'**
  String get roundPulledPill;

  /// Flow 06 - Order & pour. Screen 13. Headline naming what ran out
  ///
  /// In en, this message translates to:
  /// **'{host} ran out of {ingredient}'**
  String roundPulledTitle(String host, String ingredient);

  /// Flow 06 - Order & pour. Screen 13. First sentence of the body, naming the pulled drink
  ///
  /// In en, this message translates to:
  /// **'Your {drink} is off the list.'**
  String roundPulledIntro(String drink);

  /// Flow 06 - Order & pour. Screen 13. Label for a round-mate order that is the guest's own
  ///
  /// In en, this message translates to:
  /// **'Your {drink}'**
  String roundOthersLabelMine(String drink);

  /// Flow 06 - Order & pour. Screen 13. Label for a round-mate order sent for a friend
  ///
  /// In en, this message translates to:
  /// **'{friend}\'s {drink}'**
  String roundOthersLabelFriend(String friend, String drink);

  /// Flow 06 - Order & pour. Screen 13. Second sentence of the body, naming what else in the round survives
  ///
  /// In en, this message translates to:
  /// **'{label} is still coming — #{position} in line.'**
  String roundStillComingAt(String label, int position);

  /// Flow 06 - Order & pour. Screen 13. Heading over the swap suggestions
  ///
  /// In en, this message translates to:
  /// **'Swap it for'**
  String get roundSwapTitle;

  /// Flow 06 - Order & pour. Screen 13. Subline under the swap heading
  ///
  /// In en, this message translates to:
  /// **'Still pourable right now'**
  String get roundSwapSubtitle;

  /// Flow 06 - Order & pour. Screen 13. Sub-label on a swap suggestion a round-mate already ordered
  ///
  /// In en, this message translates to:
  /// **'What {friend}\'s having'**
  String roundSwapMateLabel(String friend);

  /// Flow 06 - Order & pour. Screen 13. Button that sends a one-drink round for the suggestion
  ///
  /// In en, this message translates to:
  /// **'Swap in'**
  String get roundSwapIn;

  /// Flow 06 - Order & pour. Screen 13. Dismisses the pull without swapping
  ///
  /// In en, this message translates to:
  /// **'Nothing for now, thanks'**
  String get roundNothingForNow;

  /// Flow 06 - Order & pour. Screen 13. Snackbar when Swap in fails
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t send the swap — try again.'**
  String get roundSwapFailed;

  /// Flow 06 - Order & pour. Menu tab. Calm empty state title
  ///
  /// In en, this message translates to:
  /// **'Nothing on the menu'**
  String get roundMenuEmptyTitle;

  /// Flow 06 - Order & pour. Menu tab. Calm empty state body
  ///
  /// In en, this message translates to:
  /// **'{host} hasn\'t added any drinks yet.'**
  String roundMenuEmptyBody(String host);

  /// Flow 06 - Order & pour. Menu tab. Calm loading state, never a bare spinner
  ///
  /// In en, this message translates to:
  /// **'Loading the menu…'**
  String get roundMenuLoading;

  /// Flow 06 - Order & pour. Screen 01. Chip under the hero title
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 ingredient} other{{n} ingredients}}'**
  String roundIngredientsCount(int n);

  /// Flow 06 - Order & pour. Screen 01. Uppercase eyebrow over the who-chips
  ///
  /// In en, this message translates to:
  /// **'Who\'s it for'**
  String get roundWhosItFor;

  /// Flow 06 - Order & pour. Screen 01. Default who-chip, the sender themself
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get roundMe;

  /// Flow 06 - Order & pour. Screen 01. Who-chip that opens the friend-name sheet
  ///
  /// In en, this message translates to:
  /// **'Someone else'**
  String get roundSomeoneElse;

  /// Flow 06 - Order & pour. Screen 01. Title of the friend-name sheet
  ///
  /// In en, this message translates to:
  /// **'Who\'s it for?'**
  String get roundSomeoneElseTitle;

  /// Flow 06 - Order & pour. Screen 01. Text field hint in the friend-name sheet
  ///
  /// In en, this message translates to:
  /// **'Friend\'s name'**
  String get roundSomeoneElseHint;

  /// Flow 06 - Order & pour. Screen 01. Confirms the friend-name sheet
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get roundSomeoneElseAdd;

  /// Flow 06 - Order & pour. Screen 01. Stepper card title
  ///
  /// In en, this message translates to:
  /// **'How many'**
  String get roundHowMany;

  /// Flow 06 - Order & pour. Screen 01. Stepper card subtitle
  ///
  /// In en, this message translates to:
  /// **'Each one queues on its own'**
  String get roundHowManySub;

  /// Flow 06 - Order & pour. Screen 01. Placeholder text in the note row before one is entered
  ///
  /// In en, this message translates to:
  /// **'Heavy on the lime, no straw…'**
  String get roundNoteHint;

  /// Flow 06 - Order & pour. Screen 01. Trailing link on the note row when empty
  ///
  /// In en, this message translates to:
  /// **'Add note'**
  String get roundAddNote;

  /// Flow 06 - Order & pour. Screen 01. Trailing link on the note row once a note exists
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get roundEditNote;

  /// Flow 06 - Order & pour. Screen 01. Title of the note-entry sheet
  ///
  /// In en, this message translates to:
  /// **'Add a note'**
  String get roundNoteSheetTitle;

  /// Flow 06 - Order & pour. Screen 01. Text field hint in the note-entry sheet
  ///
  /// In en, this message translates to:
  /// **'e.g. heavy on the lime, no straw'**
  String get roundNoteSheetHint;

  /// Flow 06 - Order & pour. Screen 01. Confirms the note-entry sheet
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get roundNoteSheetSave;

  /// Flow 06 - Order & pour. Screen 01. Bold lead-in of the queue aside
  ///
  /// In en, this message translates to:
  /// **'{n} ahead of you'**
  String roundAheadBold(int n);

  /// Flow 06 - Order & pour. Screen 01. Rest of the queue aside sentence, appended after roundAheadBold
  ///
  /// In en, this message translates to:
  /// **' in {host}\'s queue right now.'**
  String roundAheadRest(String host);

  /// Flow 06 - Order & pour. Screen 01. Primary button
  ///
  /// In en, this message translates to:
  /// **'Add to round'**
  String get roundAddToRound;

  /// Flow 06 - Order & pour. Screen 02 and the Your round tab. Title
  ///
  /// In en, this message translates to:
  /// **'Your round'**
  String get roundYourRoundTitle;

  /// Flow 06 - Order & pour. Screen 02. Subtitle under the title
  ///
  /// In en, this message translates to:
  /// **'{host} pours one at a time'**
  String roundPoursOneAtATime(String host);

  /// Flow 06 - Order & pour. Screen 02. Mono count, rendered uppercase
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 drink} other{{n} drinks}}'**
  String roundDrinksCount(int n);

  /// Flow 06 - Order & pour. Screen 02 row. Who the drink is for, the sender
  ///
  /// In en, this message translates to:
  /// **'for you'**
  String get roundForYou;

  /// Flow 06 - Order & pour. Screen 02 row. Who the drink is for, a friend
  ///
  /// In en, this message translates to:
  /// **'for {name}'**
  String roundForFriend(String name);

  /// Flow 06 - Order & pour. Screen 02. Aside when the round has one drink
  ///
  /// In en, this message translates to:
  /// **'{ahead} ahead of you. Sending puts you at #{position}.'**
  String roundAheadSendingSingle(int ahead, int position);

  /// Flow 06 - Order & pour. Screen 02. Aside when the round has several drinks
  ///
  /// In en, this message translates to:
  /// **'{ahead} ahead of you. Sending puts you at #{a}–#{b}.'**
  String roundAheadSendingRange(int ahead, int a, int b);

  /// Flow 06 - Order & pour. Screen 02. Primary button, host's first name
  ///
  /// In en, this message translates to:
  /// **'Send to {host}'**
  String roundSendTo(String host);

  /// Flow 06 - Order & pour. Screen 02. Closes the sheet to add another drink
  ///
  /// In en, this message translates to:
  /// **'Add one more'**
  String get roundAddOneMore;

  /// Flow 06 - Order & pour. Screen 02. Snackbar on a failed send
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t send your round — try again.'**
  String get roundSendFailed;

  /// Flow 06 - Order & pour. Screen 03. Headline
  ///
  /// In en, this message translates to:
  /// **'Order\'s in'**
  String get roundOrdersIn;

  /// Flow 06 - Order & pour. Screen 03. Body under the headline
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{One drink in {host}\'s queue. We\'ll buzz you the second it\'s ready.} other{{count} drinks in {host}\'s queue. We\'ll buzz you the second one of them is ready.}}'**
  String roundOrdersInBody(int count, String host);

  /// Flow 06 - Order & pour. Screen 03. Small label under each glass tile's position
  ///
  /// In en, this message translates to:
  /// **'in line'**
  String get roundInLineTag;

  /// Flow 06 - Order & pour. Screen 03. Primary button
  ///
  /// In en, this message translates to:
  /// **'Back to the menu'**
  String get roundBackToMenu;

  /// Flow 06 - Order & pour. Screen 03. Secondary action
  ///
  /// In en, this message translates to:
  /// **'Cancel the round'**
  String get roundCancelRound;

  /// Flow 06 - Order & pour. Screen 03. Footnote under Cancel the round
  ///
  /// In en, this message translates to:
  /// **'You can pull an order out until {host} starts pouring it.'**
  String roundCancelRoundFootnote(String host);

  /// Flow 06 - Order & pour. Screen 03. Snackbar after Cancel the round when some orders could not be pulled
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{One order was already pouring and stayed.} other{{n} orders were already pouring and stayed.}}'**
  String roundCancelRoundKept(int n);

  /// Flow 06 - Order & pour. Your round tab. Summary line under the title
  ///
  /// In en, this message translates to:
  /// **'{total, plural, =1{1 tonight} other{{total} tonight}} · {coming, plural, =1{1 still coming} other{{coming} still coming}}'**
  String roundTonightSummary(int total, int coming);

  /// Flow 06 - Order & pour. Your round tab. Identity reassurance card
  ///
  /// In en, this message translates to:
  /// **'You\'re {name} tonight'**
  String roundYoureTonight(String name);

  /// Flow 06 - Order & pour. The buzz banner. Timestamp label
  ///
  /// In en, this message translates to:
  /// **'now'**
  String get roundBuzzNow;

  /// Flow 06 - Order & pour. The buzz banner. Headline when the ready order is the guest's own
  ///
  /// In en, this message translates to:
  /// **'Your {drink} is ready'**
  String roundBuzzReadyMine(String drink);

  /// Flow 06 - Order & pour. The buzz banner. Headline when the ready order is for a friend
  ///
  /// In en, this message translates to:
  /// **'{friend}\'s {drink} is ready'**
  String roundBuzzReadyFriend(String friend, String drink);

  /// Flow 06 - Order & pour. The buzz banner. First clause of the body
  ///
  /// In en, this message translates to:
  /// **'On the counter at {party}.'**
  String roundBuzzBody(String party);

  /// Flow 06 - Order & pour. The buzz banner. Second clause, appended when another round drink is still coming
  ///
  /// In en, this message translates to:
  /// **'{drink} is next up.'**
  String roundBuzzNextUp(String drink);

  /// Flow 06 - Order & pour. Any screen. Snackbar when a single-order cancel loses the race to the host
  ///
  /// In en, this message translates to:
  /// **'Too late — it\'s already being poured.'**
  String get roundCancelTooLate;

  /// Flow 06 - Order & pour. Screens 01/02. Reason shown when the primary send action is disabled
  ///
  /// In en, this message translates to:
  /// **'Sending is off while the bar\'s paused.'**
  String get roundSendingPaused;

  /// Flow 06 - Order & pour. Screen 01. Tooltip for the glass back button
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get roundBack;

  /// Flow 07 - Join a party. Screen 01. The headline over the six-character field
  ///
  /// In en, this message translates to:
  /// **'What\'s the code?'**
  String get joinTitle;

  /// Flow 07 - Join a party. Screen 01. Where to find the code
  ///
  /// In en, this message translates to:
  /// **'Six characters, on the host\'s screen or stuck to the fridge.'**
  String get joinSubtitle;

  /// Flow 07 - Join a party. Screen 01. Semantic label for the code field
  ///
  /// In en, this message translates to:
  /// **'Party code, six characters'**
  String get joinCodeSemantics;

  /// Flow 07 - Join a party. Screen 01. The reminder that the fast door exists
  ///
  /// In en, this message translates to:
  /// **'Got a link from the host? Just tap it — it lets you in on its own.'**
  String get joinLinkHint;

  /// Flow 07 - Join a party. Screen 01. Disabled button label while the code is unfinished
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one{One more character} other{{n} more characters}}'**
  String joinCodeMore(int n);

  /// Flow 07 - Join a party. Screen 01. The button once six characters are in
  ///
  /// In en, this message translates to:
  /// **'Join the party'**
  String get joinCta;

  /// Flow 07 - Join a party. Screen 04. The button after a code was refused
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get joinRetry;

  /// Flow 07 - Join a party. Screen 01. Tooltip on the close button
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get joinClose;

  /// Flow 07 - Join a party. Screen 04. A code nobody is using
  ///
  /// In en, this message translates to:
  /// **'No party with that code.'**
  String get joinFailedNotFound;

  /// Flow 07 - Join a party. Screen 04. Why a code might be wrong without the guest being careless
  ///
  /// In en, this message translates to:
  /// **'Zero and O look the same on a phone screen — worth a second look.'**
  String get joinFailedNotFoundHint;

  /// Flow 07 - Join a party. Screen 04. A real code whose night is over
  ///
  /// In en, this message translates to:
  /// **'That party ended at {time}.'**
  String joinFailedEnded(String time);

  /// Flow 07 - Join a party. Screen 04. The same, when we do not know when it closed
  ///
  /// In en, this message translates to:
  /// **'That party is already over.'**
  String get joinFailedEndedNoTime;

  /// Flow 07 - Join a party. Screen 04. Why an ended code is not a typo
  ///
  /// In en, this message translates to:
  /// **'Codes are never reused, so this can only mean the night is done.'**
  String get joinFailedEndedHint;

  /// Flow 07 - Join a party. Screen 04. A network failure, never blamed on the guest
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t reach the bar.'**
  String get joinFailedOffline;

  /// Flow 07 - Join a party. Screen 04. What happens next after a network failure
  ///
  /// In en, this message translates to:
  /// **'Your code is still here — tap to try it again.'**
  String get joinFailedOfflineHint;

  /// Flow 07 - Join a party. Screen 04. The way out of the slow door
  ///
  /// In en, this message translates to:
  /// **'Ask the host to send the link instead'**
  String get joinAskForLink;

  /// Flow 07 - Join a party. Screen 02. While a tapped link resolves
  ///
  /// In en, this message translates to:
  /// **'Opening the bar…'**
  String get joinOpening;

  /// Flow 07 - Join a party. Screen 02. The one-line confirmation after arriving by link or QR
  ///
  /// In en, this message translates to:
  /// **'You\'re in'**
  String get joinYoureIn;

  /// Flow 07 - Join a party. Screen 03. Asked once, on the first send
  ///
  /// In en, this message translates to:
  /// **'One thing first'**
  String get joinNameTitle;

  /// Flow 07 - Join a party. Screen 03. Why the name is needed at all
  ///
  /// In en, this message translates to:
  /// **'{host} needs something to shout when your drink is ready.'**
  String joinNameBody(String host);

  /// Flow 07 - Join a party. Screen 03. Field eyebrow
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get joinNameLabel;

  /// Flow 07 - Join a party. Screen 03. Field placeholder
  ///
  /// In en, this message translates to:
  /// **'Sam'**
  String get joinNameHint;

  /// Flow 07 - Join a party. Screen 03. Validation when the field is left empty
  ///
  /// In en, this message translates to:
  /// **'A name is all we need.'**
  String get joinNameRequired;

  /// Flow 07 - Join a party. Screen 03. Who the name reaches
  ///
  /// In en, this message translates to:
  /// **'{host} and the pickup list see this. Nobody else.'**
  String joinNameVisibility(String host);

  /// Flow 07 - Join a party. Screen 03. The 18+ line, which rides on the send rather than gating the door
  ///
  /// In en, this message translates to:
  /// **'I\'m over 18 and drinking responsibly'**
  String get joinAgeConfirm;

  /// Flow 07 - Join a party. Screen 03. Shown when send is tapped without the 18+ line ticked
  ///
  /// In en, this message translates to:
  /// **'Tick the line above to send.'**
  String get joinAgeRequired;

  /// Flow 07 - Join a party. Screen 03. What is kept after the first send
  ///
  /// In en, this message translates to:
  /// **'This phone will remember you until the party ends.'**
  String get joinNameRemember;

  /// Flow 07 - Join a party. Screen 03. The send that also commits the name
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one{Send to the bar · 1 drink} other{Send to the bar · {n} drinks}}'**
  String joinSendToBar(int n);

  /// Flow 07 - Join a party. Screen 05. Swap the name this phone orders under
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get joinChangeName;

  /// Flow 07 - Join a party. Screen 05. The quiet way out
  ///
  /// In en, this message translates to:
  /// **'Leave the party'**
  String get joinLeaveParty;

  /// Flow 07 - Join a party. Screen 05. Confirmation title
  ///
  /// In en, this message translates to:
  /// **'Leave {party}?'**
  String joinLeaveTitle(String party);

  /// Flow 07 - Join a party. Screen 05. What leaving does and does not do
  ///
  /// In en, this message translates to:
  /// **'Drinks already sent stay in the queue — this phone just stops following them. The code lets you back in.'**
  String get joinLeaveBody;

  /// Flow 07 - Join a party. Screen 05. Confirm leaving
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get joinLeaveConfirm;

  /// Flow 07 - Join a party. Screen 05. Cancel leaving
  ///
  /// In en, this message translates to:
  /// **'Stay'**
  String get joinStay;

  /// Flow 07 - Join a party. Screen 06. The party ended while the guest was holding the phone
  ///
  /// In en, this message translates to:
  /// **'{host} closed the bar'**
  String joinEndedTitle(String host);

  /// Flow 07 - Join a party. Screen 06. The sentence under the title
  ///
  /// In en, this message translates to:
  /// **'{party} is done for the night.'**
  String joinEndedBody(String party);

  /// Flow 07 - Join a party. Screen 06. Eyebrow over the guest's own three numbers
  ///
  /// In en, this message translates to:
  /// **'Your night'**
  String get joinEndedYourNight;

  /// Flow 07 - Join a party. Screen 06. Label under the drinks count
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one{drink} other{drinks}}'**
  String joinEndedDrinksLabel(int n);

  /// Flow 07 - Join a party. Screen 06. Label under the count of drinks ordered for other people
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one{for a friend} other{for friends}}'**
  String joinEndedFriendsLabel(int n);

  /// Flow 07 - Join a party. Screen 06. Label under how long the guest stayed
  ///
  /// In en, this message translates to:
  /// **'here'**
  String get joinEndedHereLabel;

  /// Flow 07 - Join a party. Screen 06. How long the guest was at the party, in whole hours
  ///
  /// In en, this message translates to:
  /// **'{hours}H'**
  String joinEndedHours(int hours);

  /// Flow 07 - Join a party. Screen 06. What the guest can no longer do
  ///
  /// In en, this message translates to:
  /// **'The code has stopped working.'**
  String get joinEndedFootnote;

  /// Flow 07 - Join a party. Screen 06. The way out
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get joinEndedDone;

  /// Flow 07 - Join a party. Screen 07. The status pill in place of BAR OPEN
  ///
  /// In en, this message translates to:
  /// **'Bar paused'**
  String get joinPausedPill;

  /// Flow 07 - Join a party. Screen 07. What happened
  ///
  /// In en, this message translates to:
  /// **'{host} paused the bar'**
  String joinPausedTitle(String host);

  /// Flow 07 - Join a party. Screen 07. Reassurance that nothing was dropped
  ///
  /// In en, this message translates to:
  /// **'No new orders for a moment. Yours is still in the queue — nothing was lost.'**
  String get joinPausedBody;

  /// Flow 07 - Join a party. Screen 07. The footer strip in place of the round pill
  ///
  /// In en, this message translates to:
  /// **'Ordering is off'**
  String get joinPausedLocked;

  /// Flow 07 - Join a party. Screen 07. What happens next
  ///
  /// In en, this message translates to:
  /// **'You\'ll get a nudge the second {host} opens it again.'**
  String joinPausedNudge(String host);

  /// Flow 07 - Join a party. The party tab. Returning to the party this phone is already at
  ///
  /// In en, this message translates to:
  /// **'Back to {party}'**
  String joinBackTo(String party);

  /// Flow 07 - Join a party. Screen 04. The message the share sheet sends to the host
  ///
  /// In en, this message translates to:
  /// **'Send me the link to your PartyBar party?'**
  String get joinAskForLinkMessage;

  /// Flow 07 - Join a party. Screen 05. Commit a changed name
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get joinNameSave;

  /// Flow 07 - Join a party. Screen 07. The order the pause did not touch
  ///
  /// In en, this message translates to:
  /// **'{drink} · still #{position} in line'**
  String joinPausedStillInLine(String drink, int position);

  /// Flow 07 - Join a party. Screen 07. The header line under the party name while the bar is paused, in place of roundPartyOpenGuests
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Back in a bit · 1 here} other{Back in a bit · {count} here}}'**
  String joinPausedGuests(int count);
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
      <String>['en', 'uk'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'uk':
      return AppLocalizationsUk();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
