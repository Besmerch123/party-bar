/// Flow 07 — the three doors into a party, and the ways they fail.
///
/// A link asks for nothing, a QR asks for a camera the system already has,
/// and the code is the slow door of last resort. All three end on the same
/// menu, so all three normalise to the same six characters.
library;

/// Join codes are six characters out of `A–Z0–9` ([PartyService] mints them).
const kJoinCodeLength = 6;

const kJoinLinkHost = 'partybar.app';

/// The custom scheme the app claims outright; the https link above needs a
/// verified domain before Android will open it without asking.
const kJoinLinkScheme = 'partybar';

/// The path both forms share, and the route the app answers on.
const kJoinLinkPath = 'j';

/// `https://partybar.app/j/K7QM4P` — what the QR carries and what the share
/// sheet sends. One tap in a group chat is the whole of the fast door.
String partyJoinLink(String joinCode) =>
    'https://$kJoinLinkHost/$kJoinLinkPath/$joinCode';

/// Why a code did not open a door.
///
/// Each gets its own sentence on screen 04: someone who mistyped, someone who
/// arrived after closing time and someone on bad wifi are three different
/// people, and telling them apart is most of what that screen does.
enum JoinFailure {
  /// No party carries that code — a typo, or a code that was never real.
  notFound,

  /// The code was real and the night is over. Codes are never reused, so
  /// this can only mean one thing.
  ended,

  /// We could not reach the bar. Never the guest's fault, and never a dead
  /// end — the code stays in the field and the button retries.
  offline,
}

/// Everything a guest might type or paste, reduced to a code: the six
/// characters themselves, a join link, or a link with a query on the end.
///
/// Returns null when there is no whole code in there yet — a half-typed
/// field is not a failure, just unfinished.
String? joinCodeFrom(String input) {
  final trimmed = input.trim();
  if (trimmed.isEmpty) return null;

  // A link: take the segment after /j/, so a code that happens to contain
  // letters from the domain is never assembled out of the host name.
  final uri = Uri.tryParse(trimmed);
  if (uri != null && uri.pathSegments.length >= 2) {
    final segments = uri.pathSegments;
    final marker = segments.lastIndexOf(kJoinLinkPath);
    if (marker >= 0 && marker < segments.length - 1) {
      return _normalise(segments[marker + 1]);
    }
  }

  return _normalise(trimmed);
}

String? _normalise(String raw) {
  final code = raw.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
  return code.length == kJoinCodeLength ? code : null;
}
