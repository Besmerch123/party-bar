import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/order_repository.dart';
import '../../models/models.dart';
import '../../services/party_service.dart';
import '../../utils/app_router.dart';
import '../../utils/localization_helper.dart';
import '../../widgets/party/end_party_sheet.dart';
import '../../widgets/party/manage_party_sheet.dart';
import 'menu_all_cocktails_screen.dart';

/// The host's party-level verbs, shared by Flow 05's live hub and Flow 06's
/// queue — pause, reopen, edit the menu, show the QR, end.

/// The hosted-parties and party streams carry the change back to the screen.
Future<void> setPartyStatus(
  BuildContext context,
  Party party,
  PartyStatus status,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final failed = context.l10n.hostSaveFailed;
  try {
    await PartyService().updatePartyStatus(party.id, status);
  } catch (_) {
    messenger.showSnackBar(SnackBar(content: Text(failed)));
  }
}

void openPartyInvite(BuildContext context, Party party) =>
    context.push('${AppRoutes.partyInvite}/${party.id}', extra: party);

/// Opens the one menu editor and saves what comes back. [onPicked] runs
/// before the write, so the screen can show the new menu at once.
Future<List<Cocktail>?> editPartyMenu(
  BuildContext context,
  Party party,
  List<Cocktail> current, {
  ValueChanged<List<Cocktail>>? onPicked,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  final failed = context.l10n.hostDraftSaveFailed;

  final picked = await pickPartyMenu(context, current);
  if (picked == null) return null;

  onPicked?.call(picked);
  try {
    await PartyService().updateAvailableCocktails(
      party.id,
      picked.map((c) => c.id).toList(growable: false),
    );
  } catch (_) {
    messenger.showSnackBar(SnackBar(content: Text(failed)));
  }
  return picked;
}

/// Flow 05 · screen 13, rebuilt as Flow 08 · screen 01. Whatever is still
/// open is marked unserved, then the party closes with the night's two
/// numbers stamped on it.
///
/// Nothing is pushed afterwards. Nobody reads a recap at 01:24, and the
/// restock is not a step the host has to walk through on the way out — both
/// hang off [PartyRecapScreen], which the hub's ended card opens whenever
/// the host is ready for it.
///
/// [popRoute] is for callers that are themselves a pushed route (the queue):
/// they pop rather than sit on a party that no longer exists. The live hub
/// is a tab and gets swapped out by the hosted-parties stream instead.
Future<void> endParty(
  BuildContext context,
  Party party,
  List<CocktailOrder> orders, {
  bool popRoute = false,
}) async {
  final choice = await showEndPartySheet(context, party: party, orders: orders);
  if (!context.mounted) return;

  switch (choice) {
    case EndPartyChoice.end:
      final messenger = ScaffoldMessenger.of(context);
      final failed = context.l10n.hostSaveFailed;
      final router = GoRouter.of(context);
      try {
        await OrderRepository().cancelForPartyEnd(orders);
        // Counted after the cancellations, so a drink that was still in the
        // queue never lands in the night's total.
        await PartyService().closeParty(
          party.id,
          drinksPoured: orders.where((o) => o.isDelivered).length,
          guestCount: guestCountOf(orders),
        );
        if (popRoute && router.canPop()) router.pop();
      } catch (_) {
        messenger.showSnackBar(SnackBar(content: Text(failed)));
      }
    case EndPartyChoice.pauseInstead:
      await setPartyStatus(context, party, PartyStatus.paused);
    case EndPartyChoice.keepPouring:
    case null:
      break;
  }
}

/// Flow 05 · screen 11. Every choice in it is reversible, so none asks again.
Future<void> manageParty(
  BuildContext context, {
  required Party party,
  required List<CocktailOrder> orders,
  required Future<void> Function() onEditMenu,
  bool popRouteOnEnd = false,
}) async {
  final action = await showManagePartySheet(
    context,
    party: party,
    guests: orders.map((o) => o.guestName).toSet().length,
    waiting: orders.where((o) => o.isOpen).length,
    paused: party.status == PartyStatus.paused,
  );
  if (!context.mounted) return;

  switch (action) {
    case ManagePartyAction.pause:
      await setPartyStatus(context, party, PartyStatus.paused);
    case ManagePartyAction.reopen:
      await setPartyStatus(context, party, PartyStatus.active);
    case ManagePartyAction.editMenu:
      await onEditMenu();
    case ManagePartyAction.invite:
      openPartyInvite(context, party);
    case ManagePartyAction.end:
      await endParty(context, party, orders, popRoute: popRouteOnEnd);
    case null:
      break;
  }
}
