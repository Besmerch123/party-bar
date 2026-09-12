import 'package:flutter_test/flutter_test.dart';
import 'package:party_bar/models/join.dart';

void main() {
  group('joinCodeFrom', () {
    test('takes a bare code as typed', () {
      expect(joinCodeFrom('K7QM4P'), 'K7QM4P');
    });

    test('uppercases and strips punctuation and spacing', () {
      expect(joinCodeFrom('  k7 qm-4p '), 'K7QM4P');
    });

    test('is null while the code is unfinished', () {
      expect(joinCodeFrom('K7QM'), isNull);
      expect(joinCodeFrom(''), isNull);
    });

    test('is null when there are too many characters to be one code', () {
      expect(joinCodeFrom('K7QM4PX'), isNull);
    });

    test('unwraps the link the QR and the share sheet carry', () {
      expect(joinCodeFrom(partyJoinLink('K7QM4P')), 'K7QM4P');
      expect(joinCodeFrom('https://partybar.app/j/K7QM4P'), 'K7QM4P');
      expect(joinCodeFrom('partybar.app/j/k7qm4p'), 'K7QM4P');
    });

    test('unwraps the custom scheme the intent filters claim', () {
      expect(joinCodeFrom('partybar://app/j/K7QM4P'), 'K7QM4P');
    });

    test('ignores a query a messenger appended to the link', () {
      expect(joinCodeFrom('https://partybar.app/j/K7QM4P?utm=chat'), 'K7QM4P');
    });

    // The host name is full of letters; assembling a code out of it would
    // send a guest to a party that has nothing to do with the link.
    test('refuses a link with no code in it', () {
      expect(joinCodeFrom('https://partybar.app/j/'), isNull);
      expect(joinCodeFrom('https://partybar.app/'), isNull);
    });
  });
}
