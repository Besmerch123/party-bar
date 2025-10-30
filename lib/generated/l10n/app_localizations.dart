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
