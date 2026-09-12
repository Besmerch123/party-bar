/// Recipe vocabulary — the parts of a drink Explore reads but the original
/// [Cocktail] model never carried.
///
/// Flow 02 promises three things a title and a photo cannot answer: how long
/// this takes, whether it needs a shaker, and how much of each bottle goes in.
/// Everything here is optional on the document: the catalogue is populated
/// gradually, and a drink that knows none of it still renders — just without
/// the line under its name.
library;

/// How the drink is put together.
///
/// The "no shaker needed" filter reads this rather than inferring from the
/// equipment list: a recipe can list a shaker for chilling and still be built
/// in the glass.
enum CocktailMethod { built, stirred, shaken, blended, layered }

/// The bottle a drink is built around.
///
/// Denormalized from the ingredient list so browse-by-spirit and the spirit
/// filter are one comparison rather than a scan.
enum BaseSpirit { gin, vodka, rum, whisky, tequila, brandy, zeroProof, other }

/// Editorial taste note. Sits beside the method in the detail eyebrow —
/// "CITRUS · SHAKEN".
enum FlavorProfile { citrus, bitter, sweet, herbal, spicy, fruity, dry, creamy }

/// Units a measure can be written in. [topUp] and [splash] carry no meaningful
/// amount and render as the label alone.
enum MeasureUnit { ml, cl, oz, dash, barspoon, piece, splash, topUp }

extension MeasureUnitAmount on MeasureUnit {
  /// Whether the amount is worth printing. "Top up with tonic" beats
  /// "1 top up with tonic".
  bool get showsAmount => this != MeasureUnit.topUp && this != MeasureUnit.splash;
}

/// How much of one ingredient the recipe wants.
///
/// Kept beside the ingredient list rather than inside it — the list stays a
/// plain set of references, and this carries the quantity the recipe card
/// prints. [optional] marks garnishes and top-ups, which never count against
/// "makeable with my bar": nobody is blocked from a Negroni by a missing
/// orange twist.
class IngredientMeasure {
  const IngredientMeasure({
    required this.amount,
    required this.unit,
    this.optional = false,
  });

  final double amount;
  final MeasureUnit unit;
  final bool optional;

  factory IngredientMeasure.fromMap(Map<String, dynamic> map) {
    return IngredientMeasure(
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
      unit: MeasureUnit.values.firstWhere(
        (unit) => unit.name == map['unit'],
        orElse: () => MeasureUnit.ml,
      ),
      optional: map['optional'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
    'amount': amount,
    'unit': unit.name,
    'optional': optional,
  };

  /// Drops the trailing zero — 45 ml, not 45.0 ml — while keeping halves.
  String get formattedAmount =>
      amount == amount.roundToDouble() ? amount.toInt().toString() : amount.toString();

  /// Flow 09 · screen 05 — the settings row that changes the product.
  ///
  /// Only a volume converts. Dashes, barspoons, pieces, splashes and top-ups
  /// carry no meaningful amount ([MeasureUnit.showsAmount]) and pass through
  /// untouched — they are not being measured in the first place. The result
  /// is rounded to the nearest quarter ounce, the way a jigger actually
  /// pours; the stored recipe itself never changes.
  IngredientMeasure displayAs(MeasureUnit target) {
    if (target != MeasureUnit.oz || unit == MeasureUnit.oz) return this;
    if (unit != MeasureUnit.ml && unit != MeasureUnit.cl) return this;

    final ml = unit == MeasureUnit.cl ? amount * 10 : amount;
    final quarterOz = ((ml / 29.5735) * 4).round() / 4;
    return IngredientMeasure(amount: quarterOz, unit: MeasureUnit.oz, optional: optional);
  }
}

/// One screen of the hands-busy guided pour.
///
/// The plain `preparationSteps` stay the readable recipe; this is the same
/// recipe cut into the units a person actually performs, with the countdown
/// the step needs. A cocktail without these falls back to the plain steps, so
/// "Make it now" works on the whole catalogue from day one — it just cannot
/// offer a timer.
class PourStep {
  const PourStep({required this.title, this.body, this.durationSeconds});

  /// The instruction itself — "Shake hard for 12 seconds".
  final Map<String, String> title;

  /// The detail under it. Most steps do not need one.
  final Map<String, String>? body;

  /// Runs a countdown on the step when set.
  final int? durationSeconds;

  bool get hasTimer => (durationSeconds ?? 0) > 0;

  factory PourStep.fromMap(Map<String, dynamic> map) {
    return PourStep(
      title: Map<String, String>.from(map['title'] as Map? ?? const {}),
      body: map['body'] == null
          ? null
          : Map<String, String>.from(map['body'] as Map),
      durationSeconds: (map['durationSeconds'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toMap() => {
    'title': title,
    if (body != null) 'body': body,
    if (durationSeconds != null) 'durationSeconds': durationSeconds,
  };
}

/// Parses an enum value by name, tolerating anything the catalogue has not
/// been backfilled with yet.
T? enumByName<T extends Enum>(List<T> values, Object? raw) {
  if (raw is! String) return null;
  for (final value in values) {
    if (value.name == raw) return value;
  }
  return null;
}
