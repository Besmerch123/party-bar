// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'PartyBar';

  @override
  String get navigationHome => 'Home';

  @override
  String get navigationExplore => 'Explore';

  @override
  String get navigationParty => 'Party';

  @override
  String get navigationSettings => 'Settings';

  @override
  String get navigationProfile => 'Profile';

  @override
  String get language => 'Language';

  @override
  String get skip => 'Skip';

  @override
  String get getStarted => 'Get Started';

  @override
  String get next => 'Next';

  @override
  String get previous => 'Previous';

  @override
  String get onboardingTitle1 => 'Discover Amazing Cocktails';

  @override
  String get onboardingDescription1 =>
      'Browse through hundreds of cocktail recipes with detailed instructions and ingredients.';

  @override
  String get onboardingTitle2 => 'Join Party Events';

  @override
  String get onboardingDescription2 =>
      'Enter party codes to join events and order cocktails directly from the host.';

  @override
  String get onboardingTitle3 => 'Create Your Own Parties';

  @override
  String get onboardingDescription3 =>
      'Host your own cocktail parties and manage orders from your guests.';

  @override
  String get onboardingTitle4 => 'Build Your Collection';

  @override
  String get onboardingDescription4 =>
      'Create personal cocktail bars and save your favorite recipes.';

  @override
  String get profile => 'Profile';

  @override
  String get settings => 'Settings';

  @override
  String get authentication => 'Authentication';

  @override
  String get ingredients => 'Ingredients';

  @override
  String get equipment => 'Equipment';

  @override
  String get preparationSteps => 'Preparation Steps';

  @override
  String get categories => 'Categories';

  @override
  String pageOfPages(int current, int total) {
    return '$current of $total';
  }

  @override
  String get exploreCocktails => 'Explore Cocktails';

  @override
  String get filterCocktails => 'Filter Cocktails';

  @override
  String get filtersApply => 'Apply filters';

  @override
  String get filtersClear => 'Clear all';

  @override
  String get searchCocktailsHint => 'Search cocktails...';

  @override
  String get clearAll => 'Clear All';

  @override
  String cocktailsFound(int count) {
    return '$count cocktails found';
  }

  @override
  String get noCocktailsFound => 'No cocktails found';

  @override
  String get tryAdjustingFilters => 'Try adjusting your search or filters';

  @override
  String get clearFilters => 'Clear Filters';

  @override
  String get errorLoadingCocktails => 'Error Loading Cocktails';

  @override
  String get unknownError => 'Unknown error';

  @override
  String get retry => 'Retry';

  @override
  String failedToRefresh(String error) {
    return 'Failed to refresh: $error';
  }

  @override
  String get login => 'Log in';

  @override
  String get logout => 'Logout';

  @override
  String get logoutSuccess => 'Successfully logged out';

  @override
  String get logoutError => 'Failed to logout. Please try again.';

  @override
  String get signIn => 'Sign In';

  @override
  String get signUp => 'Sign Up';

  @override
  String get signInSuccess => 'Successfully signed in';

  @override
  String get signUpSuccess => 'Account created successfully';

  @override
  String get email => 'Email';

  @override
  String get emailHint => 'Enter your email';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get emailInvalid => 'Please enter a valid email';

  @override
  String get password => 'Password';

  @override
  String get passwordHint => 'Enter your password';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get confirmPasswordHint => 'Re-enter your password';

  @override
  String get confirmPasswordRequired => 'Please confirm your password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get createAccount => 'Create Account';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get signUpSubtitle => 'Create a new account to get started';

  @override
  String get signInSubtitle => 'Sign in to your account';

  @override
  String get orContinueWith => 'Or continue with';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get authenticationRequired => 'Authentication Required';

  @override
  String get authenticationRequiredMessage =>
      'This feature is available only for authenticated users. Please sign in to continue.';

  @override
  String get signInToContinue => 'Sign In to Continue';

  @override
  String get partyHub => 'Party Hub';

  @override
  String get welcomeToPartyBar => 'Welcome to PartyBar!';

  @override
  String get joinOrCreateParty =>
      'Join a party or create your own cocktail experience';

  @override
  String get joinParty => 'Join Party';

  @override
  String get joinPartySubtitle => 'Enter a party code to join the fun';

  @override
  String get createParty => 'Create Party';

  @override
  String get createPartySubtitle => 'Host your own cocktail party';

  @override
  String get partyQuickInfo =>
      'Hosts can manage orders and guests can browse cocktails in real-time!';
}
