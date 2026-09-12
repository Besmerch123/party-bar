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
  String get navigationMyBar => 'Мій бар';

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

  @override
  String get later => 'Пізніше';

  @override
  String get continueLabel => 'Продовжити';

  @override
  String get splashTagline =>
      'Ваша полиця. Їхні замовлення.\nОдин бар на весь вечір.';

  @override
  String get onboardingBarEyebrow => 'Що у вас є';

  @override
  String get onboardingBarTitle => 'Ваша полиця\nстає меню';

  @override
  String get onboardingBarBody =>
      'Скажіть PartyBar, які пляшки у вас є. Він визначить усі коктейлі, які ви вже можете налити — і той один лайм, що відкриє ще одинадцять.';

  @override
  String get onboardingBarStatShelf => 'Джин, горілка, тонік';

  @override
  String get onboardingBarStatPourable => 'Можна налити';

  @override
  String get onboardingBarStatUnlock => 'Додайте один лайм';

  @override
  String get onboardingOrdersEyebrow => 'Що роблять вони';

  @override
  String get onboardingOrdersTitle => 'Вони замовляють.\nВи отримуєте чергу.';

  @override
  String get onboardingOrdersBody =>
      'Гості сканують код і замовляють зі свого телефону. Без додатка, без акаунту. Ви просто виконуєте список.';

  @override
  String get onboardingOrdersCta => 'Налаштувати мій бар';

  @override
  String get onboardingSampleGinTonic => 'Джин-тонік';

  @override
  String get onboardingSampleCosmopolitan => 'Космополітен';

  @override
  String get onboardingSampleOrderNote => 'Марта · більше лайма';

  @override
  String get onboardingSampleOrderWaiting => 'Данило · чекає 2 хв';

  @override
  String get orderStatusNew => 'Нове';

  @override
  String get orderStatusQueued => 'У черзі';

  @override
  String get onboardingVibeTitle => 'Що ви\nлюбите пити?';

  @override
  String get onboardingVibeBody =>
      'Оберіть два-три. Це лише сортує стрічку — нічого не приховується.';

  @override
  String get vibeSharpCitrus => 'Різкі й цитрусові';

  @override
  String get vibeDarkStirred => 'Темні й змішані';

  @override
  String get vibeLongFizzy => 'Довгі й газовані';

  @override
  String get vibeSpicy => 'Гострі';

  @override
  String get vibeZeroProof => 'Безалкогольні';

  @override
  String get vibeThreeIngredients => 'Максимум три інгредієнти';

  @override
  String get onboardingBottlesTitle => 'П\'ять пляшок —\nбар відкрито';

  @override
  String get onboardingBottlesBody =>
      'Оберіть те, що справді є на полиці. Решта може почекати.';

  @override
  String get onboardingBottlesSearchHint => 'Пошук пляшок і міксерів';

  @override
  String get onboardingBottlesSection => 'Зазвичай є в кожному барі';

  @override
  String get onboardingBottlesNoMatch => 'За цим запитом нічого не знайдено.';

  @override
  String get onboardingOpenBar => 'Відкрити мій бар';

  @override
  String bottleInCocktails(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'у $count коктейлях',
      many: 'у $count коктейлях',
      few: 'у $count коктейлях',
      one: 'у $count коктейлі',
    );
    return '$_temp0';
  }

  @override
  String bottleUnlocksMore(int count) {
    return 'відкриває ще $count';
  }

  @override
  String onboardingBottlesAdded(int count, int total) {
    return 'Додано $count з $total';
  }

  @override
  String onboardingDrinksUnlocked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Відкрито $count напоїв',
      many: 'Відкрито $count напоїв',
      few: 'Відкрито $count напої',
      one: 'Відкрито $count напій',
    );
    return '$_temp0';
  }

  @override
  String get bottleGin => 'Джин';

  @override
  String get bottleVodka => 'Горілка';

  @override
  String get bottleTonic => 'Тонік';

  @override
  String get bottleLime => 'Лайм';

  @override
  String get bottleWhiteRum => 'Білий ром';

  @override
  String get bottleSweetVermouth => 'Солодкий вермут';

  @override
  String get bottleWhiskey => 'Віскі';

  @override
  String get bottleTequila => 'Текіла';

  @override
  String get bottleTripleSec => 'Трипл-сек';

  @override
  String get bottleLemon => 'Лимон';

  @override
  String get bottleSimpleSyrup => 'Цукровий сироп';

  @override
  String get bottleSodaWater => 'Содова вода';

  @override
  String get bottleAngostura => 'Ангостура біттер';

  @override
  String get bottleMint => 'М\'ята';

  @override
  String get bottleShaker => 'Шейкер';

  @override
  String get exploreFeedTitle => 'Наливаємо сьогодні';

  @override
  String exploreShelfMatch(int makeable, int total) {
    return '$makeable з $total напоїв підходять до вашої полиці';
  }

  @override
  String exploreNoShelfYet(int total) {
    return '$total напоїв. Додайте пляшку, щоб побачити, що можна налити.';
  }

  @override
  String get exploreSectionTwoBottles => 'Дві пляшки, один напій';

  @override
  String get exploreSectionZeroProof => 'Без алкоголю';

  @override
  String get exploreSectionMakeableNow => 'Готове з вашої полиці';

  @override
  String get exploreSeeAll => 'Усі';

  @override
  String exploreAllOnShelf(int count) {
    return '$count з вашої полиці';
  }

  @override
  String exploreMissingBadge(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'бракує $count',
      one: 'бракує 1',
    );
    return '$_temp0';
  }

  @override
  String exploreNeedsIngredient(String ingredient) {
    return 'потрібно: $ingredient';
  }

  @override
  String get exploreEmptyTitle => 'Тут поки порожньо';

  @override
  String get exploreEmptyBody =>
      'Не вдалося завантажити каталог. Потягніть, щоб спробувати ще раз.';

  @override
  String cocktailMinutes(int count) {
    return '$count хв';
  }

  @override
  String cocktailAbv(String value) {
    return '$value% алк.';
  }

  @override
  String get methodBuilt => 'у склянці';

  @override
  String get methodStirred => 'на ложці';

  @override
  String get methodShaken => 'у шейкері';

  @override
  String get methodBlended => 'у блендері';

  @override
  String get methodLayered => 'шарами';

  @override
  String get spiritGin => 'Джин';

  @override
  String get spiritVodka => 'Горілка';

  @override
  String get spiritRum => 'Ром';

  @override
  String get spiritWhisky => 'Віскі';

  @override
  String get spiritTequila => 'Текіла';

  @override
  String get spiritBrandy => 'Бренді';

  @override
  String get spiritZeroProof => 'Без алкоголю';

  @override
  String get spiritOther => 'Інше';

  @override
  String get flavorCitrus => 'Цитрус';

  @override
  String get flavorBitter => 'Гіркий';

  @override
  String get flavorSweet => 'Солодкий';

  @override
  String get flavorHerbal => 'Трав’яний';

  @override
  String get flavorSpicy => 'Пряний';

  @override
  String get flavorFruity => 'Фруктовий';

  @override
  String get flavorDry => 'Сухий';

  @override
  String get flavorCreamy => 'Вершковий';

  @override
  String get unitMl => 'мл';

  @override
  String get unitCl => 'сл';

  @override
  String get unitOz => 'унц';

  @override
  String get unitDash => 'крапля';

  @override
  String get unitBarspoon => 'барна ложка';

  @override
  String get unitPiece => 'шт';

  @override
  String get unitSplash => 'трохи';

  @override
  String get unitTopUp => 'долити';

  @override
  String measureAmount(String amount, String unit) {
    return '$amount $unit';
  }

  @override
  String get searchHint => 'Коктейль, напій або настрій';

  @override
  String get searchCancel => 'Скасувати';

  @override
  String get searchRecent => 'Нещодавні';

  @override
  String get searchClearRecent => 'Очистити';

  @override
  String get searchPopularThisWeek => 'Популярне цього тижня';

  @override
  String get searchBrowseBySpirit => 'За основою';

  @override
  String get searchClearQuery => 'Очистити пошук';

  @override
  String get filterSheetTitle => 'Фільтр';

  @override
  String get filterReset => 'Скинути';

  @override
  String get filterOpen => 'Фільтри';

  @override
  String get filterMakeableTitle => 'Можна з моєї полиці';

  @override
  String filterMakeableSubtitle(int bottles, int drinks) {
    String _temp0 = intl.Intl.pluralLogic(
      bottles,
      locale: localeName,
      other: '$bottles пляшок на полиці',
      one: '1 пляшка на полиці',
    );
    return '$_temp0 · $drinks напоїв';
  }

  @override
  String get filterMakeableEmptyBar => 'На полиці ще немає пляшок';

  @override
  String get filterSectionSort => 'Сортування';

  @override
  String get filterSectionBaseSpirit => 'Основа';

  @override
  String get filterSectionEffort => 'Зусилля';

  @override
  String get sortMakeable => 'Можливі';

  @override
  String get sortPopular => 'Популярні';

  @override
  String get sortSeasonal => 'Сезонні';

  @override
  String get filterUnderThreeMinutes => 'Менше 3 хвилин';

  @override
  String get filterNoShaker => 'Без шейкера';

  @override
  String get filterThreeIngredients => 'Максимум три інгредієнти';

  @override
  String filterShowDrinks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Показати $count напоїв',
      one: 'Показати 1 напій',
      zero: 'Немає збігів',
    );
    return '$_temp0';
  }

  @override
  String get filterChipMakeable => 'Можливі';

  @override
  String get filterChipNoShaker => 'Без шейкера';

  @override
  String get filterChipUnderThree => 'До 3 хв';

  @override
  String get filterChipThreeIngredients => 'До 3 частин';

  @override
  String filterRemove(String filter) {
    return 'Прибрати: $filter';
  }

  @override
  String resultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count напоїв',
      one: '1 напій',
      zero: 'Немає напоїв',
    );
    return '$_temp0';
  }

  @override
  String get resultsMakeableFirst => 'спочатку можливі';

  @override
  String get resultsPopularFirst => 'спочатку популярні';

  @override
  String get resultsSeasonalFirst => 'спочатку сезонні';

  @override
  String get zeroResultsTitle => 'Поки нічого не знайшлося';

  @override
  String zeroResultsBlockedTitle(String filter) {
    return 'Заважає фільтр: $filter';
  }

  @override
  String zeroResultsBody(String query, String filter) {
    return 'Немає збігів для “$query” із фільтром $filter. Приберіть його або спробуйте щось із цього.';
  }

  @override
  String zeroResultsBodyNoQuery(String filter) {
    return 'Немає збігів із фільтром $filter. Приберіть його або спробуйте щось із цього.';
  }

  @override
  String zeroResultsBodyPlain(String query) {
    return 'Немає збігів для “$query”. Спробуйте інше слово або щось із цього.';
  }

  @override
  String zeroResultsDropFilter(String filter) {
    return 'Прибрати “$filter”';
  }

  @override
  String get zeroResultsClearAll => 'Скинути все';

  @override
  String get zeroResultsOneBottleAway => 'Одна пляшка до мети';

  @override
  String zeroResultsUnlocks(String ingredient, int count) {
    return 'додайте $ingredient · відкриє $count';
  }

  @override
  String zeroResultsUnlocksUnknown(String ingredient) {
    return 'додайте $ingredient';
  }

  @override
  String get zeroResultsPourable => 'Це можна налити вже сьогодні';

  @override
  String get addToBar => 'Додати на полицю';

  @override
  String addedToBar(String ingredient) {
    return '$ingredient тепер на вашій полиці';
  }

  @override
  String get cocktailSave => 'Зберегти';

  @override
  String get cocktailShare => 'Поділитися';

  @override
  String get cocktailBack => 'Назад';

  @override
  String get cocktailNotOnShelf => 'немає на полиці';

  @override
  String cocktailAddUnlocks(String ingredient, int count) {
    return 'Додайте $ingredient на полицю — відкриє ще $count';
  }

  @override
  String cocktailAddToBarPlain(String ingredient) {
    return 'Додайте $ingredient на полицю';
  }

  @override
  String get cocktailMakeItNow => 'Готувати зараз';

  @override
  String get cocktailAddToParty => 'Додати до вечірки';

  @override
  String get cocktailIngredientsTitle => 'Інгредієнти';

  @override
  String get cocktailRecipeCopied => 'Рецепт скопійовано';

  @override
  String pourStepCounter(int step, int total, String cocktail) {
    return 'Крок $step з $total · $cocktail';
  }

  @override
  String get pourTimerHint => 'Торкніться, щоб запустити таймер';

  @override
  String get pourTimerRunning => 'Триває';

  @override
  String get pourTimerDone => 'Час вийшов';

  @override
  String get pourNext => 'Далі';

  @override
  String get pourFinish => 'Готово';

  @override
  String get pourBack => 'Попередній крок';

  @override
  String get pourExit => 'Зупинити';

  @override
  String get pourShowRecipe => 'Рецепт';

  @override
  String pourFinished(String cocktail) {
    return '$cocktail готовий. Смачного.';
  }

  @override
  String get pourNoSteps => 'Для цього напою ще немає покрокового рецепта.';

  @override
  String authGateSaveTitle(String cocktail) {
    return 'Зберегти $cocktail';
  }

  @override
  String get authGateSaveBody =>
      'Збережені напої живуть у вашому акаунті й переживуть новий телефон. Полиця та все переглянуте переїде разом із вами.';

  @override
  String get authGateLists => 'Списки, що синхронізуються';

  @override
  String get authGateHost => 'Проводьте вечірку та приймайте замовлення';

  @override
  String authGateShelf(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ваші $count пляшок переїдуть з вами',
      one: 'Ваша 1 пляшка переїде з вами',
      zero: 'Ваша полиця переїде з вами',
    );
    return '$_temp0';
  }

  @override
  String get authGateApple => 'Продовжити з Apple';

  @override
  String get authGateEmail => 'Через електронну пошту';

  @override
  String get authGateKeepBrowsing => 'Далі без акаунта';

  @override
  String get authContinueGoogle => 'Продовжити з Google';

  @override
  String get authContinueApple => 'Продовжити з Apple';

  @override
  String get authAppleSoon => 'Скоро';

  @override
  String authLegalLine(String terms, String privacy) {
    return 'Продовжуючи, ви погоджуєтесь із $terms та $privacy.';
  }

  @override
  String get authTerms => 'Умовами';

  @override
  String get authPrivacy => 'Політикою конфіденційності';

  @override
  String get authBarrierEyebrow => 'Залишився один крок';

  @override
  String get authBarrierHostTitle => 'У вечірки має бути господар';

  @override
  String get authBarrierHostBody =>
      'Щоб гості приєднувались за вашим посиланням, а меню було на місці й наступної суботи. Чернетка збережеться у будь-якому разі.';

  @override
  String get authBarrierBarTitle => 'Не втрачайте цю полицю';

  @override
  String get authBarrierBarBody =>
      'Увійдіть через Google — і полиця перейде на наступний телефон. У будь-якому разі вона й далі працюватиме на цьому.';

  @override
  String get authNotNow => 'Не зараз';

  @override
  String get authProvidersEyebrow => 'Ваш бар скрізь';

  @override
  String get authProvidersTitle => 'Один акаунт.\nУсі вечірки.';

  @override
  String get authProvidersBody =>
      'Ваша полиця, збережені напої та кожна вечірка, яку ви провели — на будь-якому телефоні.';

  @override
  String get authAgeNote => 'Лише 18+ · ми нічого не публікуємо';

  @override
  String get authSignedInBadge => 'Ви увійшли';

  @override
  String get authNameTitle => 'Як вас бачитимуть\nгості?';

  @override
  String get authNameBody =>
      'Це єдине, що інші на вечірці бачать поруч із вашими замовленнями.';

  @override
  String get authAddPhoto => 'Додати фото';

  @override
  String get authAddPhotoNote => 'Необов\'язково. Літери цілком достатньо.';

  @override
  String get authDisplayNameLabel => 'Ім\'я для гостей';

  @override
  String get authDisplayNameHint => 'Марта';

  @override
  String get authAgeConfirm => 'Мені 18 або більше';

  @override
  String authAgeLegal(String terms, String privacy) {
    return 'PartyBar — для людей повнолітнього віку. Див. $terms та $privacy.';
  }

  @override
  String get authNameRequired => 'Оберіть ім\'я, яке гості впізнають.';

  @override
  String get authAgeRequired => 'Підтвердьте, що вам є 18, щоб продовжити.';

  @override
  String get authFinishHost => 'Створити вечірку';

  @override
  String get authFinishBar => 'Відкрити мій бар';

  @override
  String get authFinishSave => 'Зберегти напій';

  @override
  String get authFinishGeneric => 'Продовжити';

  @override
  String authSignedInAs(String name) {
    return 'Увійшли як $name';
  }

  @override
  String get authDraftKept => 'Чернетка збереглась, поки ви входили';

  @override
  String get authDraftRestored => 'Відновлено';

  @override
  String guestLiveAt(String party) {
    return 'Наживо · $party';
  }

  @override
  String get guestTitle => 'Ви біля бару';

  @override
  String guestBody(String host) {
    return 'Акаунт не потрібен. $host просто має знати, чий це напій.';
  }

  @override
  String get guestBodyNoHost =>
      'Акаунт не потрібен. Господар просто має знати, чий це напій.';

  @override
  String get guestNameLabel => 'Як до вас звертатись?';

  @override
  String get guestNameHint => 'Ваше ім\'я';

  @override
  String get guestNameRequired => 'Нам достатньо лише імені.';

  @override
  String get guestStartOrdering => 'Почати замовляти';

  @override
  String get guestAgeNote => 'Замовляючи, ви підтверджуєте, що вам є 18';

  @override
  String get guestHaveAccount => 'Є акаунт? Увійти';

  @override
  String get claimHeadline => 'Ось це була ніч';

  @override
  String claimSubline(int count, String party) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count напою · $party',
      many: '$count напоїв · $party',
      few: '$count напої · $party',
      one: '1 напій · $party',
    );
    return '$_temp0';
  }

  @override
  String claimTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Зберегти сьогоднішні $count напою?',
      many: 'Зберегти сьогоднішні $count напоїв?',
      few: 'Зберегти сьогоднішні $count напої?',
      one: 'Зберегти сьогоднішній напій?',
    );
    return '$_temp0';
  }

  @override
  String get claimBody =>
      'Акаунт зберігає те, що ви пили, і наступного разу бар уже знатиме ваш смак. Пропустіть — і сьогоднішнє нікуди не зникне.';

  @override
  String claimMore(int count) {
    return '+$count';
  }

  @override
  String get claimWithGoogle => 'Зберегти з Google';

  @override
  String get claimWithApple => 'Apple';

  @override
  String get claimNoThanks => 'Ні, дякую';

  @override
  String authErrorDifferentProvider(String email) {
    return 'Для $email ви вже користуєтесь Google.';
  }

  @override
  String get authErrorDifferentProviderNoEmail =>
      'Для цієї адреси ви вже користуєтесь Google.';

  @override
  String get authErrorOffline =>
      'Немає з\'єднання. Чернетка лишається на телефоні — увійдемо, коли відновиться.';

  @override
  String get authErrorGeneric => 'Вхід не вдався. Спробуйте ще раз.';

  @override
  String get authErrorRetry => 'Спробувати знову';

  @override
  String get authBack => 'Назад';

  @override
  String get authClose => 'Закрити';

  @override
  String get barTitle => 'Мій бар';

  @override
  String get barEmptyBody =>
      'На полиці поки нічого немає. Позначте, що у вас є, — це залишиться на телефоні, доки ви не увійдете.';

  @override
  String get barEmptyBodySignedIn =>
      'На полиці поки нічого немає. Позначте, що у вас є.';

  @override
  String get barSearchHint => 'Пляшки, міксери, інструменти…';

  @override
  String get barStartersSection => 'З цього починає більшість барів';

  @override
  String get barAddAll => 'Додати все';

  @override
  String get barStartersFooter => 'Дванадцять підказок, а далі — пошук';

  @override
  String barInDrinks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'У $count напоях',
      many: 'У $count напоях',
      few: 'У $count напоях',
      one: 'У $count напої',
    );
    return '$_temp0';
  }

  @override
  String barInDrinksInline(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'у $count напоях',
      many: 'у $count напоях',
      few: 'у $count напоях',
      one: 'у $count напої',
    );
    return '$_temp0';
  }

  @override
  String barNeededForDrinks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Потрібно для $count напоїв',
      many: 'Потрібно для $count напоїв',
      few: 'Потрібно для $count напоїв',
      one: 'Потрібно для $count напою',
    );
    return '$_temp0';
  }

  @override
  String get barOnYourShelf => 'На вашій полиці';

  @override
  String barShelfCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count на полиці',
      one: '1 на полиці',
    );
    return '$_temp0';
  }

  @override
  String barMakeableCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count напоїв, які ви можете приготувати',
      many: '$count напоїв, які ви можете приготувати',
      few: '$count напої, які ви можете приготувати',
      one: '$count напій, який ви можете приготувати',
    );
    return '$_temp0';
  }

  @override
  String barThingsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count речей',
      many: '$count речей',
      few: '$count речі',
      one: '$count річ',
    );
    return '$_temp0';
  }

  @override
  String get barFilterAll => 'Усе';

  @override
  String get barSectionSpirits => 'Алкоголь';

  @override
  String get barSectionMixers => 'Міксери';

  @override
  String get barSectionFresh => 'Свіже';

  @override
  String get barSectionSyrups => 'Сиропи';

  @override
  String get barSectionTools => 'Інструменти';

  @override
  String get barSectionIce => 'Лід';

  @override
  String get barSectionOther => 'Інше';

  @override
  String get barGroupSpirits => 'Алкоголь і лікери';

  @override
  String get barGroupMixers => 'Міксери';

  @override
  String get barGroupFresh => 'Свіже';

  @override
  String get barGroupSyrups => 'Сиропи й біттери';

  @override
  String get barGroupTools => 'Інструменти й посуд';

  @override
  String get barGroupIce => 'Лід';

  @override
  String get barGroupOther => 'Усе інше';

  @override
  String barInYourDrinks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'У $count з ваших напоїв',
      one: 'У 1 з ваших напоїв',
    );
    return '$_temp0';
  }

  @override
  String barNeededForYourDrinks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Потрібен для $count з ваших напоїв',
      one: 'Потрібен для 1 з ваших напоїв',
    );
    return '$_temp0';
  }

  @override
  String get barAddedJustNow => 'Щойно додано';

  @override
  String get barNotInYourBar => 'Немає у вашому барі';

  @override
  String get barRanOutGroup => 'Закінчилось';

  @override
  String get barAddAllToList => 'Додати все у список';

  @override
  String barBlocksDrinks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Блокує $count напоїв',
      many: 'Блокує $count напоїв',
      few: 'Блокує $count напої',
      one: 'Блокує $count напій',
    );
    return '$_temp0';
  }

  @override
  String get barOnYourList => 'У вашому списку';

  @override
  String get barAddToList => 'Додати у список';

  @override
  String get barFreshInfo =>
      'Свіжі продукти псуються, тож ми питаємо, що закінчилось, лише коли вечірка завершується — ніколи посеред неї.';

  @override
  String get barOpenList => 'Список покупок';

  @override
  String get barAddItem => 'Додати у мій бар';

  @override
  String barMarkRanOut(String item) {
    return 'Позначити “$item” як закінчене';
  }

  @override
  String barPutBack(String item) {
    return 'Повернути “$item” на полицю';
  }

  @override
  String get barSheetOnShelf => 'На полиці';

  @override
  String get barSheetRanOut => 'Закінчилось — додати у список';

  @override
  String get barSheetNote => 'Нотатка';

  @override
  String get barSheetNoteHint => 'Бренд, пляшка, де зберігається…';

  @override
  String get barSheetNoteAdd => 'Додати';

  @override
  String get barSheetNoteSave => 'Зберегти';

  @override
  String get barSheetRemove => 'Прибрати з мого бару';

  @override
  String get barSheetUnlocks => 'Відкриває для вас';

  @override
  String get barSheetMore => 'ще';

  @override
  String get barSheetDone => 'Готово';

  @override
  String barRemoved(String item) {
    return '“$item” прибрано';
  }

  @override
  String get barUndo => 'Скасувати';

  @override
  String get barSearchCancel => 'Скасувати';

  @override
  String barSearchMatches(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count збігів',
      many: '$count збігів',
      few: '$count збіги',
      one: '1 збіг',
      zero: 'Немає збігів',
    );
    return '$_temp0';
  }

  @override
  String get barAlreadyOnShelf => 'Уже на вашій полиці';

  @override
  String get barRanOutTapRestock => 'Закінчилось · торкніться, щоб повернути';

  @override
  String barAddCustom(String query) {
    return 'Не знайшли? Додайте “$query” як власну пляшку';
  }

  @override
  String barAddCustomToList(String query) {
    return 'Не знайшли? Додайте “$query” у список';
  }

  @override
  String get barCustomItem => 'Ваша власна пляшка';

  @override
  String get barSearchListHint => 'Що вам потрібно?';

  @override
  String get barAlreadyOnList => 'Уже у вашому списку';

  @override
  String get barCatalogueOffline =>
      'Поки що лише стартовий список — повний каталог потребує з\'єднання.';

  @override
  String get shoppingListTitle => 'Список покупок';

  @override
  String shoppingListSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count речей · позначте одну — і вона потрапить на полицю',
      many: '$count речей · позначте одну — і вона потрапить на полицю',
      few: '$count речі · позначте одну — і вона потрапить на полицю',
      one: '1 річ · позначте — і вона потрапить на полицю',
      zero: 'Нічого купувати',
    );
    return '$_temp0';
  }

  @override
  String get shoppingListBlockingHeader => 'Блокує ваші напої';

  @override
  String shoppingListBlockingLine(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Потрібен для $count напоїв, які ви могли б приготувати',
      many: 'Потрібен для $count напоїв, які ви могли б приготувати',
      few: 'Потрібен для $count напоїв, які ви могли б приготувати',
      one: 'Потрібен для $count напою, який ви могли б приготувати',
    );
    return '$_temp0';
  }

  @override
  String get shoppingListAlsoHeader => 'Також додано';

  @override
  String shoppingListRanOutAt(String party) {
    return 'Закінчилось на “$party”';
  }

  @override
  String get shoppingListRanOut => 'Закінчилось';

  @override
  String shoppingListForCocktail(String cocktail) {
    return 'Для “$cocktail”';
  }

  @override
  String get shoppingListAddedByYou => 'Додано вами';

  @override
  String get shoppingListNowOnShelf => 'Тепер на вашій полиці';

  @override
  String get shoppingListAddSomething => 'Додати щось інше…';

  @override
  String get shoppingListShare => 'Поділитися списком';

  @override
  String get shoppingListClearTicked => 'Прибрати позначені';

  @override
  String get shoppingListClearAll => 'Очистити весь список';

  @override
  String get shoppingListEmptyTitle => 'Нічого купувати';

  @override
  String get shoppingListEmptyBody =>
      'Сюди потрапляє те, що закінчилось, і все, що ви додасте самі.';

  @override
  String get shoppingListRemove => 'Прибрати зі списку';

  @override
  String get shareListTitle => 'Надіслати список';

  @override
  String get shareListHeading => 'PartyBar — список покупок';

  @override
  String get shareListPlainNote =>
      'Звичайний текст — отримувачу не потрібен застосунок';

  @override
  String get shareListShare => 'Поділитися';

  @override
  String get shareListCopy => 'Копіювати';

  @override
  String get shareListCopied => 'Список скопійовано';

  @override
  String get shareListIncludeWhy => 'Додати причину для кожного пункту';

  @override
  String ranOutDrinksPoured(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Налито $count напоїв',
      many: 'Налито $count напоїв',
      few: 'Налито $count напої',
      one: 'Налито $count напій',
    );
    return '$_temp0';
  }

  @override
  String get ranOutTitle => 'Щось закінчилось?';

  @override
  String get ranOutBody =>
      'Позначте, чого не стало. Усе, що пропустите, залишиться на полиці — ми ніколи не вгадуємо за тим, що наливали.';

  @override
  String get ranOutGone => 'Закінчилось · додається у список';

  @override
  String ranOutPoured(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Наливали сьогодні $count разів',
      many: 'Наливали сьогодні $count разів',
      few: 'Наливали сьогодні $count рази',
      one: 'Наливали сьогодні 1 раз',
    );
    return '$_temp0';
  }

  @override
  String ranOutUpdate(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Оновити мій бар · $count закінчилось',
      zero: 'Оновити мій бар',
    );
    return '$_temp0';
  }

  @override
  String get ranOutNothing => 'Нічого не закінчилось';

  @override
  String get ranOutEmpty => 'На полиці немає чого перевіряти.';

  @override
  String twoAwayEyebrow(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Бракує $count речей',
      two: 'Бракує двох речей',
    );
    return '$_temp0';
  }

  @override
  String twoAwayTitle(int have, int total) {
    return 'У вас є $have з $total';
  }

  @override
  String get twoAwayBody => 'Усе інше вже на вашій полиці.';

  @override
  String twoAwayAlsoBlocks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'також блокує ще $count',
      one: 'також блокує ще 1',
      zero: 'лише це',
    );
    return '$_temp0';
  }

  @override
  String twoAwayAddToList(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Додати всі $count у мій список',
      two: 'Додати обидва у мій список',
    );
    return '$_temp0';
  }

  @override
  String get twoAwayHaveThese => 'Насправді у мене це є';

  @override
  String get twoAwayFootnote =>
      '“У мене це є” додає їх у ваш бар — це єдине місце, де запас коли-небудь виправляють.';

  @override
  String twoAwayPrompt(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Бракує $count речей · дивитись',
      many: 'Бракує $count речей · дивитись',
      few: 'Бракує $count речей · дивитись',
      one: 'Бракує $count речі · дивитись',
    );
    return '$_temp0';
  }

  @override
  String get twoAwayAddedToList => 'У вашому списку';

  @override
  String get twoAwayAddedToBar => 'На вашій полиці';

  @override
  String get hostBarClosed => 'Бар зачинено';

  @override
  String get hostNothingPouring => 'Ще нічого\nне наливаємо';

  @override
  String get hostNothingPouringBody =>
      'Задайте назву й меню. Дві хвилини — і ваша кухня приймає замовлення.';

  @override
  String get hostPartyCta => 'Влаштувати вечірку';

  @override
  String get hostJoinWithCode => 'Приєднатися за кодом';

  @override
  String hostDraftMeta(int count, String time) {
    return 'Чернетка · у меню: $count · збережено $time';
  }

  @override
  String hostLiveMeta(int count) {
    return 'Наживо · у меню: $count';
  }

  @override
  String hostEndedMeta(int count) {
    return 'Налито: $count';
  }

  @override
  String get hostResume => 'Продовжити';

  @override
  String get hostRecap => 'Підсумок';

  @override
  String get hostOpen => 'Відкрити';

  @override
  String get hostNameTitle => 'Як назвемо\nвечірку?';

  @override
  String get hostNameBody =>
      'Гості побачать це, коли приєднаються. Змінити можна будь-коли.';

  @override
  String get hostNameHint => 'Назва вечірки';

  @override
  String get hostNameIdeaFriday => 'П’ятничний вечір';

  @override
  String get hostNameIdeaHousewarming => 'Новосілля';

  @override
  String get hostNameIdeaJustUs => 'Тільки ми вдвох';

  @override
  String get hostWhenLabel => 'Коли';

  @override
  String get hostWhenTonight => 'Сьогодні';

  @override
  String get hostWhenPickDate => 'Обрати дату';

  @override
  String get hostCodeDeadNote =>
      'Ніхто не приєднається, доки ви не відкриєте бар, — не поспішайте з меню.';

  @override
  String get hostNextMenu => 'Далі · меню';

  @override
  String get hostDraftSaveFailed =>
      'Не вдалося зберегти чернетку. Спробуйте ще раз.';

  @override
  String get hostMenuTitle => 'Що наливатимете?';

  @override
  String hostMenuBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count з них не потребують нічого, чого у вас немає.',
      many: '$count з них не потребують нічого, чого у вас немає.',
      few: '$count з них не потребують нічого, чого у вас немає.',
      one: '$count з них не потребує нічого, чого у вас немає.',
      zero:
          'Поки жоден не готується з вашого бару — пошукайте або перегляньте всі.',
    );
    return '$_temp0';
  }

  @override
  String get hostMenuSearchHint => 'Пошук коктейлів';

  @override
  String hostMenuFilterCanMake(int count) {
    return 'Можна зробити: $count';
  }

  @override
  String get hostMenuFilterAll => 'Усі коктейлі';

  @override
  String hostMenuCount(int count) {
    return 'У меню: $count';
  }

  @override
  String get hostMenuAddLater =>
      'Додати більше можна пізніше — навіть посеред вечірки';

  @override
  String get hostMenuReview => 'Переглянути';

  @override
  String hostMenuAdd(String name) {
    return 'Додати $name до меню';
  }

  @override
  String hostMenuRemove(String name) {
    return 'Прибрати $name з меню';
  }

  @override
  String get hostMenuLoadFailed => 'Не вдалося завантажити коктейлі.';

  @override
  String get hostRetry => 'Спробувати ще';

  @override
  String get hostSearchDone => 'Готово';

  @override
  String hostSearchMatches(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count збігу',
      many: '$count збігів',
      few: '$count збіги',
      one: '$count збіг',
    );
    return '$_temp0';
  }

  @override
  String get hostSearchOnlyMakeable => 'Лише те, що можу зробити';

  @override
  String hostBadgeNo(String ingredient) {
    return 'Немає: $ingredient';
  }

  @override
  String hostBadgeMissing(int count) {
    return 'Бракує: $count';
  }

  @override
  String get hostBadgeAllInStock => 'Усе є';

  @override
  String hostSearchShoppingTip(String ingredient) {
    return 'Додайте все одно — і $ingredient потрапить у список покупок.';
  }

  @override
  String hostSearchNoResults(String query) {
    return 'Нічого не знайдено за запитом «$query».';
  }

  @override
  String get hostAllTitle => 'Усі коктейлі';

  @override
  String get hostAllFilterAll => 'Усі';

  @override
  String hostAllReady(int count) {
    return 'Можна наливати · $count';
  }

  @override
  String hostAllNeedsShopping(int count) {
    return 'Треба докупити · $count';
  }

  @override
  String get hostAllClosestFirst => 'Спершу найближчі';

  @override
  String hostAllIngredientCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count інгредієнта',
      many: '$count інгредієнтів',
      few: '$count інгредієнти',
      one: '$count інгредієнт',
    );
    return '$_temp0';
  }

  @override
  String hostAllShort(int count, String ingredients) {
    return 'Бракує $count · $ingredients';
  }

  @override
  String hostAllDone(int count) {
    return 'Готово · у меню: $count';
  }

  @override
  String hostMissingOneTitle(String ingredient) {
    return 'Бракує одного: $ingredient';
  }

  @override
  String hostMissingManyTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Бракує $count інгредієнта',
      many: 'Бракує $count інгредієнтів',
      few: 'Бракує $count інгредієнтів',
      one: 'Бракує $count інгредієнта',
    );
    return '$_temp0';
  }

  @override
  String get hostMissingBody =>
      'Додайте в меню все одно — гості зможуть замовити, а нестачу бачитимете лише ви, не вони.';

  @override
  String get hostMissingOutOfStock => 'немає';

  @override
  String hostMissingAddAndBuyOne(String ingredient) {
    return 'Додати й купити: $ingredient';
  }

  @override
  String hostMissingAddAndBuyMany(int count) {
    return 'Додати й купити все ($count)';
  }

  @override
  String hostMissingShowMakeable(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Показати $count, що можу зробити',
      many: 'Показати $count, що можу зробити',
      few: 'Показати $count, що можу зробити',
      one: 'Показати $count, що можу зробити',
      zero: 'Показати, що можу зробити',
    );
    return '$_temp0';
  }

  @override
  String get hostMissingFootnote =>
      'Гості побачать позначку «обмежено», лише якщо щось закінчиться посеред вечірки.';

  @override
  String get hostDraftPill => 'Чернетка';

  @override
  String hostDraftMetaTonight(int count) {
    return 'Сьогодні · у меню: $count · бармен — ви';
  }

  @override
  String hostDraftMetaDate(String date, int count) {
    return '$date · у меню: $count · бармен — ви';
  }

  @override
  String get hostDraftMenuRow => 'Меню';

  @override
  String hostDraftDrinks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count напою',
      many: '$count напоїв',
      few: '$count напої',
      one: '$count напій',
    );
    return '$_temp0';
  }

  @override
  String get hostDraftWhenRow => 'Коли';

  @override
  String get hostDraftTonightOpen => 'Сьогодні, без кінця';

  @override
  String get hostDraftInviteRow => 'Код запрошення';

  @override
  String get hostDraftDead => 'Не діє';

  @override
  String hostDraftToBuy(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Купити $count речі',
      many: 'Купити $count речей',
      few: 'Купити $count речі',
      one: 'Купити $count річ',
    );
    return '$_temp0';
  }

  @override
  String hostDraftToBuyBody(String ingredients, String cocktails) {
    return '$ingredients. Доти $cocktails доведеться імпровізувати.';
  }

  @override
  String get hostDraftCanPour => 'Можна налити зараз';

  @override
  String hostDraftCanPourValue(int ready, int total) {
    return '$ready з $total';
  }

  @override
  String get hostGoLiveCta => 'Відкрити бар і код';

  @override
  String get hostSaveForLater => 'Зберегти чернетку на потім';

  @override
  String get hostDraftLoadFailed => 'Не вдалося завантажити вечірку.';

  @override
  String get hostGoLiveTitle => 'Відкрити бар?';

  @override
  String get hostGoLiveBody => 'Ось що зміниться, щойно ви натиснете.';

  @override
  String hostGoLiveCodeWorks(String code) {
    return 'Код $code почне діяти';
  }

  @override
  String get hostGoLiveCodeWorksSub =>
      'Приєднатися зможе будь-хто з кодом або QR';

  @override
  String get hostGoLiveOrders => 'Замовлення почнуть надходити на ваш телефон';

  @override
  String get hostGoLiveOrdersSub => 'Черга — за кнопкою «Відкрити бар»';

  @override
  String get hostGoLiveUndo => 'Нічого не остаточно';

  @override
  String get hostGoLiveUndoSub =>
      'Ставте бар на паузу чи змінюйте меню будь-коли';

  @override
  String get hostGoLive => 'Відкрити бар';

  @override
  String get hostNotYet => 'Ще ні';

  @override
  String get hostOneLiveParty => 'Одна вечірка наживо за раз';

  @override
  String hostSecondLiveTitle(String name) {
    return '«$name» ще триває';
  }

  @override
  String get hostSecondLiveBody =>
      'Один бар за раз — завершіть ту вечірку, і її підсумок збережеться до відкриття нової.';

  @override
  String hostGoToParty(String name) {
    return 'Перейти до «$name»';
  }

  @override
  String get hostEndAndStartFresh => 'Завершити її й почати нову';

  @override
  String get hostEmptyMenuTitle => 'Відкрити з порожнім меню?';

  @override
  String get hostEmptyMenuBody =>
      'Гості все одно зможуть приєднатися й попросити що завгодно — ви просто прийматимете побажання замість замовлень.';

  @override
  String get hostOpenAsRequestBar => 'Відкрити бар на побажання';

  @override
  String get hostAddACoupleFirst => 'Спершу додам кілька';

  @override
  String hostLivePill(String elapsed) {
    return 'Наживо · $elapsed';
  }

  @override
  String get hostBarOpenTitle => 'Бар відкрито';

  @override
  String get hostBarOpenBody =>
      'Наведіть камеру. Без застосунку й акаунта — лише ім’я.';

  @override
  String get hostCopyCode => 'Скопіювати код';

  @override
  String get hostCodeCopied => 'Код скопійовано';

  @override
  String get hostShareLink => 'Поділитися посиланням';

  @override
  String get hostGoToTheParty => 'До вечірки';

  @override
  String hostShareText(String name, String code) {
    return 'Приєднуйтеся до «$name» у PartyBar з кодом $code';
  }

  @override
  String hostHereAndPoured(int here, int poured) {
    return 'Тут: $here · налито: $poured';
  }

  @override
  String get hostOpenTheBar => 'До бару';

  @override
  String get hostOnTheMenuTonight => 'У меню сьогодні';

  @override
  String get hostEdit => 'Змінити';

  @override
  String get hostShowQr => 'Показати QR-код';

  @override
  String get hostShare => 'Поділитися';

  @override
  String get hostManage => 'Керувати вечіркою';

  @override
  String get hostMenuEmptyRequests =>
      'Меню порожнє — гості надсилають побажання.';

  @override
  String get hostLowBadge => 'Мало';

  @override
  String hostManageSub(String elapsed, int guests, int waiting) {
    return 'Наживо $elapsed · тут: $guests · чекають: $waiting';
  }

  @override
  String get hostLiveChip => 'Наживо';

  @override
  String get hostPauseBar => 'Поставити бар на паузу';

  @override
  String get hostPauseCaption =>
      'Нові замовлення зупиняться. Гості побачать «повернемося за хвилину».';

  @override
  String get hostEditTonightsMenu => 'Змінити меню';

  @override
  String get hostInviteMore => 'Запросити ще';

  @override
  String get hostWhosHere => 'Хто тут';

  @override
  String get hostAddCoHost => 'Додати співведучого';

  @override
  String get hostSoon => 'Скоро';

  @override
  String get hostEndParty => 'Завершити вечірку';

  @override
  String get hostEndPartyHint => 'далі — підсумок вечора';

  @override
  String get hostSaveFailed => 'Не вдалося зберегти. Спробуйте ще раз.';

  @override
  String hostPausedPill(String elapsed) {
    return 'Бар на паузі · $elapsed';
  }

  @override
  String get hostPausedTitle => 'Бар зачинено\nна хвилинку';

  @override
  String hostPausedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ніхто не може замовити. $count замовлення в черзі все ще ваші.',
      many: 'Ніхто не може замовити. $count замовлень у черзі все ще ваші.',
      few: 'Ніхто не може замовити. $count замовлення в черзі все ще ваші.',
      one: 'Ніхто не може замовити. $count замовлення в черзі все ще ваше.',
      zero: 'Ніхто не може замовити, а черга порожня.',
    );
    return '$_temp0';
  }

  @override
  String get hostReopenBar => 'Знову відкрити бар';

  @override
  String get hostGuestsSeeing => 'Гості бачать';

  @override
  String get hostBackInAMinute => 'Повернемося за хвилину';

  @override
  String get hostMenuVisibleOrderingOff => 'Меню видно · замовлення вимкнено';

  @override
  String get hostInQueue => 'У черзі';

  @override
  String hostOrdersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count замовлення',
      many: '$count замовлень',
      few: '$count замовлення',
      one: '$count замовлення',
    );
    return '$_temp0';
  }

  @override
  String get hostStillHere => 'Ще тут';

  @override
  String hostGuestsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count гостя',
      many: '$count гостей',
      few: '$count гості',
      one: '$count гість',
    );
    return '$_temp0';
  }

  @override
  String get hostEndTitle => 'Завершуємо вечір?';

  @override
  String get hostEndBody =>
      'Код перестане діяти, а черга закриється. Цього не скасувати.';

  @override
  String hostEndWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count замовлення ще чекають',
      many: '$count замовлень ще чекають',
      few: '$count замовлення ще чекають',
      one: '$count замовлення ще чекає',
    );
    return '$_temp0';
  }

  @override
  String hostEndWaitingDetail(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Їх буде позначено як неподані',
      many: 'Їх буде позначено як неподані',
      few: 'Їх буде позначено як неподані',
      one: 'Його буде позначено як неподане',
    );
    return '$_temp0';
  }

  @override
  String get hostEndPoured => 'Налито';

  @override
  String get hostEndGuests => 'Гості';

  @override
  String get hostEndOpenFor => 'Відкрито';

  @override
  String get hostEndConfirm => 'Закрити бар';

  @override
  String get hostKeepPouring => 'Наливати далі';

  @override
  String get hostJustNeedBreak => 'Потрібна перерва?';

  @override
  String get hostPauseInstead => 'Краще поставити бар на паузу';

  @override
  String get queueBarTitle => 'Бар';

  @override
  String get queueBack => 'Назад';

  @override
  String get queuePause => 'Призупинити бар';

  @override
  String queueSublineInLine(int inLine, int poured) {
    return '$inLine у черзі · $poured подано сьогодні';
  }

  @override
  String queueSublineOnCounter(int onCounter, int inLine) {
    return '$onCounter на стійці · $inLine у черзі';
  }

  @override
  String get queuePausedRowTitle => 'Гості зараз не можуть замовляти';

  @override
  String get queuePausedRowBody =>
      'Бар на паузі — відкрийте знову, коли будете готові.';

  @override
  String get queueOnTheCounterEyebrow => 'На стійці';

  @override
  String queueGuestBuzzed(String guest, String wait) {
    return '$guest · сповіщено $wait тому';
  }

  @override
  String queueGuestBuzzedForFriend(String guest, String forName, String wait) {
    return '$guest, для $forName · сповіщено $wait тому';
  }

  @override
  String get queueHandedOver => 'Віддано';

  @override
  String get queueBuzzAgain => 'Сповістити ще раз';

  @override
  String get queueBackToMixing => 'Назад до змішування';

  @override
  String queueBuzzedAgainSnack(String guest) {
    return '$guest сповіщено ще раз';
  }

  @override
  String get queuePouringEyebrow => 'Наливається зараз';

  @override
  String get queueNextUpEyebrow => 'Наступний';

  @override
  String queueGuestWaiting(String guest, String wait) {
    return '$guest · чекає $wait';
  }

  @override
  String queueGuestWaitingForFriend(String guest, String forName, String wait) {
    return '$guest, для $forName · чекає $wait';
  }

  @override
  String get queueStartPouring => 'Почати наливати';

  @override
  String get queueSkipCantMake => 'Пропустити · не вийде зробити';

  @override
  String queueIngredientsMethodChip(int count, String method) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count інгредієнта',
      many: '$count інгредієнтів',
      few: '$count інгредієнти',
      one: '$count інгредієнт',
    );
    return '$_temp0 · $method';
  }

  @override
  String get queuePourPill => 'Наливати';

  @override
  String queueInLineHeader(int count) {
    return 'У черзі · $count';
  }

  @override
  String get queueOldestFirst => 'Спочатку найстаріші';

  @override
  String get queueNewTag => 'Нове';

  @override
  String get queueRowSheetPourNow => 'Наливати зараз';

  @override
  String queueSkipConfirmTitle(String name) {
    return 'Пропустити $name?';
  }

  @override
  String get queueSkipConfirmBody =>
      'Гостю повідомлять, що напою не буде. Це незворотно.';

  @override
  String get queueSkipConfirmCancel => 'Не треба';

  @override
  String get queueStatPoured => 'Подано';

  @override
  String get queueStatAvgWait => 'Сер. очікування';

  @override
  String get queueStatTopDrink => 'Популярний напій';

  @override
  String get queueStatEmpty => '—';

  @override
  String get queueEmptyBody =>
      'Ніхто не чекає — замовлення з’являться тут одразу, як їх надішлють.';

  @override
  String get queueEmptyShowQr => 'Показати QR-код';

  @override
  String queuePouringPill(String time) {
    return 'Наливається · $time';
  }

  @override
  String queueForGuestPosition(String guest, int position) {
    return 'для $guest · #$position у черзі';
  }

  @override
  String queueForGuestFromSender(String forName, String guest) {
    return 'для $forName · від $guest';
  }

  @override
  String queueNoteLabel(String guest) {
    return '$guest просить';
  }

  @override
  String queueHowHostMakesItRow(String host, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Як $host готує · $count кроку',
      many: 'Як $host готує · $count кроків',
      few: 'Як $host готує · $count кроки',
      one: 'Як $host готує · $count крок',
    );
    return '$_temp0';
  }

  @override
  String queueReadyBuzz(String guest) {
    return 'Готово — сповістити $guest';
  }

  @override
  String get queueOutOfSomething => 'Щось закінчилось';

  @override
  String get queueCancelOrder => 'Скасувати замовлення';

  @override
  String queueCancelOrderConfirmTitle(String name) {
    return 'Скасувати $name?';
  }

  @override
  String queueCancelOrderConfirmBody(String guest) {
    return '$guest повідомлять, що замовлення скасовано. Це незворотно.';
  }

  @override
  String get queueCancelOrderConfirmKeep => 'Наливати далі';

  @override
  String queueMethodSheetTitle(String host) {
    return 'Як $host готує';
  }

  @override
  String queueMethodSubtitle(String cocktail, String method) {
    return '$cocktail · $method';
  }

  @override
  String queueMethodMinutes(int minutes) {
    return '~$minutes хв';
  }

  @override
  String queueMethodTimerSeconds(int seconds) {
    return '$seconds с';
  }

  @override
  String get queueWhatRanOutTitle => 'Що закінчилось?';

  @override
  String queueOutOfTitle(String ingredient) {
    return 'Закінчився $ingredient?';
  }

  @override
  String queueOutOfSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count напою використовують це',
      many: '$count напоїв використовують це',
      few: '$count напої використовують це',
      one: '$count напій використовує це',
    );
    return 'Пляшка порожня · $_temp0';
  }

  @override
  String queueWaitingInQueue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count чекає в черзі',
      many: '$count чекають в черзі',
      few: '$count чекають в черзі',
      one: '$count чекає в черзі',
      zero: 'ніхто не чекає',
    );
    return '$_temp0';
  }

  @override
  String queueGuestsToldTitle(String guest) {
    return '$guest отримає повідомлення з варіантами';
  }

  @override
  String get queueGuestsToldGeneric =>
      'Гості отримають повідомлення з варіантами';

  @override
  String queueGuestsToldBody(String host, String ingredient) {
    return '«$host закінчив(ла) $ingredient» — і напої, які ще можна налити, одним дотиком.';
  }

  @override
  String queuePullDrinks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Прибрати $count напою з меню',
      many: 'Прибрати $count напоїв з меню',
      few: 'Прибрати $count напої з меню',
      one: 'Прибрати $count напій з меню',
    );
    return '$_temp0';
  }

  @override
  String get queueKeepOnMenu => 'Лише це замовлення — залишити в меню';

  @override
  String queueOrderLandedTitle(String guest, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count напою',
      many: '$count напоїв',
      few: '$count напої',
      one: '$count напій',
    );
    return '$guest замовив(ла) $_temp0';
  }

  @override
  String queueForFriend(String name) {
    return 'для $name';
  }

  @override
  String get queueWaitingOnYouTitle => 'Чекають на вас';

  @override
  String queueInLineBadge(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count у черзі',
      many: '$count у черзі',
      few: '$count у черзі',
      one: '$count у черзі',
    );
    return '$_temp0';
  }

  @override
  String queueDrinkForGuest(String drink, String guest) {
    return '$drink · $guest';
  }

  @override
  String get roundNavTonight => 'Сьогодні';

  @override
  String get roundNavYourRound => 'Твоє коло';

  @override
  String roundPill(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Твоє коло · $count',
      many: 'Твоє коло · $count',
      few: 'Твоє коло · $count',
      one: 'Твоє коло · $count',
    );
    return '$_temp0';
  }

  @override
  String get roundPausedTitle => 'Бар на паузі';

  @override
  String roundPausedBody(String host) {
    return 'Зараз $host не наливає — меню можна переглядати, але надсилати замовлення поки не можна.';
  }

  @override
  String get roundEndedTitle => 'Бар зачинено';

  @override
  String roundEndedBody(String party) {
    return '$party завершилася. Дякуємо, що завітали.';
  }

  @override
  String get roundEndedLeave => 'Готово';

  @override
  String get roundBarOpenPill => 'Бар відкрито';

  @override
  String roundHostPouring(String host, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count тут сьогодні',
      many: '$count тут сьогодні',
      few: '$count тут сьогодні',
      one: '$count тут сьогодні',
    );
    return '$host наливає · $_temp0';
  }

  @override
  String get roundOnMenuTonight => 'У меню сьогодні';

  @override
  String roundSeeAll(int count) {
    return 'Усі $count';
  }

  @override
  String roundPartyOpenGuests(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Бар відкрито · $count тут',
      many: 'Бар відкрито · $count тут',
      few: 'Бар відкрито · $count тут',
      one: 'Бар відкрито · $count тут',
    );
    return '$_temp0';
  }

  @override
  String get roundYourRoundEyebrow => 'Твоє коло';

  @override
  String roundSentAt(String time) {
    return 'Надіслано $time';
  }

  @override
  String roundYoureNext(String drink) {
    return 'твоя черга — $drink';
  }

  @override
  String roundInLine(String drink) {
    return 'у черзі — $drink';
  }

  @override
  String get roundStageSent => 'Надіслано';

  @override
  String get roundStageInLine => 'У черзі';

  @override
  String get roundStageMixing => 'Готується';

  @override
  String get roundStageReady => 'Готово';

  @override
  String roundOrderPositionInLine(int n) {
    return '#$n у черзі';
  }

  @override
  String get roundMixingNow => 'Готується зараз';

  @override
  String get roundStatusMixing => 'Готується';

  @override
  String get roundStatusReady => 'Готово';

  @override
  String get roundStatusServed => 'Подано';

  @override
  String get roundStatusCancelled => 'Скасовано';

  @override
  String get roundStatusPulled => 'Прибрано';

  @override
  String get roundWhileYouWait => 'Поки чекаєш';

  @override
  String get roundFullMenu => 'Усе меню';

  @override
  String roundMixingHeadlineMine(String host, String drink) {
    return '$host наливає твій $drink';
  }

  @override
  String roundMixingHeadlineFriend(String host, String friend, String drink) {
    return '$host наливає $drink для $friend';
  }

  @override
  String get roundCancelLocked => 'Скасовувати вже пізно — це вже в келиху.';

  @override
  String get roundPocketIt =>
      'Сховай телефон у кишеню — сповістимо, коли напій буде на барі.';

  @override
  String roundReadySince(String elapsed) {
    return 'Готово · $elapsed тому';
  }

  @override
  String get roundGrabIt => 'Забирай,\nпоки холодний';

  @override
  String roundReadyLineWithNote(String drink, String note) {
    return '$drink, $note — на барній стійці з твоїм ім\'ям.';
  }

  @override
  String roundReadyLineNoNote(String drink) {
    return '$drink — на барній стійці з твоїм ім\'ям.';
  }

  @override
  String get roundOnMyWay => 'Вже йду';

  @override
  String roundServedFootnote(String host) {
    return '$host позначає напій поданим, коли його вручають.';
  }

  @override
  String get roundPulledPill => 'Прибрано з меню';

  @override
  String roundPulledTitle(String host, String ingredient) {
    return 'У $host закінчився $ingredient';
  }

  @override
  String roundPulledIntro(String drink) {
    return 'Твій $drink прибрали з меню.';
  }

  @override
  String roundOthersLabelMine(String drink) {
    return 'Твій $drink';
  }

  @override
  String roundOthersLabelFriend(String friend, String drink) {
    return '$drink для $friend';
  }

  @override
  String roundStillComingAt(String label, int position) {
    return '$label ще в дорозі — #$position у черзі.';
  }

  @override
  String get roundSwapTitle => 'Заміни на';

  @override
  String get roundSwapSubtitle => 'Це ще можна налити прямо зараз';

  @override
  String roundSwapMateLabel(String friend) {
    return 'Те, що п\'є $friend';
  }

  @override
  String get roundSwapIn => 'Замінити';

  @override
  String get roundNothingForNow => 'Поки нічого, дякую';

  @override
  String get roundSwapFailed => 'Не вдалося надіслати заміну — спробуй ще раз.';

  @override
  String get roundMenuEmptyTitle => 'Меню поки порожнє';

  @override
  String roundMenuEmptyBody(String host) {
    return 'У $host поки немає напоїв у меню.';
  }

  @override
  String get roundMenuLoading => 'Завантажуємо меню…';

  @override
  String roundIngredientsCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n інгредієнта',
      many: '$n інгредієнтів',
      few: '$n інгредієнти',
      one: '$n інгредієнт',
    );
    return '$_temp0';
  }

  @override
  String get roundWhosItFor => 'Для кого';

  @override
  String get roundMe => 'Я';

  @override
  String get roundSomeoneElse => 'Хтось інший';

  @override
  String get roundSomeoneElseTitle => 'Для кого це?';

  @override
  String get roundSomeoneElseHint => 'Ім\'я друга';

  @override
  String get roundSomeoneElseAdd => 'Додати';

  @override
  String get roundHowMany => 'Скільки';

  @override
  String get roundHowManySub => 'Кожен стає в чергу окремо';

  @override
  String get roundNoteHint => 'Побільше лайма, без соломинки…';

  @override
  String get roundAddNote => 'Додати нотатку';

  @override
  String get roundEditNote => 'Змінити';

  @override
  String get roundNoteSheetTitle => 'Додати нотатку';

  @override
  String get roundNoteSheetHint => 'напр., побільше лайма, без соломинки';

  @override
  String get roundNoteSheetSave => 'Зберегти';

  @override
  String roundAheadBold(int n) {
    return '$n попереду тебе';
  }

  @override
  String roundAheadRest(String host) {
    return ' у черзі до $host прямо зараз.';
  }

  @override
  String get roundAddToRound => 'Додати в коло';

  @override
  String get roundYourRoundTitle => 'Твоє коло';

  @override
  String roundPoursOneAtATime(String host) {
    return '$host наливає по одному';
  }

  @override
  String roundDrinksCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n напою',
      many: '$n напоїв',
      few: '$n напої',
      one: '$n напій',
    );
    return '$_temp0';
  }

  @override
  String get roundForYou => 'для тебе';

  @override
  String roundForFriend(String name) {
    return 'для $name';
  }

  @override
  String roundAheadSendingSingle(int ahead, int position) {
    return '$ahead попереду тебе. Після надсилання будеш на #$position.';
  }

  @override
  String roundAheadSendingRange(int ahead, int a, int b) {
    return '$ahead попереду тебе. Після надсилання будеш на #$a–#$b.';
  }

  @override
  String roundSendTo(String host) {
    return 'Надіслати $host';
  }

  @override
  String get roundAddOneMore => 'Додати ще один';

  @override
  String get roundSendFailed => 'Не вдалося надіслати коло — спробуй ще раз.';

  @override
  String get roundOrdersIn => 'Замовлення надіслано';

  @override
  String roundOrdersInBody(int count, String host) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count напою у черзі до $host. Сповістимо, щойно перший з них буде готовий.',
      many:
          '$count напоїв у черзі до $host. Сповістимо, щойно перший з них буде готовий.',
      few:
          '$count напої у черзі до $host. Сповістимо, щойно перший з них буде готовий.',
      one: '$count напій у черзі до $host. Сповістимо, щойно він буде готовий.',
    );
    return '$_temp0';
  }

  @override
  String get roundInLineTag => 'у черзі';

  @override
  String get roundBackToMenu => 'До меню';

  @override
  String get roundCancelRound => 'Скасувати коло';

  @override
  String roundCancelRoundFootnote(String host) {
    return 'Замовлення можна прибрати, доки $host не почне його наливати.';
  }

  @override
  String roundCancelRoundKept(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n замовлення вже наливали, тож вони залишились.',
      many: '$n замовлень вже наливали, тож вони залишились.',
      few: '$n замовлення вже наливали, тож вони залишились.',
      one: '$n замовлення вже наливали, тож воно залишилось.',
    );
    return '$_temp0';
  }

  @override
  String roundTonightSummary(int total, int coming) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$total сьогодні',
      many: '$total сьогодні',
      few: '$total сьогодні',
      one: '$total сьогодні',
    );
    String _temp1 = intl.Intl.pluralLogic(
      coming,
      locale: localeName,
      other: '$coming ще в дорозі',
      many: '$coming ще в дорозі',
      few: '$coming ще в дорозі',
      one: '$coming ще в дорозі',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String roundYoureTonight(String name) {
    return 'Сьогодні ти — $name';
  }

  @override
  String get roundBuzzNow => 'щойно';

  @override
  String roundBuzzReadyMine(String drink) {
    return 'Твій $drink готовий';
  }

  @override
  String roundBuzzReadyFriend(String friend, String drink) {
    return '$drink для $friend готовий';
  }

  @override
  String roundBuzzBody(String party) {
    return 'На барній стійці на $party.';
  }

  @override
  String roundBuzzNextUp(String drink) {
    return '$drink — наступний.';
  }

  @override
  String get roundCancelTooLate => 'Вже пізно — це вже наливають.';

  @override
  String get roundSendingPaused => 'Надсилання вимкнено, поки бар на паузі.';

  @override
  String get roundBack => 'Назад';

  @override
  String get joinTitle => 'Який код?';

  @override
  String get joinSubtitle =>
      'Шість символів — на екрані господаря або на холодильнику.';

  @override
  String get joinCodeSemantics => 'Код вечірки, шість символів';

  @override
  String get joinLinkHint =>
      'Господар надіслав посилання? Просто торкнись його — воно впускає саме.';

  @override
  String joinCodeMore(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Ще $n символу',
      many: 'Ще $n символів',
      few: 'Ще $n символи',
      one: 'Ще $n символ',
    );
    return '$_temp0';
  }

  @override
  String get joinCta => 'Приєднатися';

  @override
  String get joinRetry => 'Спробувати ще';

  @override
  String get joinClose => 'Закрити';

  @override
  String get joinFailedNotFound => 'Немає вечірки з таким кодом.';

  @override
  String get joinFailedNotFoundHint =>
      'Нуль і літера O на екрані однакові — варто глянути ще раз.';

  @override
  String joinFailedEnded(String time) {
    return 'Ця вечірка завершилась о $time.';
  }

  @override
  String get joinFailedEndedNoTime => 'Ця вечірка вже завершилась.';

  @override
  String get joinFailedEndedHint =>
      'Коди ніколи не повторюються, тож це означає лише одне — ніч скінчилась.';

  @override
  String get joinFailedOffline => 'Не вдалося дістатись бару.';

  @override
  String get joinFailedOfflineHint =>
      'Код лишився тут — торкнись, щоб спробувати ще раз.';

  @override
  String get joinAskForLink => 'Попроси господаря надіслати посилання';

  @override
  String get joinOpening => 'Відчиняємо бар…';

  @override
  String get joinYoureIn => 'Ти всередині';

  @override
  String get joinNameTitle => 'Спершу одне';

  @override
  String joinNameBody(String host) {
    return '$host має щось вигукнути, коли твій напій буде готовий.';
  }

  @override
  String get joinNameLabel => 'Твоє імʼя';

  @override
  String get joinNameHint => 'Сем';

  @override
  String get joinNameRequired => 'Потрібне лише імʼя.';

  @override
  String joinNameVisibility(String host) {
    return 'Це бачить $host і список видачі. Більше ніхто.';
  }

  @override
  String get joinAgeConfirm => 'Мені є 18, і я пʼю відповідально';

  @override
  String get joinAgeRequired => 'Постав позначку вище, щоб надіслати.';

  @override
  String get joinNameRemember =>
      'Цей телефон памʼятатиме тебе до кінця вечірки.';

  @override
  String joinSendToBar(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Надіслати в бар · $n напою',
      many: 'Надіслати в бар · $n напоїв',
      few: 'Надіслати в бар · $n напої',
      one: 'Надіслати в бар · $n напій',
    );
    return '$_temp0';
  }

  @override
  String get joinChangeName => 'Змінити';

  @override
  String get joinLeaveParty => 'Залишити вечірку';

  @override
  String joinLeaveTitle(String party) {
    return 'Залишити $party?';
  }

  @override
  String get joinLeaveBody =>
      'Надіслані напої лишаться в черзі — цей телефон просто перестане за ними стежити. Код впустить назад.';

  @override
  String get joinLeaveConfirm => 'Залишити';

  @override
  String get joinStay => 'Лишитись';

  @override
  String joinEndedTitle(String host) {
    return '$host зачинив бар';
  }

  @override
  String joinEndedBody(String party) {
    return '$party завершилась.';
  }

  @override
  String get joinEndedYourNight => 'Твоя ніч';

  @override
  String joinEndedDrinksLabel(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'напою',
      many: 'напоїв',
      few: 'напої',
      one: 'напій',
    );
    return '$_temp0';
  }

  @override
  String joinEndedFriendsLabel(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'для друзів',
      many: 'для друзів',
      few: 'для друзів',
      one: 'для друга',
    );
    return '$_temp0';
  }

  @override
  String get joinEndedHereLabel => 'тут';

  @override
  String joinEndedHours(int hours) {
    return '$hoursГ';
  }

  @override
  String get joinEndedFootnote => 'Код більше не працює.';

  @override
  String get joinEndedDone => 'Готово';

  @override
  String get joinPausedPill => 'Бар на паузі';

  @override
  String joinPausedTitle(String host) {
    return '$host поставив бар на паузу';
  }

  @override
  String get joinPausedBody =>
      'Нових замовлень поки що немає. Твоє досі в черзі — нічого не загубилось.';

  @override
  String get joinPausedLocked => 'Замовлення вимкнені';

  @override
  String joinPausedNudge(String host) {
    return 'Ми штовхнемо тебе, щойно $host відкриє його знову.';
  }

  @override
  String joinBackTo(String party) {
    return 'Назад до $party';
  }

  @override
  String get joinAskForLinkMessage =>
      'Скинь мені посилання на свою вечірку в PartyBar?';

  @override
  String get joinNameSave => 'Зберегти';

  @override
  String joinPausedStillInLine(String drink, int position) {
    return '$drink · досі #$position у черзі';
  }

  @override
  String joinPausedGuests(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Скоро повернемось · $count тут',
      many: 'Скоро повернемось · $count тут',
      few: 'Скоро повернемось · $count тут',
      one: 'Скоро повернемось · $count тут',
    );
    return '$_temp0';
  }

  @override
  String get hostCloseTitle => 'Закрити бар?';

  @override
  String hostCloseWaitingBody(int count, String names) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count напою ще чекають — $names. Закриття скасує їх і пояснить чому на тих телефонах.',
      many:
          '$count напоїв ще чекають — $names. Закриття скасує їх і пояснить чому на тих телефонах.',
      few:
          '$count напої ще чекають — $names. Закриття скасує їх і пояснить чому на тих телефонах.',
      one:
          'Один напій ще чекає — $names. Закриття скасує його й пояснить чому на тому телефоні.',
    );
    return '$_temp0';
  }

  @override
  String hostClosePourFirst(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Спершу налий ці $count',
      many: 'Спершу налий ці $count',
      few: 'Спершу налий ці $count',
      one: 'Спершу налий його',
    );
    return '$_temp0';
  }

  @override
  String hostCloseAnyway(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Закрити все одно · скасує $count',
      many: 'Закрити все одно · скасує $count',
      few: 'Закрити все одно · скасує $count',
      one: 'Закрити все одно · скасує 1',
    );
    return '$_temp0';
  }

  @override
  String get hostCloseFootnote =>
      'Код перестає діяти тієї ж секунди. Нічого не видаляється.';

  @override
  String hostNamesPair(String first, String second) {
    return '$first і $second';
  }

  @override
  String hostNamesMore(String names, int count) {
    return '$names і ще $count';
  }

  @override
  String get hostYourNights => 'Твої вечори';

  @override
  String get recapLastNight => 'Минулої ночі';

  @override
  String get recapTonight => 'Сьогодні';

  @override
  String get recapEarlier => 'Раніше';

  @override
  String recapWhen(String date, String from, String until, String guests) {
    return '$date · $from – $until · $guests';
  }

  @override
  String recapWhenOpen(String date, String from, String guests) {
    return '$date · з $from · $guests';
  }

  @override
  String recapGuests(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count гостей',
      many: '$count гостей',
      few: '$count гості',
      one: '$count гість',
      zero: 'ще нікого',
    );
    return '$_temp0';
  }

  @override
  String get recapPouredLabel => 'напоїв налито';

  @override
  String get recapWaitLabel => 'серед. очікування';

  @override
  String get recapRecipesLabel => 'рецептів у справі';

  @override
  String get recapNoWait => '—';

  @override
  String get recapWhatPeopleDrank => 'Що пили';

  @override
  String get recapNothingPoured =>
      'Цього разу з бару нічого не вийшло. Вечір усе одно був.';

  @override
  String get recapRestockTitle => 'Що закінчилось';

  @override
  String recapRestockBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count пляшок робили всю роботу',
      many: '$count пляшок робили всю роботу',
      few: '$count пляшки робили всю роботу',
      one: '$count пляшка робила всю роботу',
      zero: 'Перевір полицю перед наступним разом',
    );
    return '$_temp0';
  }

  @override
  String get recapSaveMenuTitle => 'Зберегти це меню';

  @override
  String recapSaveMenuBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count рецептів, у тому ж порядку',
      many: '$count рецептів, у тому ж порядку',
      few: '$count рецепти, у тому ж порядку',
      one: '$count рецепт, у тому ж порядку',
    );
    return '$_temp0';
  }

  @override
  String recapSaveMenuDone(String name) {
    return 'Збережено як $name';
  }

  @override
  String get recapShare => 'Поділитися підсумком';

  @override
  String get recapMissing => 'Цього вечора тут більше немає.';

  @override
  String get shareCardStory => 'Сторіс';

  @override
  String get shareCardSquare => 'Квадрат';

  @override
  String get shareCardNameGuests => 'Назвати гостей';

  @override
  String get shareCardShowWaits => 'Показати час очікування';

  @override
  String get shareCardSend => 'Надіслати в чат';

  @override
  String get shareCardFootnote =>
      'Зберігається як зображення. Жодного посилання на вечірку.';

  @override
  String shareCardHeadline(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count напоїв',
      many: '$count напоїв',
      few: '$count напої',
      one: '$count напій',
    );
    return '$_temp0';
  }

  @override
  String shareCardPeople(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count людей',
      many: '$count людей',
      few: '$count людини',
      one: '$count людина',
    );
    return '$_temp0';
  }

  @override
  String shareCardUntil(String date, String time) {
    return '$date, до $time';
  }

  @override
  String shareCardDrinkChip(String drink, int count) {
    return '$drink ×$count';
  }

  @override
  String shareCardWaitChip(String wait) {
    return '$wait очікування';
  }

  @override
  String get shareCardFailed => 'Не вдалося зробити зображення.';

  @override
  String get presetTitle => 'Лишити це меню';

  @override
  String presetBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count рецептів у тому порядку, що були. Відкриються у два дотики.',
      many:
          '$count рецептів у тому порядку, що були. Відкриються у два дотики.',
      few: '$count рецепти в тому порядку, що були. Відкриються у два дотики.',
      one: 'Один рецепт, готовий відкритись наступного разу.',
    );
    return '$_temp0';
  }

  @override
  String get presetNameHint => 'Ті самі дев\'ять';

  @override
  String presetKeepsRecipes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count рецептів, той самий порядок',
      many: '$count рецептів, той самий порядок',
      few: '$count рецепти, той самий порядок',
      one: '$count рецепт',
    );
    return '$_temp0';
  }

  @override
  String get presetDropsParty => 'Без назви, коду й списку гостей';

  @override
  String get presetSave => 'Зберегти меню';

  @override
  String get presetFootnote =>
      'Житиме поряд з іншими збереженими меню у «Провести вечірку».';

  @override
  String get presetNameRequired => 'Дай йому назву, щоб зберегти.';

  @override
  String presetSavedMenus(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count збережених меню',
      many: '$count збережених меню',
      few: '$count збережені меню',
      one: '$count збережене меню',
      zero: 'Збережені меню',
    );
    return '$_temp0';
  }

  @override
  String get presetPickTitle => 'Твої збережені меню';

  @override
  String presetMeta(int count, String date) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count рецептів · збережено $date',
      many: '$count рецептів · збережено $date',
      few: '$count рецепти · збережено $date',
      one: '$count рецепт · збережено $date',
    );
    return '$_temp0';
  }

  @override
  String get presetNone =>
      'Поки нічого не збережено. Лиши меню з вечора, який вдався — і воно з\'явиться тут.';

  @override
  String presetAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Додано $count напоїв',
      many: 'Додано $count напоїв',
      few: 'Додано $count напої',
      one: 'Додано $count напій',
      zero: 'Ці напої вже в меню',
    );
    return '$_temp0';
  }

  @override
  String get presetRemove => 'Забути це меню';

  @override
  String get nightsTitle => 'Твої вечори';

  @override
  String nightsSummary(String parties, String drinks, String since) {
    return '$parties · $drinks · від $since';
  }

  @override
  String nightsParties(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count вечірок',
      many: '$count вечірок',
      few: '$count вечірки',
      one: '$count вечірка',
    );
    return '$_temp0';
  }

  @override
  String nightsDrinks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count напоїв налито',
      many: '$count напоїв налито',
      few: '$count напої налито',
      one: '$count напій налито',
    );
    return '$_temp0';
  }

  @override
  String nightsDrinksShort(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count напоїв',
      many: '$count напоїв',
      few: '$count напої',
      one: '$count напій',
    );
    return '$_temp0';
  }

  @override
  String nightsRowMeta(String date, String drinks, String guests) {
    return '$date · $drinks · $guests';
  }

  @override
  String get nightsEmptyTitle => 'Ще жодного вечора';

  @override
  String get nightsEmptyBody =>
      'Кожна закрита вечірка записує себе сюди — цифри, меню, що закінчилось.';

  @override
  String guestRecapEyebrow(String party, String date) {
    return '$party · $date';
  }

  @override
  String guestRecapTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ти випив\n$count',
      many: 'Ти випив\n$count',
      few: 'Ти випив\n$count',
      one: 'Ти випив\nодин',
      zero: 'Ти прийшов,\nти подивився',
    );
    return '$_temp0';
  }

  @override
  String guestRecapTitleMade(int count, int drinks) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ти випив $drinks,\nа зробив $count',
      many: 'Ти випив $drinks,\nа зробив $count',
      few: 'Ти випив $drinks,\nа зробив $count',
      one: 'Ти випив $drinks,\nа зробив один',
    );
    return '$_temp0';
  }

  @override
  String guestRecapForFriends(int count, String names) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count з них були для $names.',
      many: '$count з них були для $names.',
      few: '$count з них були для $names.',
      one: 'Один з них був для $names.',
    );
    return '$_temp0';
  }

  @override
  String guestRecapLastDrink(String drink, String host) {
    return '$drink був останнім, що вийшов з бару, перш ніж $host його закрив.';
  }

  @override
  String guestRecapNothing(String host) {
    return 'Цього разу ти нічого не замовив — бар був $host, а вечір твій.';
  }

  @override
  String get guestRecapRecipe => 'Рецепт';

  @override
  String get guestRecapStartBar => 'Почни власний бар';

  @override
  String get guestRecapFootnote =>
      'Ця сторінка лишиться на твоєму телефоні тиждень. Акаунт не потрібен.';

  @override
  String get guestRecapSee => 'Подивитись вечір';

  @override
  String get guestRecapGone => 'Той вечір уже відпустив.';

  @override
  String guestRecapYourNight(String party) {
    return 'Твій вечір на $party';
  }
}
