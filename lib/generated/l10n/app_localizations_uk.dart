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

  @override
  String get createPartyTitle => 'Створити вечірку';

  @override
  String get createYourParty => 'Створіть свою вечірку';

  @override
  String get createPartyDescription =>
      'Налаштуйте коктейльну вечірку та запросіть гостей';

  @override
  String get partyDetails => 'Деталі вечірки';

  @override
  String get partyNameLabel => 'Назва вечірки *';

  @override
  String get partyNameHint => 'напр., День народження Сари';

  @override
  String get partyDescriptionLabel => 'Опис (необов\'язково)';

  @override
  String get partyDescriptionHint => 'Розкажіть гостям про вашу вечірку...';

  @override
  String get selectAvailableCocktails => 'Виберіть доступні коктейлі *';

  @override
  String selectedCount(int count) {
    return 'Обрано: $count';
  }

  @override
  String get allClassic => 'Всі класичні';

  @override
  String get tikiAndFrozen => 'Тікі та заморожені';

  @override
  String get createPartyButton => 'Створити вечірку';

  @override
  String get pleaseEnterPartyName => 'Будь ласка, введіть назву вечірки';

  @override
  String get pleaseSelectCocktail =>
      'Будь ласка, виберіть хоча б один коктейль';

  @override
  String get cocktail => 'Коктейль';

  @override
  String get invitationCode => 'Код запрошення';

  @override
  String get shareCode => 'Поділитися кодом';

  @override
  String get copyCode => 'Копіювати код';

  @override
  String get codeCopied => 'Код скопійовано';

  @override
  String get partyCocktails => 'Коктейлі вечірки';

  @override
  String get addCocktails => 'Додати коктейлі';

  @override
  String get removeCocktail => 'Видалити коктейль';

  @override
  String get noCocktailsAdded => 'Коктейлі не додані';

  @override
  String get editPartyInfo => 'Редагувати інформацію про вечірку';

  @override
  String get saveChanges => 'Зберегти зміни';

  @override
  String get cancel => 'Скасувати';

  @override
  String get partyStatus => 'Статус вечірки';

  @override
  String get startParty => 'Почати вечірку';

  @override
  String get pauseParty => 'Призупинити вечірку';

  @override
  String get resumeParty => 'Відновити вечірку';

  @override
  String get endParty => 'Завершити вечірку';

  @override
  String get partyActive => 'Вечірка активна';

  @override
  String get partyPaused => 'Вечірка призупинена';

  @override
  String get partyEnded => 'Вечірка завершена';

  @override
  String get confirmEndParty => 'Підтвердити завершення вечірки';

  @override
  String get confirmEndPartyMessage =>
      'Ви впевнені, що хочете завершити цю вечірку? Цю дію не можна скасувати.';

  @override
  String get partyAdminPanel => 'Панель адміністратора вечірки';

  @override
  String get myHostedParties => 'Мої вечірки';

  @override
  String get viewMyParties => 'Переглянути мої вечірки';

  @override
  String get noHostedParties => 'Ви ще не організували жодної вечірки';

  @override
  String get createFirstParty => 'Створіть свою першу вечірку, щоб почати!';

  @override
  String get viewDetails => 'Переглянути деталі';
}
