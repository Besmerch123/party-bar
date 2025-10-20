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
}
