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
  String get loading => 'Завантаження...';

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
  String get partyIdle => 'Не розпочата';

  @override
  String get confirmEndParty => 'Підтвердити завершення вечірки';

  @override
  String get confirmEndPartyMessage =>
      'Ви впевнені, що хочете завершити цю вечірку? Цю дію не можна скасувати.';

  @override
  String get goToHostDashboard => 'Перейти до панелі господаря';

  @override
  String get goToPartyMenu => 'Перейти до меню вечірки';

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

  @override
  String cocktailsSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Обрано $count коктейлів',
      few: 'Обрано $count коктейлі',
      one: 'Обрано 1 коктейль',
    );
    return '$_temp0';
  }

  @override
  String get selectCocktails => 'Оберіть коктейлі';

  @override
  String addSelectedCocktails(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Зберегти $count коктейлів',
      few: 'Зберегти $count коктейлі',
      one: 'Зберегти 1 коктейль',
    );
    return '$_temp0';
  }

  @override
  String get cocktailsAlreadyAdded => 'Всі обрані коктейлі вже додані';

  @override
  String cocktailsAddedSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count коктейлів успішно додано',
      few: '$count коктейлі успішно додано',
      one: '1 коктейль успішно додано',
    );
    return '$_temp0';
  }

  @override
  String failedToAddCocktails(String error) {
    return 'Не вдалося додати коктейлі: $error';
  }

  @override
  String get noPendingOrders => 'Немає очікуючих замовлень';

  @override
  String get ordersWillAppear =>
      'Замовлення з\'являться тут, коли гості їх розмістять';

  @override
  String get unknownCocktail => 'Невідомий коктейль';

  @override
  String forGuest(String guestName) {
    return 'Для: $guestName';
  }

  @override
  String ordered(String time) {
    return 'Замовлено: $time';
  }

  @override
  String get justNow => 'Щойно';

  @override
  String minutesAgo(int minutes) {
    return '$minutesхв тому';
  }

  @override
  String hoursAgo(int hours) {
    return '$hoursгод тому';
  }

  @override
  String get startPreparing => 'Почати готувати';

  @override
  String get markReady => 'Позначити готовим';

  @override
  String get markDelivered => 'Позначити доставленим';

  @override
  String get newOrders => 'Нові замовлення';

  @override
  String get preparing => 'Готується';

  @override
  String get readyForPickup => 'Готово до видачі';

  @override
  String get orders => 'Замовлення';

  @override
  String ordersCount(int count) {
    return 'Замовлення ($count)';
  }

  @override
  String get stats => 'Статистика';

  @override
  String get menu => 'Меню';

  @override
  String get totalOrders => 'Всього замовлень';

  @override
  String get completed => 'Виконано';

  @override
  String get pending => 'Очікує';

  @override
  String get activeTime => 'Час активності';

  @override
  String get partyOverview => 'Огляд вечірки';

  @override
  String get popularCocktails => 'Популярні коктейлі';

  @override
  String get noOrdersYet => 'Ще немає замовлень';

  @override
  String availableCocktails(int count) {
    return 'Доступні коктейлі ($count)';
  }

  @override
  String get noCocktailsAvailable => 'Немає доступних коктейлів';

  @override
  String get addCocktailsToMenu => 'Додайте коктейлі до меню вечірки';

  @override
  String get errorLoadingCocktailsList => 'Помилка завантаження коктейлів';

  @override
  String get partyCopiedToClipboard => 'Код вечірки скопійовано!';

  @override
  String get partyQRCode => 'QR-код вечірки';

  @override
  String get qrCodeMock => 'QR-КОД\n(Макет)';

  @override
  String code(String code) {
    return 'Код: $code';
  }

  @override
  String get close => 'Закрити';

  @override
  String get partyResumed => 'Вечірку відновлено';

  @override
  String get partyPausedMessage => 'Вечірку призупинено';

  @override
  String failedToUpdateOrder(String error) {
    return 'Не вдалося оновити замовлення: $error';
  }

  @override
  String failedToUpdatePartyStatus(String error) {
    return 'Не вдалося оновити статус вечірки: $error';
  }

  @override
  String orderMarkedAs(String cocktail, String guest, String status) {
    return '$cocktail для $guest позначено як $status';
  }

  @override
  String errorWithMessage(String message) {
    return 'Помилка: $message';
  }

  @override
  String get joinPartyTitle => 'Приєднатися до вечірки';

  @override
  String get joinTheParty => 'Приєднайтеся до вечірки!';

  @override
  String get enterPartyCodeToOrder =>
      'Введіть код вечірки, щоб почати замовляти коктейлі';

  @override
  String get yourName => 'Ваше ім\'я';

  @override
  String get enterYourName => 'Введіть ваше ім\'я';

  @override
  String get partyCode => 'Код вечірки';

  @override
  String get enterPartyCode => 'Введіть 6-значний код вечірки';

  @override
  String get scanQRCode => 'Сканувати QR-код';

  @override
  String get qrCodeScannedSuccess => 'QR-код успішно відсканований!';

  @override
  String get pleaseEnterNameAndCode =>
      'Будь ласка, введіть код вечірки та ваше ім\'я';

  @override
  String get askHostForCode =>
      'Попросіть господаря вечірки надати 6-значний код або відскануйте їхній QR-код';

  @override
  String get partyNotFound =>
      'Вечірку не знайдено. Перевірте код і спробуйте ще раз.';

  @override
  String get joiningParty => 'Приєднання до вечірки...';

  @override
  String get orderCocktail => 'Замовити коктейль';

  @override
  String get specialRequests => 'Особливі побажання';

  @override
  String get specialRequestsHint => 'наприклад, більше лайма, без цукру...';

  @override
  String get optional => '(необов\'язково)';

  @override
  String orderConfirmation(String cocktailName) {
    return 'Замовити $cocktailName';
  }

  @override
  String orderConfirmMessage(String cocktailName) {
    return 'Ви впевнені, що хочете замовити $cocktailName?';
  }

  @override
  String cocktailOrderedSuccess(String cocktailName) {
    return '$cocktailName успішно замовлено!';
  }

  @override
  String failedToOrderCocktail(String error) {
    return 'Не вдалося замовити коктейль: $error';
  }

  @override
  String get myOrders => 'Мої замовлення';

  @override
  String get myStats => 'Моя статистика';

  @override
  String get ordersPlaced => 'Зроблено замовлень';

  @override
  String get cocktailsTried => 'Спробовано коктейлів';

  @override
  String get favoriteCocktail => 'Улюблений коктейль';

  @override
  String get noFavoriteYet => 'Ще немає улюбленого';

  @override
  String get youHaventOrderedYet => 'Ви ще не замовили жодного коктейлю';

  @override
  String get startOrderingFromMenu => 'Почніть замовляти з меню!';

  @override
  String get alreadyTried => 'Вже спробували';

  @override
  String welcome(String name) {
    return 'Ласкаво просимо, $name!';
  }

  @override
  String get viewRecipe => 'Переглянути рецепт';

  @override
  String get orderNow => 'Замовити зараз';
}
