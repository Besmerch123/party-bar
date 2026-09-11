/// Search over the bar catalogue — screen 02's only way in.
///
/// The list is a few hundred entries at most, so this trades any real
/// indexing for something that reads clearly and folds diacritics: "creme"
/// has to find "crème", and "gin" has to find "London dry gin" before it
/// finds "Ginger beer".
library;

import 'bar_item.dart';

/// One catalogue entry that matched a query, and where in its resolved name
/// the match sits — enough for the search screen to bold the hit.
class BarSearchMatch {
  const BarSearchMatch({
    required this.entry,
    required this.start,
    required this.end,
  });

  final BarCatalogueEntry entry;

  /// The match range in the string [nameOf] returned, `[start, end)`.
  final int start;
  final int end;
}

/// Case- and diacritic-light "contains" search over [entries].
///
/// A prefix match ("Gin Fizz" for "gin") always outranks a match in the
/// middle of a name ("Ginger beer" for... no, "Virgin mojito" for "gin");
/// within the same rank, the shorter name wins, because it is more likely to
/// be what a two-letter query meant. An empty query finds nothing — there is
/// no "browse everything" mode here, search is the only way in.
List<BarSearchMatch> searchBarCatalogue(
  Iterable<BarCatalogueEntry> entries,
  String query, {
  required String Function(BarCatalogueEntry entry) nameOf,
}) {
  final needle = _fold(query.trim());
  if (needle.isEmpty) return const [];

  final scored = <_ScoredMatch>[];
  var index = 0;
  for (final entry in entries) {
    final name = nameOf(entry);
    final at = _fold(name).indexOf(needle);
    if (at >= 0) {
      scored.add(
        _ScoredMatch(
          match: BarSearchMatch(entry: entry, start: at, end: at + needle.length),
          isPrefix: at == 0,
          nameLength: name.length,
          order: index,
        ),
      );
    }
    index++;
  }

  scored.sort((a, b) {
    if (a.isPrefix != b.isPrefix) return a.isPrefix ? -1 : 1;
    final byLength = a.nameLength.compareTo(b.nameLength);
    if (byLength != 0) return byLength;
    return a.order.compareTo(b.order);
  });

  return scored.map((s) => s.match).toList(growable: false);
}

class _ScoredMatch {
  const _ScoredMatch({
    required this.match,
    required this.isPrefix,
    required this.nameLength,
    required this.order,
  });

  final BarSearchMatch match;
  final bool isPrefix;
  final int nameLength;

  /// Original position, so entries tied on every other measure keep the
  /// order they arrived in rather than whatever the sort felt like.
  final int order;
}

/// Common Latin diacritics, folded to their plain letter.
const Map<String, String> _diacritics = {
  'à': 'a', 'á': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a', 'å': 'a', 'ā': 'a',
  'è': 'e', 'é': 'e', 'ê': 'e', 'ë': 'e', 'ē': 'e',
  'ì': 'i', 'í': 'i', 'î': 'i', 'ï': 'i',
  'ò': 'o', 'ó': 'o', 'ô': 'o', 'õ': 'o', 'ö': 'o', 'ø': 'o',
  'ù': 'u', 'ú': 'u', 'û': 'u', 'ü': 'u',
  'ñ': 'n', 'ç': 'c', 'ý': 'y', 'ÿ': 'y',
};

String _fold(String input) => input
    .toLowerCase()
    .split('')
    .map((char) => _diacritics[char] ?? char)
    .join();
