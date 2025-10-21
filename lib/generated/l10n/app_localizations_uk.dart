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
  String get navigationExplore => 'Досліджувати';

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
}
