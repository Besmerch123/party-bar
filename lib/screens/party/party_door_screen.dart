import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../services/guest_session.dart';
import '../../services/party_service.dart';
import '../../theme/theme.dart';
import '../../utils/localization_helper.dart';
import 'guest_party_screen.dart';
import 'join_party_screen.dart';

/// Flow 07 · screen 02 — the fast door, and the one the phone walks through
/// on its own.
///
/// A tapped link, a scanned QR and a reopened app all land here with nothing
/// but an identifier. The screen resolves it and then *becomes* the party:
/// no interstitial, no welcome page, no navigation the back button has to
/// unpick. The drinks are the welcome.
///
/// A link that cannot be opened falls back to the slow door with the code
/// already typed and the reason already on screen — the guest is never left
/// holding a dead link with nothing to do about it.
class PartyDoorScreen extends StatefulWidget {
  const PartyDoorScreen({super.key, this.code, this.partyId})
    : assert(
        code != null || partyId != null,
        'a door needs either a code to open or a party to return to',
      );

  /// From a link or a QR: six characters that have to be looked up.
  final String? code;

  /// From [GuestSession]: the party this phone was already at. No lookup by
  /// code, because the code may well have been the host's to begin with.
  final String? partyId;

  @override
  State<PartyDoorScreen> createState() => _PartyDoorScreenState();
}

class _PartyDoorScreenState extends State<PartyDoorScreen> {
  Party? _party;
  JoinFailure? _failure;

  /// True when a code opened this, which is the arrival that deserves a word
  /// of confirmation. Coming back to a party the phone remembers does not.
  bool get _viaLink => widget.code != null;

  @override
  void initState() {
    super.initState();
    _open();
  }

  Future<void> _open() async {
    final code = widget.code;

    Party? party;
    try {
      party = code != null
          ? await PartyService().joinPartyByCode(code)
          : await PartyService().getPartyById(widget.partyId!);
    } catch (_) {
      if (mounted) setState(() => _failure = JoinFailure.offline);
      return;
    }

    if (!mounted) return;

    // A party this phone remembers that is gone or over is not a failure to
    // show anyone — it is just no longer worth remembering.
    if (!_viaLink && (party == null || party.isEnded)) {
      await GuestSession.forget();
      if (mounted) setState(() => _failure = JoinFailure.notFound);
      return;
    }

    if (party == null || party.isDraft) {
      setState(() => _failure = JoinFailure.notFound);
      return;
    }
    if (party.isEnded) {
      setState(() => _failure = JoinFailure.ended);
      return;
    }

    setState(() => _party = party);
  }

  @override
  Widget build(BuildContext context) {
    if (_party case final party?) {
      return GuestPartyScreen(party: party, welcome: _viaLink);
    }

    if (_failure case final failure?) {
      return JoinPartyScreen(
        initialCode: widget.code,
        initialFailure: _viaLink ? failure : null,
      );
    }

    return const _Opening();
  }
}

class _Opening extends StatelessWidget {
  const _Opening();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.signalLight,
              ),
            ),
            const SizedBox(height: 18),
            Text(context.l10n.joinOpening, style: AppTypography.meta),
          ],
        ),
      ),
    );
  }
}
