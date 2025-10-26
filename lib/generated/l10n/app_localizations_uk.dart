// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get appTitle => 'PartyBar';

  @override
  String get navigationHome => 'Головна';

  @override
  String get navigationExplore => 'Каталог';

  @override
  String get navigationParty => 'Вечірка';

  @override
  String get navigationSettings => 'Налаштування';

  @override
  String get navigationProfile => 'Профіль';

  @override
  String get language => 'Мова';

  @override
  String get skip => 'Пропустити';

  @override
  String get getStarted => 'Почати';

  @override
  String get next => 'Далі';

  @override
  String get previous => 'Назад';

  @override
  String get onboardingTitle1 => 'Відкрийте для себе чудові коктейлі';

  @override
  String get onboardingDescription1 =>
      'Переглядайте сотні рецептів коктейлів з детальними інструкціями та інгредієнтами.';

  @override
  String get onboardingTitle2 => 'Приєднуйтесь до вечірок';

  @override
  String get onboardingDescription2 =>
      'Вводьте коди вечірок, щоб приєднатися до подій і замовляти коктейлі безпосередньо у хоста.';

  @override
  String get onboardingTitle3 => 'Створюйте власні вечірки';

  @override
  String get onboardingDescription3 =>
      'Проводьте власні коктейльні вечірки та керуйте замовленнями ваших гостей.';

  @override
  String get onboardingTitle4 => 'Створіть свою колекцію';

  @override
  String get onboardingDescription4 =>
      'Створюйте персональні коктейль-бари та зберігайте улюблені рецепти.';

  @override
  String get profile => 'Профіль';

  @override
  String get settings => 'Налаштування';

  @override
  String get authentication => 'Автентифікація';

  @override
  String get ingredients => 'Інгредієнти';

  @override
  String get equipment => 'Обладнання';

  @override
  String get preparationSteps => 'Етапи приготування';

  @override
  String get categories => 'Категорії';

  @override
  String pageOfPages(int current, int total) {
    return '$current з $total';
  }

  @override
  String get exploreCocktails => 'Досліджуйте коктейлі';

  @override
  String get filterCocktails => 'Фільтрувати коктейлі';

  @override
  String get filtersApply => 'Застосувати фільтри';

  @override
  String get filtersClear => 'Очистити всі';

  @override
  String get searchCocktailsHint => 'Шукати коктейлі...';

  @override
  String get clearAll => 'Очистити все';

  @override
  String cocktailsFound(int count) {
    return 'Знайдено $count коктейлів';
  }

  @override
  String get noCocktailsFound => 'Коктейлі не знайдено';

  @override
  String get tryAdjustingFilters => 'Спробуйте змінити пошук або фільтри';

  @override
  String get clearFilters => 'Очистити фільтри';

  @override
  String get errorLoadingCocktails => 'Помилка завантаження коктейлів';

  @override
  String get unknownError => 'Невідома помилка';

  @override
  String get retry => 'Повторити';

  @override
  String failedToRefresh(String error) {
    return 'Не вдалося оновити: $error';
  }

  @override
  String get login => 'Увійти';

  @override
  String get logout => 'Вийти';

  @override
  String get logoutSuccess => 'Успішно вийшли з системи';

  @override
  String get logoutError => 'Не вдалося вийти. Спробуйте ще раз.';

  @override
  String get signIn => 'Увійти';

  @override
  String get signUp => 'Зареєструватися';

  @override
  String get signInSuccess => 'Успішно увійшли';

  @override
  String get signUpSuccess => 'Обліковий запис створено успішно';

  @override
  String get email => 'Електронна пошта';

  @override
  String get emailHint => 'Введіть вашу електронну пошту';

  @override
  String get emailRequired => 'Електронна пошта обов\'язкова';

  @override
  String get emailInvalid => 'Будь ласка, введіть дійсну електронну пошту';

  @override
  String get password => 'Пароль';

  @override
  String get passwordHint => 'Введіть ваш пароль';

  @override
  String get passwordRequired => 'Пароль обов\'язковий';

  @override
  String get passwordTooShort => 'Пароль має містити не менше 6 символів';

  @override
  String get confirmPassword => 'Підтвердіть пароль';

  @override
  String get confirmPasswordHint => 'Введіть пароль ще раз';

  @override
  String get confirmPasswordRequired => 'Будь ласка, підтвердіть ваш пароль';

  @override
  String get passwordsDoNotMatch => 'Паролі не збігаються';

  @override
  String get createAccount => 'Створити обліковий запис';

  @override
  String get welcomeBack => 'З поверненням';

  @override
  String get signUpSubtitle => 'Створіть новий обліковий запис, щоб розпочати';

  @override
  String get signInSubtitle => 'Увійдіть у ваш обліковий запис';

  @override
  String get orContinueWith => 'Або продовжте з';

  @override
  String get continueWithGoogle => 'Продовжити через Google';

  @override
  String get authenticationRequired => 'Потрібна автентифікація';

  @override
  String get authenticationRequiredMessage =>
      'Ця функція доступна лише для автентифікованих користувачів. Будь ласка, увійдіть, щоб продовжити.';

  @override
  String get signInToContinue => 'Увійти, щоб продовжити';

  @override
  String get partyHub => 'Центр вечірок';

  @override
  String get welcomeToPartyBar => 'Ласкаво просимо до PartyBar!';

  @override
  String get joinOrCreateParty =>
      'Приєднайтесь до вечірки або створіть свій власний коктейльний досвід';

  @override
  String get joinParty => 'Приєднатися до вечірки';

  @override
  String get joinPartySubtitle =>
      'Введіть код вечірки, щоб приєднатися до веселощів';

  @override
  String get createParty => 'Створити вечірку';

  @override
  String get createPartySubtitle => 'Організуйте власну коктейльну вечірку';

  @override
  String get partyQuickInfo =>
      'Хости можуть керувати замовленнями, а гості переглядати коктейлі в режимі реального часу!';
}
