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
  String get navigationMyBar => 'My bar';

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
  String get loading => 'Loading...';

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

  @override
  String get createPartyTitle => 'Create Party';

  @override
  String get createYourParty => 'Create Your Party';

  @override
  String get createPartyDescription =>
      'Set up your cocktail party and invite guests';

  @override
  String get partyDetails => 'Party Details';

  @override
  String get partyNameLabel => 'Party Name *';

  @override
  String get partyNameHint => 'e.g., Sarah\'s Birthday Bash';

  @override
  String get partyDescriptionLabel => 'Description (Optional)';

  @override
  String get partyDescriptionHint => 'Tell guests about your party...';

  @override
  String get selectAvailableCocktails => 'Select Available Cocktails *';

  @override
  String selectedCount(int count) {
    return '$count selected';
  }

  @override
  String get allClassic => 'All Classic';

  @override
  String get tikiAndFrozen => 'Tiki & Frozen';

  @override
  String get createPartyButton => 'Create Party';

  @override
  String get pleaseEnterPartyName => 'Please enter a party name';

  @override
  String get pleaseSelectCocktail => 'Please select at least one cocktail';

  @override
  String get cocktail => 'Cocktail';

  @override
  String get invitationCode => 'Invitation Code';

  @override
  String get shareCode => 'Share Code';

  @override
  String get copyCode => 'Copy Code';

  @override
  String get codeCopied => 'Code copied to clipboard!';

  @override
  String get partyCocktails => 'Party Cocktails';

  @override
  String get addCocktails => 'Add Cocktails';

  @override
  String get removeCocktail => 'Remove';

  @override
  String get noCocktailsAdded => 'No cocktails added yet';

  @override
  String get editPartyInfo => 'Edit Party Info';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get cancel => 'Cancel';

  @override
  String get partyStatus => 'Party Status';

  @override
  String get startParty => 'Start Party';

  @override
  String get pauseParty => 'Pause Party';

  @override
  String get resumeParty => 'Resume Party';

  @override
  String get endParty => 'End Party';

  @override
  String get partyActive => 'Active';

  @override
  String get partyPaused => 'Paused';

  @override
  String get partyEnded => 'Ended';

  @override
  String get partyIdle => 'Not started';

  @override
  String get confirmEndParty => 'Are you sure you want to end the party?';

  @override
  String get confirmEndPartyMessage =>
      'This action cannot be undone. All party data will be archived.';

  @override
  String get goToHostDashboard => 'Go to Host Dashboard';

  @override
  String get goToPartyMenu => 'Go to Party Menu';

  @override
  String get partyAdminPanel => 'Party Admin';

  @override
  String get myHostedParties => 'My Hosted Parties';

  @override
  String get viewMyParties => 'View My Parties';

  @override
  String get noHostedParties => 'You haven\'t hosted any parties yet';

  @override
  String get createFirstParty => 'Create your first party to get started!';

  @override
  String get viewDetails => 'View Details';

  @override
  String cocktailsSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cocktails selected',
      one: '1 cocktail selected',
    );
    return '$_temp0';
  }

  @override
  String get selectCocktails => 'Select Cocktails';

  @override
  String addSelectedCocktails(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Save $count Cocktails',
      one: 'Save 1 Cocktail',
    );
    return '$_temp0';
  }

  @override
  String get cocktailsAlreadyAdded =>
      'All selected cocktails are already added';

  @override
  String cocktailsAddedSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cocktails added successfully',
      one: '1 cocktail added successfully',
    );
    return '$_temp0';
  }

  @override
  String failedToAddCocktails(String error) {
    return 'Failed to add cocktails: $error';
  }

  @override
  String get noPendingOrders => 'No pending orders';

  @override
  String get ordersWillAppear => 'Orders will appear here as guests place them';

  @override
  String get unknownCocktail => 'Unknown Cocktail';

  @override
  String forGuest(String guestName) {
    return 'For: $guestName';
  }

  @override
  String ordered(String time) {
    return 'Ordered: $time';
  }

  @override
  String get justNow => 'Just now';

  @override
  String minutesAgo(int minutes) {
    return '${minutes}m ago';
  }

  @override
  String hoursAgo(int hours) {
    return '${hours}h ago';
  }

  @override
  String get startPreparing => 'Start Preparing';

  @override
  String get markReady => 'Mark Ready';

  @override
  String get markDelivered => 'Mark Delivered';

  @override
  String get newOrders => 'New Orders';

  @override
  String get preparing => 'Preparing';

  @override
  String get readyForPickup => 'Ready for Pickup';

  @override
  String get orders => 'Orders';

  @override
  String ordersCount(int count) {
    return 'Orders ($count)';
  }

  @override
  String get stats => 'Stats';

  @override
  String get menu => 'Menu';

  @override
  String get totalOrders => 'Total Orders';

  @override
  String get completed => 'Completed';

  @override
  String get pending => 'Pending';

  @override
  String get activeTime => 'Active Time';

  @override
  String get partyOverview => 'Party Overview';

  @override
  String get popularCocktails => 'Popular Cocktails';

  @override
  String get noOrdersYet => 'No orders yet';

  @override
  String availableCocktails(int count) {
    return 'Available Cocktails ($count)';
  }

  @override
  String get noCocktailsAvailable => 'No cocktails available';

  @override
  String get addCocktailsToMenu => 'Add cocktails to the party menu';

  @override
  String get errorLoadingCocktailsList => 'Error loading cocktails';

  @override
  String get partyCopiedToClipboard => 'Party code copied to clipboard!';

  @override
  String get partyQRCode => 'Party QR Code';

  @override
  String get qrCodeMock => 'QR CODE\n(Mock)';

  @override
  String code(String code) {
    return 'Code: $code';
  }

  @override
  String get close => 'Close';

  @override
  String get partyResumed => 'Party resumed';

  @override
  String get partyPausedMessage => 'Party paused';

  @override
  String failedToUpdateOrder(String error) {
    return 'Failed to update order: $error';
  }

  @override
  String failedToUpdatePartyStatus(String error) {
    return 'Failed to update party status: $error';
  }

  @override
  String orderMarkedAs(String cocktail, String guest, String status) {
    return '$cocktail for $guest marked as $status';
  }

  @override
  String errorWithMessage(String message) {
    return 'Error: $message';
  }

  @override
  String get joinPartyTitle => 'Join Party';

  @override
  String get joinTheParty => 'Join the Party!';

  @override
  String get enterPartyCodeToOrder =>
      'Enter the party code to start ordering cocktails';

  @override
  String get yourName => 'Your Name';

  @override
  String get enterYourName => 'Enter your name';

  @override
  String get partyCode => 'Party Code';

  @override
  String get enterPartyCode => 'Enter 6-digit party code';

  @override
  String get scanQRCode => 'Scan QR Code';

  @override
  String get qrCodeScannedSuccess => 'QR Code scanned successfully!';

  @override
  String get pleaseEnterNameAndCode =>
      'Please enter both party code and your name';

  @override
  String get askHostForCode =>
      'Ask the party host for the 6-digit party code or scan their QR code';

  @override
  String get partyNotFound =>
      'Party not found. Please check the code and try again.';

  @override
  String get joiningParty => 'Joining party...';

  @override
  String get orderCocktail => 'Order Cocktail';

  @override
  String get specialRequests => 'Special Requests';

  @override
  String get specialRequestsHint => 'e.g., extra lime, no sugar...';

  @override
  String get optional => '(optional)';

  @override
  String orderConfirmation(String cocktailName) {
    return 'Order $cocktailName';
  }

  @override
  String orderConfirmMessage(String cocktailName) {
    return 'Are you sure you want to order $cocktailName?';
  }

  @override
  String cocktailOrderedSuccess(String cocktailName) {
    return '$cocktailName ordered successfully!';
  }

  @override
  String failedToOrderCocktail(String error) {
    return 'Failed to order cocktail: $error';
  }

  @override
  String get myOrders => 'My Orders';

  @override
  String get myStats => 'My Stats';

  @override
  String get ordersPlaced => 'Orders Placed';

  @override
  String get cocktailsTried => 'Cocktails Tried';

  @override
  String get favoriteCocktail => 'Favorite Cocktail';

  @override
  String get noFavoriteYet => 'No favorite yet';

  @override
  String get youHaventOrderedYet => 'You haven\'t ordered any cocktails yet';

  @override
  String get startOrderingFromMenu => 'Start ordering from the menu!';

  @override
  String get alreadyTried => 'Already tried';

  @override
  String welcome(String name) {
    return 'Welcome, $name!';
  }

  @override
  String get viewRecipe => 'View Recipe';

  @override
  String get orderNow => 'Order Now';

  @override
  String get later => 'Later';

  @override
  String get continueLabel => 'Continue';

  @override
  String get splashTagline => 'Your shelf. Their orders.\nOne bar, all night.';

  @override
  String get onboardingBarEyebrow => 'What you own';

  @override
  String get onboardingBarTitle => 'Your shelf\nbecomes a menu';

  @override
  String get onboardingBarBody =>
      'Tell PartyBar which bottles you have. It works out every cocktail you can already pour — and the one lime that unlocks eleven more.';

  @override
  String get onboardingBarStatShelf => 'Gin, vodka, tonic';

  @override
  String get onboardingBarStatPourable => 'You can pour';

  @override
  String get onboardingBarStatUnlock => 'Add one lime';

  @override
  String get onboardingOrdersEyebrow => 'What they do';

  @override
  String get onboardingOrdersTitle => 'They order.\nYou get a queue.';

  @override
  String get onboardingOrdersBody =>
      'Guests scan a code and order from their own phone. No app, no account. You just work down the list.';

  @override
  String get onboardingOrdersCta => 'Set up my bar';

  @override
  String get onboardingSampleGinTonic => 'Gin & Tonic';

  @override
  String get onboardingSampleCosmopolitan => 'Cosmopolitan';

  @override
  String get onboardingSampleOrderNote => 'Marta · heavy on the lime';

  @override
  String get onboardingSampleOrderWaiting => 'Danylo · waiting 2 min';

  @override
  String get orderStatusNew => 'New';

  @override
  String get orderStatusQueued => 'Queued';

  @override
  String get onboardingVibeTitle => 'What do you\ndrink like?';

  @override
  String get onboardingVibeBody =>
      'Pick two or three. It only sorts your feed — nothing gets hidden.';

  @override
  String get vibeSharpCitrus => 'Sharp & citrus';

  @override
  String get vibeDarkStirred => 'Dark & stirred';

  @override
  String get vibeLongFizzy => 'Long & fizzy';

  @override
  String get vibeSpicy => 'Spicy';

  @override
  String get vibeZeroProof => 'Zero proof';

  @override
  String get vibeThreeIngredients => 'Three ingredients max';

  @override
  String get onboardingBottlesTitle => 'Five bottles\nand you\'re open';

  @override
  String get onboardingBottlesBody =>
      'Tap what\'s actually on your shelf. Everything else can wait.';

  @override
  String get onboardingBottlesSearchHint => 'Search bottles & mixers';

  @override
  String get onboardingBottlesSection => 'Most home bars have these';

  @override
  String get onboardingBottlesNoMatch => 'Nothing matched that search.';

  @override
  String get onboardingOpenBar => 'Open my bar';

  @override
  String bottleInCocktails(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'in $count cocktails',
      one: 'in $count cocktail',
    );
    return '$_temp0';
  }

  @override
  String bottleUnlocksMore(int count) {
    return 'unlocks $count more';
  }

  @override
  String onboardingBottlesAdded(int count, int total) {
    return '$count of $total added';
  }

  @override
  String onboardingDrinksUnlocked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count drinks unlocked',
      one: '$count drink unlocked',
    );
    return '$_temp0';
  }

  @override
  String get bottleGin => 'Gin';

  @override
  String get bottleVodka => 'Vodka';

  @override
  String get bottleTonic => 'Tonic water';

  @override
  String get bottleLime => 'Lime';

  @override
  String get bottleWhiteRum => 'White rum';

  @override
  String get bottleSweetVermouth => 'Sweet vermouth';

  @override
  String get bottleWhiskey => 'Whiskey';

  @override
  String get bottleTequila => 'Tequila';

  @override
  String get bottleTripleSec => 'Triple sec';

  @override
  String get bottleLemon => 'Lemon';

  @override
  String get bottleSimpleSyrup => 'Simple syrup';

  @override
  String get bottleSodaWater => 'Soda water';

  @override
  String get bottleAngostura => 'Angostura bitters';

  @override
  String get bottleMint => 'Mint';

  @override
  String get bottleShaker => 'Shaker';

  @override
  String get exploreFeedTitle => 'Pour tonight';

  @override
  String exploreShelfMatch(int makeable, int total) {
    return '$makeable of $total drinks match your shelf';
  }

  @override
  String exploreNoShelfYet(int total) {
    return '$total drinks. Add a bottle to see what you can pour.';
  }

  @override
  String get exploreSectionTwoBottles => 'Two bottles, one drink';

  @override
  String get exploreSectionZeroProof => 'Zero proof';

  @override
  String get exploreSectionMakeableNow => 'Ready on your shelf';

  @override
  String get exploreSeeAll => 'See all';

  @override
  String exploreAllOnShelf(int count) {
    return '$count on your shelf';
  }

  @override
  String exploreMissingBadge(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count missing',
      one: '1 missing',
    );
    return '$_temp0';
  }

  @override
  String exploreNeedsIngredient(String ingredient) {
    return 'needs $ingredient';
  }

  @override
  String get exploreEmptyTitle => 'Nothing here yet';

  @override
  String get exploreEmptyBody =>
      'The catalogue could not be loaded. Pull to try again.';

  @override
  String cocktailMinutes(int count) {
    return '$count min';
  }

  @override
  String cocktailAbv(String value) {
    return '$value% ABV';
  }

  @override
  String get methodBuilt => 'built';

  @override
  String get methodStirred => 'stirred';

  @override
  String get methodShaken => 'shaken';

  @override
  String get methodBlended => 'blended';

  @override
  String get methodLayered => 'layered';

  @override
  String get spiritGin => 'Gin';

  @override
  String get spiritVodka => 'Vodka';

  @override
  String get spiritRum => 'Rum';

  @override
  String get spiritWhisky => 'Whisky';

  @override
  String get spiritTequila => 'Tequila';

  @override
  String get spiritBrandy => 'Brandy';

  @override
  String get spiritZeroProof => 'Zero proof';

  @override
  String get spiritOther => 'Other';

  @override
  String get flavorCitrus => 'Citrus';

  @override
  String get flavorBitter => 'Bitter';

  @override
  String get flavorSweet => 'Sweet';

  @override
  String get flavorHerbal => 'Herbal';

  @override
  String get flavorSpicy => 'Spicy';

  @override
  String get flavorFruity => 'Fruity';

  @override
  String get flavorDry => 'Dry';

  @override
  String get flavorCreamy => 'Creamy';

  @override
  String get unitMl => 'ml';

  @override
  String get unitCl => 'cl';

  @override
  String get unitOz => 'oz';

  @override
  String get unitDash => 'dash';

  @override
  String get unitBarspoon => 'bar spoon';

  @override
  String get unitPiece => 'pc';

  @override
  String get unitSplash => 'splash';

  @override
  String get unitTopUp => 'top up';

  @override
  String measureAmount(String amount, String unit) {
    return '$amount $unit';
  }

  @override
  String get searchHint => 'Cocktail, spirit, or mood';

  @override
  String get searchCancel => 'Cancel';

  @override
  String get searchRecent => 'Recent';

  @override
  String get searchClearRecent => 'Clear';

  @override
  String get searchPopularThisWeek => 'Popular this week';

  @override
  String get searchBrowseBySpirit => 'Browse by spirit';

  @override
  String get searchClearQuery => 'Clear search';

  @override
  String get filterSheetTitle => 'Filter';

  @override
  String get filterReset => 'Reset';

  @override
  String get filterOpen => 'Filters';

  @override
  String get filterMakeableTitle => 'Makeable with my bar';

  @override
  String filterMakeableSubtitle(int bottles, int drinks) {
    String _temp0 = intl.Intl.pluralLogic(
      bottles,
      locale: localeName,
      other: '$bottles bottles on the shelf',
      one: '1 bottle on the shelf',
    );
    return '$_temp0 · $drinks drinks';
  }

  @override
  String get filterMakeableEmptyBar => 'No bottles on the shelf yet';

  @override
  String get filterSectionSort => 'Sort';

  @override
  String get filterSectionBaseSpirit => 'Base spirit';

  @override
  String get filterSectionEffort => 'Effort';

  @override
  String get sortMakeable => 'Makeable';

  @override
  String get sortPopular => 'Popular';

  @override
  String get sortSeasonal => 'Seasonal';

  @override
  String get filterUnderThreeMinutes => 'Under 3 minutes';

  @override
  String get filterNoShaker => 'No shaker needed';

  @override
  String get filterThreeIngredients => 'Three ingredients max';

  @override
  String filterShowDrinks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Show $count drinks',
      one: 'Show 1 drink',
      zero: 'No drinks match',
    );
    return '$_temp0';
  }

  @override
  String get filterChipMakeable => 'Makeable';

  @override
  String get filterChipNoShaker => 'No shaker';

  @override
  String get filterChipUnderThree => 'Under 3 min';

  @override
  String get filterChipThreeIngredients => 'Max 3 parts';

  @override
  String filterRemove(String filter) {
    return 'Remove $filter';
  }

  @override
  String resultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count drinks',
      one: '1 drink',
      zero: 'No drinks',
    );
    return '$_temp0';
  }

  @override
  String get resultsMakeableFirst => 'makeable first';

  @override
  String get resultsPopularFirst => 'popular first';

  @override
  String get resultsSeasonalFirst => 'seasonal first';

  @override
  String get zeroResultsTitle => 'Nothing matches that yet';

  @override
  String zeroResultsBlockedTitle(String filter) {
    return '$filter is what is in the way';
  }

  @override
  String zeroResultsBody(String query, String filter) {
    return 'Nothing matches “$query” with $filter on. Drop that filter, or try one of these.';
  }

  @override
  String zeroResultsBodyNoQuery(String filter) {
    return 'Nothing matches with $filter on. Drop that filter, or try one of these.';
  }

  @override
  String zeroResultsBodyPlain(String query) {
    return 'Nothing matches “$query”. Try another word, or one of these.';
  }

  @override
  String zeroResultsDropFilter(String filter) {
    return 'Drop “$filter”';
  }

  @override
  String get zeroResultsClearAll => 'Clear all';

  @override
  String get zeroResultsOneBottleAway => 'One bottle away';

  @override
  String zeroResultsUnlocks(String ingredient, int count) {
    return 'add $ingredient · unlocks $count';
  }

  @override
  String zeroResultsUnlocksUnknown(String ingredient) {
    return 'add $ingredient';
  }

  @override
  String get zeroResultsPourable => 'You can pour these tonight';

  @override
  String get addToBar => 'Add to my bar';

  @override
  String addedToBar(String ingredient) {
    return '$ingredient is on your shelf';
  }

  @override
  String get cocktailSave => 'Save';

  @override
  String get cocktailShare => 'Share';

  @override
  String get cocktailBack => 'Back';

  @override
  String get cocktailNotOnShelf => 'not on your shelf';

  @override
  String cocktailAddUnlocks(String ingredient, int count) {
    return 'Add $ingredient to your bar — unlocks $count more';
  }

  @override
  String cocktailAddToBarPlain(String ingredient) {
    return 'Add $ingredient to your bar';
  }

  @override
  String get cocktailMakeItNow => 'Make it now';

  @override
  String get cocktailAddToParty => 'Add to a party';

  @override
  String get cocktailIngredientsTitle => 'Ingredients';

  @override
  String get cocktailRecipeCopied => 'Recipe copied to clipboard';

  @override
  String pourStepCounter(int step, int total, String cocktail) {
    return 'Step $step of $total · $cocktail';
  }

  @override
  String get pourTimerHint => 'Tap to run the timer';

  @override
  String get pourTimerRunning => 'Running';

  @override
  String get pourTimerDone => 'Time';

  @override
  String get pourNext => 'Next step';

  @override
  String get pourFinish => 'Poured it';

  @override
  String get pourBack => 'Previous step';

  @override
  String get pourExit => 'Stop';

  @override
  String get pourShowRecipe => 'Recipe';

  @override
  String pourFinished(String cocktail) {
    return '$cocktail poured. Enjoy.';
  }

  @override
  String get pourNoSteps => 'This one has no steps written down yet.';

  @override
  String authGateSaveTitle(String cocktail) {
    return 'Keep the $cocktail';
  }

  @override
  String get authGateSaveBody =>
      'Saved drinks live in your account, so they survive a new phone. Your shelf and everything you have browsed comes with you.';

  @override
  String get authGateLists => 'Lists that sync';

  @override
  String get authGateHost => 'Host a party, take orders';

  @override
  String authGateShelf(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Your $count bottles carry over',
      one: 'Your 1 bottle carries over',
      zero: 'Your shelf carries over',
    );
    return '$_temp0';
  }

  @override
  String get authGateApple => 'Continue with Apple';

  @override
  String get authGateEmail => 'Use an email address';

  @override
  String get authGateKeepBrowsing => 'Keep browsing without an account';

  @override
  String get authContinueGoogle => 'Continue with Google';

  @override
  String get authContinueApple => 'Continue with Apple';

  @override
  String get authAppleSoon => 'Soon';

  @override
  String authLegalLine(String terms, String privacy) {
    return 'By continuing you agree to the $terms and $privacy.';
  }

  @override
  String get authTerms => 'Terms';

  @override
  String get authPrivacy => 'Privacy Policy';

  @override
  String get authBarrierEyebrow => 'One step left';

  @override
  String get authBarrierHostTitle => 'Parties need an owner';

  @override
  String get authBarrierHostBody =>
      'So guests can join from your link, and the menu is still here next Saturday. Your draft is saved either way.';

  @override
  String get authBarrierBarTitle => 'Don’t lose this shelf';

  @override
  String get authBarrierBarBody =>
      'Sign in with Google and it follows you to the next phone. It keeps working on this one either way.';

  @override
  String get authNotNow => 'Not now';

  @override
  String get authProvidersEyebrow => 'Your bar, everywhere';

  @override
  String get authProvidersTitle => 'One account.\nEvery party.';

  @override
  String get authProvidersBody =>
      'Your shelf, your saved drinks and every party you have hosted, on any phone you pick up.';

  @override
  String get authAgeNote => '18+ only · we never post anything';

  @override
  String get authSignedInBadge => 'Signed in';

  @override
  String get authNameTitle => 'How should\nguests see you?';

  @override
  String get authNameBody =>
      'This is the only thing other people at a party see next to your orders.';

  @override
  String get authAddPhoto => 'Add a photo';

  @override
  String get authAddPhotoNote => 'Optional. Your initial works fine.';

  @override
  String get authDisplayNameLabel => 'Display name';

  @override
  String get authDisplayNameHint => 'Marta';

  @override
  String get authAgeConfirm => 'I’m 18 or over';

  @override
  String authAgeLegal(String terms, String privacy) {
    return 'PartyBar is for people of legal drinking age. See the $terms and $privacy.';
  }

  @override
  String get authNameRequired => 'Pick something guests will recognise.';

  @override
  String get authAgeRequired => 'Confirm you are 18 or over to continue.';

  @override
  String get authFinishHost => 'Create my party';

  @override
  String get authFinishBar => 'Open my bar';

  @override
  String get authFinishSave => 'Save the drink';

  @override
  String get authFinishGeneric => 'Continue';

  @override
  String authSignedInAs(String name) {
    return 'Signed in as $name';
  }

  @override
  String get authDraftKept => 'Draft kept while you signed in';

  @override
  String get authDraftRestored => 'Restored';

  @override
  String guestLiveAt(String party) {
    return 'Live · $party';
  }

  @override
  String get guestTitle => 'You’re at the bar';

  @override
  String guestBody(String host) {
    return 'No account needed. $host just needs to know whose drink is whose.';
  }

  @override
  String get guestBodyNoHost =>
      'No account needed. The host just needs to know whose drink is whose.';

  @override
  String get guestNameLabel => 'What should we call you?';

  @override
  String get guestNameHint => 'Your name';

  @override
  String get guestNameRequired => 'A name is all we need.';

  @override
  String get guestStartOrdering => 'Start ordering';

  @override
  String get guestAgeNote => 'By ordering you confirm you’re 18 or over';

  @override
  String get guestHaveAccount => 'Have an account? Sign in';

  @override
  String get claimHeadline => 'That was a night';

  @override
  String claimSubline(int count, String party) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count drinks · $party',
      one: '1 drink · $party',
    );
    return '$_temp0';
  }

  @override
  String claimTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Keep tonight’s $count?',
      one: 'Keep tonight’s drink?',
    );
    return '$_temp0';
  }

  @override
  String get claimBody =>
      'An account saves what you drank, so next time the bar already knows your taste. Skip it and nothing is lost tonight.';

  @override
  String claimMore(int count) {
    return '+$count';
  }

  @override
  String get claimWithGoogle => 'Save with Google';

  @override
  String get claimWithApple => 'Apple';

  @override
  String get claimNoThanks => 'No thanks';

  @override
  String authErrorDifferentProvider(String email) {
    return 'You already use Google for $email.';
  }

  @override
  String get authErrorDifferentProviderNoEmail =>
      'You already use Google for that address.';

  @override
  String get authErrorOffline =>
      'No connection. Your draft is on this phone — we’ll sign you in when you’re back.';

  @override
  String get authErrorGeneric => 'Sign-in did not go through. Try again.';

  @override
  String get authErrorRetry => 'Try again';

  @override
  String get authBack => 'Back';

  @override
  String get authClose => 'Close';

  @override
  String get barTitle => 'My bar';

  @override
  String get barEmptyBody =>
      'Nothing on the shelf yet. Tap what you own — it stays on this phone until you sign in.';

  @override
  String get barEmptyBodySignedIn =>
      'Nothing on the shelf yet. Tap what you own.';

  @override
  String get barSearchHint => 'Bottles, mixers, tools…';

  @override
  String get barStartersSection => 'Most bars start here';

  @override
  String get barAddAll => 'Add all';

  @override
  String get barStartersFooter =>
      'Twelve suggestions, then search for the rest';

  @override
  String barInDrinks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'In $count drinks',
      one: 'In 1 drink',
    );
    return '$_temp0';
  }

  @override
  String barInDrinksInline(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'in $count drinks',
      one: 'in 1 drink',
    );
    return '$_temp0';
  }

  @override
  String barNeededForDrinks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Needed for $count drinks',
      one: 'Needed for 1 drink',
    );
    return '$_temp0';
  }

  @override
  String get barOnYourShelf => 'On your shelf';

  @override
  String barShelfCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count on the shelf',
      one: '1 on the shelf',
    );
    return '$_temp0';
  }

  @override
  String barMakeableCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count drinks you can make',
      one: '1 drink you can make',
    );
    return '$_temp0';
  }

  @override
  String barThingsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count things',
      one: '1 thing',
    );
    return '$_temp0';
  }

  @override
  String get barFilterAll => 'All';

  @override
  String get barSectionSpirits => 'Spirits';

  @override
  String get barSectionMixers => 'Mixers';

  @override
  String get barSectionFresh => 'Fresh';

  @override
  String get barSectionSyrups => 'Syrups';

  @override
  String get barSectionTools => 'Tools';

  @override
  String get barSectionIce => 'Ice';

  @override
  String get barSectionOther => 'Other';

  @override
  String get barGroupSpirits => 'Spirits & liqueurs';

  @override
  String get barGroupMixers => 'Mixers';

  @override
  String get barGroupFresh => 'Fresh';

  @override
  String get barGroupSyrups => 'Syrups & bitters';

  @override
  String get barGroupTools => 'Tools & glassware';

  @override
  String get barGroupIce => 'Ice';

  @override
  String get barGroupOther => 'Everything else';

  @override
  String barInYourDrinks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'In $count of your drinks',
      one: 'In 1 of your drinks',
    );
    return '$_temp0';
  }

  @override
  String barNeededForYourDrinks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Needed for $count of your drinks',
      one: 'Needed for 1 of your drinks',
    );
    return '$_temp0';
  }

  @override
  String get barAddedJustNow => 'Added just now';

  @override
  String get barNotInYourBar => 'Not in your bar';

  @override
  String get barRanOutGroup => 'Ran out';

  @override
  String get barAddAllToList => 'Add all to list';

  @override
  String barBlocksDrinks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Blocks $count drinks',
      one: 'Blocks 1 drink',
    );
    return '$_temp0';
  }

  @override
  String get barOnYourList => 'On your list';

  @override
  String get barAddToList => 'Add to list';

  @override
  String get barFreshInfo =>
      'Fresh things go off, so we ask what ran out when a party ends — never in the middle of one.';

  @override
  String get barOpenList => 'Shopping list';

  @override
  String get barAddItem => 'Add to my bar';

  @override
  String barMarkRanOut(String item) {
    return 'Mark $item as ran out';
  }

  @override
  String barPutBack(String item) {
    return 'Put $item back on the shelf';
  }

  @override
  String get barSheetOnShelf => 'On the shelf';

  @override
  String get barSheetRanOut => 'Ran out — put it on my list';

  @override
  String get barSheetNote => 'Note';

  @override
  String get barSheetNoteHint => 'Brand, bottle, where it lives…';

  @override
  String get barSheetNoteAdd => 'Add';

  @override
  String get barSheetNoteSave => 'Save';

  @override
  String get barSheetRemove => 'Remove from my bar';

  @override
  String get barSheetUnlocks => 'Unlocks for you';

  @override
  String get barSheetMore => 'more';

  @override
  String get barSheetDone => 'Done';

  @override
  String barRemoved(String item) {
    return '$item removed';
  }

  @override
  String get barUndo => 'Undo';

  @override
  String get barSearchCancel => 'Cancel';

  @override
  String barSearchMatches(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count matches',
      one: '1 match',
      zero: 'No matches',
    );
    return '$_temp0';
  }

  @override
  String get barAlreadyOnShelf => 'Already on your shelf';

  @override
  String get barRanOutTapRestock => 'Ran out · tap to put it back';

  @override
  String barAddCustom(String query) {
    return 'Not here? Add “$query” as your own bottle';
  }

  @override
  String barAddCustomToList(String query) {
    return 'Not here? Add “$query” to your list';
  }

  @override
  String get barCustomItem => 'Your own bottle';

  @override
  String get barSearchListHint => 'What do you need?';

  @override
  String get barAlreadyOnList => 'Already on your list';

  @override
  String get barCatalogueOffline =>
      'Only the starter list for now — the full catalogue needs a connection.';

  @override
  String get shoppingListTitle => 'Shopping list';

  @override
  String shoppingListSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count things · tick one and it goes on the shelf',
      one: '1 thing · tick it and it goes on the shelf',
      zero: 'Nothing to buy',
    );
    return '$_temp0';
  }

  @override
  String get shoppingListBlockingHeader => 'Blocking your drinks';

  @override
  String shoppingListBlockingLine(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count drinks you could make need it',
      one: '1 drink you could make needs it',
    );
    return '$_temp0';
  }

  @override
  String get shoppingListAlsoHeader => 'Also added';

  @override
  String shoppingListRanOutAt(String party) {
    return 'Ran out at $party';
  }

  @override
  String get shoppingListRanOut => 'Ran out';

  @override
  String shoppingListForCocktail(String cocktail) {
    return 'For $cocktail';
  }

  @override
  String get shoppingListAddedByYou => 'Added by you';

  @override
  String get shoppingListNowOnShelf => 'Now on your shelf';

  @override
  String get shoppingListAddSomething => 'Add something else…';

  @override
  String get shoppingListShare => 'Share the list';

  @override
  String get shoppingListClearTicked => 'Clear the ticked ones';

  @override
  String get shoppingListClearAll => 'Clear the whole list';

  @override
  String get shoppingListEmptyTitle => 'Nothing to buy';

  @override
  String get shoppingListEmptyBody =>
      'Ran-out things land here, and so does anything you add.';

  @override
  String get shoppingListRemove => 'Remove from list';

  @override
  String get shareListTitle => 'Send the list';

  @override
  String get shareListHeading => 'PartyBar — shopping list';

  @override
  String get shareListPlainNote => 'Plain text — whoever gets it needs no app';

  @override
  String get shareListShare => 'Share';

  @override
  String get shareListCopy => 'Copy';

  @override
  String get shareListCopied => 'List copied';

  @override
  String get shareListIncludeWhy => 'Include why each one is needed';

  @override
  String ranOutDrinksPoured(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count drinks poured',
      one: '1 drink poured',
    );
    return '$_temp0';
  }

  @override
  String get ranOutTitle => 'Anything run out?';

  @override
  String get ranOutBody =>
      'Tap what is gone. Everything you skip stays on the shelf — we never guess from what was poured.';

  @override
  String get ranOutGone => 'Gone · going on your list';

  @override
  String ranOutPoured(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Poured $count times tonight',
      one: 'Poured once tonight',
    );
    return '$_temp0';
  }

  @override
  String ranOutUpdate(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Update my bar · $count gone',
      zero: 'Update my bar',
    );
    return '$_temp0';
  }

  @override
  String get ranOutNothing => 'Nothing ran out';

  @override
  String get ranOutEmpty => 'Nothing on the shelf to check.';

  @override
  String twoAwayEyebrow(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count things short',
      two: 'Two things short',
    );
    return '$_temp0';
  }

  @override
  String twoAwayTitle(int have, int total) {
    return 'You have $have of the $total';
  }

  @override
  String get twoAwayBody => 'Everything else is on your shelf already.';

  @override
  String twoAwayAlsoBlocks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'also blocks $count more',
      one: 'also blocks 1 more',
      zero: 'only this one',
    );
    return '$_temp0';
  }

  @override
  String twoAwayAddToList(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Add all $count to my list',
      two: 'Add both to my list',
    );
    return '$_temp0';
  }

  @override
  String get twoAwayHaveThese => 'I actually have these';

  @override
  String get twoAwayFootnote =>
      '“I have these” adds them to your bar — the only place stock is ever corrected.';

  @override
  String twoAwayPrompt(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count things short · see what',
      one: '1 thing short · see what',
    );
    return '$_temp0';
  }

  @override
  String get twoAwayAddedToList => 'On your list';

  @override
  String get twoAwayAddedToBar => 'On your shelf';
}
