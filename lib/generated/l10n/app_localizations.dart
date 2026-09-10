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

  /// Email field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

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

  /// Flow 03 - Auth. Starts the magic-link lane
  ///
  /// In en, this message translates to:
  /// **'Continue with email'**
  String get authContinueEmail;

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

  /// Flow 03 - Auth. Screen 01. Barrier title when the interrupted action was editing the shelf
  ///
  /// In en, this message translates to:
  /// **'My Bar needs an owner'**
  String get authBarrierBarTitle;

  /// Flow 03 - Auth. Screen 01. Barrier body for editing the shelf
  ///
  /// In en, this message translates to:
  /// **'So your shelf follows you to the next phone, and the app keeps answering what you can pour. Nothing you have ticked is lost either way.'**
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

  /// Flow 03 - Auth. Screen 03. Headline of the address screen
  ///
  /// In en, this message translates to:
  /// **'What’s your\nemail?'**
  String get authEmailTitle;

  /// Flow 03 - Auth. Screen 03. Body of the address screen
  ///
  /// In en, this message translates to:
  /// **'We send a link that signs you in. No password to invent, none to forget.'**
  String get authEmailBody;

  /// Flow 03 - Auth. Screen 03. Placeholder in the email field
  ///
  /// In en, this message translates to:
  /// **'you@example.com'**
  String get authEmailHint;

  /// Flow 03 - Auth. Screen 03. Sends the magic link
  ///
  /// In en, this message translates to:
  /// **'Send the link'**
  String get authEmailSend;

  /// Flow 03 - Auth. Screen 03. Footnote telling returning people there is no separate sign-up
  ///
  /// In en, this message translates to:
  /// **'Already have an account? The same link signs you back in.'**
  String get authEmailReturning;

  /// Flow 03 - Auth. Screen 03. Validation message under the email field
  ///
  /// In en, this message translates to:
  /// **'That does not look like an email address.'**
  String get authEmailInvalid;

  /// Flow 03 - Auth. Screen 04. Headline after a link has been sent
  ///
  /// In en, this message translates to:
  /// **'Check your\nmail'**
  String get authCheckMailTitle;

  /// Flow 03 - Auth. Screen 04. Body naming the address the link went to
  ///
  /// In en, this message translates to:
  /// **'We sent a sign-in link to {email}. It works once and expires in 15 minutes.'**
  String authCheckMailBody(String email);

  /// Flow 03 - Auth. Screen 04. Opens the device mail app
  ///
  /// In en, this message translates to:
  /// **'Open Mail'**
  String get authOpenMail;

  /// Flow 03 - Auth. Screen 04. Countdown on the sleeping resend button, time reads as 0:42
  ///
  /// In en, this message translates to:
  /// **'Resend in {time}'**
  String authResendIn(String time);

  /// Flow 03 - Auth. Screen 04. Resends the link once the countdown is over
  ///
  /// In en, this message translates to:
  /// **'Send it again'**
  String get authResend;

  /// Flow 03 - Auth. Screen 04. Title of the 6-digit code card
  ///
  /// In en, this message translates to:
  /// **'On another device?'**
  String get authOtherDeviceTitle;

  /// Flow 03 - Auth. Screen 04. Body of the 6-digit code card
  ///
  /// In en, this message translates to:
  /// **'The mail also carries a 6-digit code. Type it here to finish on this phone.'**
  String get authOtherDeviceBody;

  /// Flow 03 - Auth. Screen 04. Accessibility label for the 6-digit code field
  ///
  /// In en, this message translates to:
  /// **'Sign-in code'**
  String get authCodeLabel;

  /// Flow 03 - Auth. Screen 04. Goes back to the address screen
  ///
  /// In en, this message translates to:
  /// **'Wrong address? Change it'**
  String get authChangeEmail;

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

  /// Flow 03 - Auth. Screen 07. Headline of the expired-link screen
  ///
  /// In en, this message translates to:
  /// **'That link\nhas expired'**
  String get authExpiredTitle;

  /// Flow 03 - Auth. Screen 07. Body of the expired-link screen
  ///
  /// In en, this message translates to:
  /// **'Sign-in links last 15 minutes and work once. Nothing is wrong with your account — here is a fresh one.'**
  String get authExpiredBody;

  /// Flow 03 - Auth. Screen 07. Sends a replacement link to the same address
  ///
  /// In en, this message translates to:
  /// **'Send a new link'**
  String get authSendNewLink;

  /// Flow 03 - Auth. Screen 07. Goes back to the address screen
  ///
  /// In en, this message translates to:
  /// **'Use a different address'**
  String get authDifferentAddress;

  /// Flow 03 - Auth. Screen 07. Title of the reassurance card
  ///
  /// In en, this message translates to:
  /// **'Your draft is safe'**
  String get authDraftSafeTitle;

  /// Flow 03 - Auth. Screen 07. Body of the reassurance card
  ///
  /// In en, this message translates to:
  /// **'Everything you set up is still on this phone. Signing in only moves it to your account.'**
  String get authDraftSafeBody;

  /// Flow 03 - Auth. Screen 07. Leaves the flow without signing in
  ///
  /// In en, this message translates to:
  /// **'Keep going without an account'**
  String get authKeepGoing;

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

  /// Flow 03 - Auth. Screen 09. Claims the night with Apple, short form on a split row
  ///
  /// In en, this message translates to:
  /// **'Apple'**
  String get claimWithApple;

  /// Flow 03 - Auth. Screen 09. Claims the night with an email link, short form on a split row
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get claimWithEmail;

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
