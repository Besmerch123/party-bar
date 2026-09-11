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
}
