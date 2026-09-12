import 'package:flutter/material.dart';

import '../../../generated/l10n/app_localizations.dart';
import '../../../models/models.dart';
import '../../../providers/party_cocktails.dart';
import '../../../theme/theme.dart';
import '../../../utils/cocktail_labels.dart';
import '../../../utils/localization_helper.dart';
import '../../auth/auth_controls.dart';
import '../order_bits.dart';

/// Flow 06 · screens 09 and 11 — "The bar": the host's queue, drawn from
/// plain data so it can be pumped in a test without Firebase.
///
/// Section order is fixed: on the counter, pouring, next up, the rest of the
/// line, an empty state when nothing is open, then tonight's stats. Every
/// section but the header renders only when it has something to show.
class QueueBody extends StatelessWidget {
  const QueueBody({
    super.key,
    required this.party,
    required this.orders,
    required this.cocktails,
    required this.onBack,
    required this.onTogglePause,
    required this.onManage,
    required this.onInvite,
    required this.onStartPouring,
    required this.onSkip,
    required this.onTapPouring,
    required this.onTapInLineRow,
    required this.onMarkServed,
    required this.onBuzzAgain,
    required this.onBackToMixing,
  });

  final Party party;
  final List<CocktailOrder> orders;
  final PartyCocktails cocktails;

  final VoidCallback onBack;
  final VoidCallback onTogglePause;
  final VoidCallback onManage;
  final VoidCallback onInvite;

  final ValueChanged<CocktailOrder> onStartPouring;
  final ValueChanged<CocktailOrder> onSkip;
  final ValueChanged<CocktailOrder> onTapPouring;
  final ValueChanged<CocktailOrder> onTapInLineRow;
  final ValueChanged<CocktailOrder> onMarkServed;
  final ValueChanged<CocktailOrder> onBuzzAgain;
  final ValueChanged<CocktailOrder> onBackToMixing;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final counter = onTheCounter(orders);
    final poursNow = pouring(orders);
    final line = inLine(orders);
    final nextUp = line.isEmpty ? null : line.first;
    final restInLine = line.length > 1 ? line.sublist(1) : const <CocktailOrder>[];
    final stats = barNightStatsOf(orders);
    final paused = party.status == PartyStatus.paused;
    final nothingOpen = counter.isEmpty && poursNow.isEmpty && line.isEmpty;
    final compactNextUp = counter.isNotEmpty || poursNow.isNotEmpty;

    final subline = counter.isNotEmpty
        ? l10n.queueSublineOnCounter(counter.length, line.length)
        : l10n.queueSublineInLine(line.length, stats.poured);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TopBar(
              paused: paused,
              onBack: onBack,
              onTogglePause: onTogglePause,
              onManage: onManage,
            ),
            const SizedBox(height: 14),
            Padding(
              padding: AppSpacing.screen,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.queueBarTitle,
                    style: AppTypography.heading.copyWith(fontSize: 24, height: 1),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    subline,
                    style: AppTypography.meta.copyWith(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink.withValues(alpha: .5),
                    ),
                  ),
                ],
              ),
            ),
            if (paused) ...[
              const SizedBox(height: 16),
              Padding(
                padding: AppSpacing.screen,
                child: _PausedRow(onReopen: onTogglePause),
              ),
            ],
            if (counter.isNotEmpty)
              _Section(
                label: l10n.queueOnTheCounterEyebrow,
                color: AppColors.ready,
                topGap: 22,
                child: Column(
                  children: [
                    for (final (i, order) in counter.indexed) ...[
                      if (i > 0) const SizedBox(height: 12),
                      _OnTheCounterCard(
                        order: order,
                        cocktail: cocktails.byId(order.cocktailId),
                        onMarkServed: () => onMarkServed(order),
                        onBuzzAgain: () => onBuzzAgain(order),
                        onBackToMixing: () => onBackToMixing(order),
                      ),
                    ],
                  ],
                ),
              ),
            if (poursNow.isNotEmpty)
              _Section(
                label: l10n.queuePouringEyebrow,
                color: AppColors.signalLight,
                topGap: 22,
                child: Column(
                  children: [
                    for (final (i, order) in poursNow.indexed) ...[
                      if (i > 0) const SizedBox(height: 10),
                      _PouringCompactCard(
                        order: order,
                        cocktail: cocktails.byId(order.cocktailId),
                        onTap: () => onTapPouring(order),
                      ),
                    ],
                  ],
                ),
              ),
            if (nextUp != null)
              _Section(
                label: l10n.queueNextUpEyebrow,
                color: AppColors.inkMeta,
                topGap: 22,
                child: compactNextUp
                    ? _NextUpCompactRow(
                        order: nextUp,
                        cocktail: cocktails.byId(nextUp.cocktailId),
                        onPour: () => onStartPouring(nextUp),
                      )
                    : _NextUpBigCard(
                        order: nextUp,
                        cocktail: cocktails.byId(nextUp.cocktailId),
                        onStartPouring: () => onStartPouring(nextUp),
                        onSkip: () => onSkip(nextUp),
                      ),
              ),
            if (restInLine.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenEdge,
                  22,
                  AppSpacing.screenEdge,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            l10n.queueInLineHeader(restInLine.length).toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.label.copyWith(
                              color: AppColors.inkMeta,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            l10n.queueOldestFirst,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.meta.copyWith(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.signalLight,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    for (final (i, order) in restInLine.indexed) ...[
                      if (i > 0) const SizedBox(height: 10),
                      _InLineRow(
                        order: order,
                        cocktail: cocktails.byId(order.cocktailId),
                        position: positionOf(order, orders),
                        onTap: () => onTapInLineRow(order),
                      ),
                    ],
                  ],
                ),
              ),
            if (nothingOpen)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenEdge,
                  40,
                  AppSpacing.screenEdge,
                  0,
                ),
                child: _EmptyQueue(onInvite: onInvite),
              ),
            if (stats.poured > 0)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenEdge,
                  22,
                  AppSpacing.screenEdge,
                  0,
                ),
                child: _StatsCard(
                  stats: stats,
                  topDrinkTitle: stats.topCocktailId == null
                      ? null
                      : cocktails.byId(stats.topCocktailId!)?.title.translate(context),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.paused,
    required this.onBack,
    required this.onTogglePause,
    required this.onManage,
  });

  final bool paused;
  final VoidCallback onBack;
  final VoidCallback onTogglePause;
  final VoidCallback onManage;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.screenEdge, 8, AppSpacing.screenEdge, 0),
      child: Row(
        children: [
          AuthIconAction(icon: Icons.arrow_back, onTap: onBack, semanticLabel: l10n.queueBack),
          const Spacer(),
          AuthIconAction(
            icon: paused ? Icons.play_arrow : Icons.pause,
            onTap: onTogglePause,
            semanticLabel: paused ? l10n.hostReopenBar : l10n.queuePause,
          ),
          const SizedBox(width: 8),
          AuthIconAction(icon: Icons.tune, onTap: onManage, semanticLabel: l10n.hostManage),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.label,
    required this.color,
    required this.child,
    this.topGap = 20,
  });

  final String label;
  final Color color;
  final Widget child;
  final double topGap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(AppSpacing.screenEdge, topGap, AppSpacing.screenEdge, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: AppTypography.label.copyWith(color: color)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

/// Screen 11 — the amber row while the bar is paused: guests cannot order,
/// and reopening is one tap away.
class _PausedRow extends StatelessWidget {
  const _PausedRow({required this.onReopen});

  final VoidCallback onReopen;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Material(
      color: AppColors.lowWash,
      borderRadius: AppRadius.tileAll,
      child: InkWell(
        onTap: onReopen,
        borderRadius: AppRadius.tileAll,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.low.withValues(alpha: .25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.pause, size: 17, color: AppColors.low),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.queuePausedRowTitle,
                      style: AppTypography.cardTitle.copyWith(color: AppColors.ink),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.queuePausedRowBody,
                      style: AppTypography.caption.copyWith(height: 1.3),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                l10n.hostReopenBar,
                style: AppTypography.buttonSecondary.copyWith(
                  fontSize: 12,
                  color: AppColors.low,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The line under a name: "Sam · waiting 4m" / "Sam, for Marta · waiting 4m",
/// and the "buzzed" equivalent for the counter.
String _guestLine(
  AppLocalizations l10n,
  CocktailOrder order, {
  required String wait,
  required bool buzzed,
}) {
  if (order.isForFriend) {
    return buzzed
        ? l10n.queueGuestBuzzedForFriend(order.guestName, order.forName!, wait)
        : l10n.queueGuestWaitingForFriend(order.guestName, order.forName!, wait);
  }
  return buzzed
      ? l10n.queueGuestBuzzed(order.guestName, wait)
      : l10n.queueGuestWaiting(order.guestName, wait);
}

class _OnTheCounterCard extends StatelessWidget {
  const _OnTheCounterCard({
    required this.order,
    required this.cocktail,
    required this.onMarkServed,
    required this.onBuzzAgain,
    required this.onBackToMixing,
  });

  final CocktailOrder order;
  final Cocktail? cocktail;
  final VoidCallback onMarkServed;
  final VoidCallback onBuzzAgain;
  final VoidCallback onBackToMixing;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final wait = formatWait(DateTime.now().difference(order.readyAt ?? order.createdAt));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment(-0.6, -1),
          end: Alignment(0.5, 1),
          colors: [Color(0x3835D07F), AppColors.sheet],
          stops: [0, .6],
        ),
        borderRadius: AppRadius.cardAll,
        border: Border.all(color: const Color(0x7435D07F), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              OrderThumb(image: cocktail?.image, size: 62, radius: 16),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cocktail?.title.translate(context) ?? '—',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.heading.copyWith(fontSize: 19, height: 1.05),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        GuestInitial(name: order.guestName, size: 20, highlighted: true),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _guestLine(l10n, order, wait: wait, buzzed: true),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.meta.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.ink.withValues(alpha: .65),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 60,
            child: Material(
              color: AppColors.ink,
              borderRadius: AppRadius.pillAll,
              child: InkWell(
                onTap: onMarkServed,
                borderRadius: AppRadius.pillAll,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.done_all, size: 23, color: AppColors.ground),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        l10n.queueHandedOver,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.buttonPrimary.copyWith(
                          fontSize: 16.5,
                          color: AppColors.ground,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _GhostRow(
                  icon: Icons.notifications,
                  label: l10n.queueBuzzAgain,
                  onTap: onBuzzAgain,
                  emphasised: true,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _GhostRow(
                  icon: Icons.undo,
                  label: l10n.queueBackToMixing,
                  onTap: onBackToMixing,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GhostRow extends StatelessWidget {
  const _GhostRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.emphasised = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool emphasised;

  @override
  Widget build(BuildContext context) {
    final ink = emphasised ? AppColors.ink : AppColors.ink.withValues(alpha: .5);
    return Material(
      color: emphasised ? AppColors.fillStrong : AppColors.fillMuted,
      borderRadius: AppRadius.pillAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.pillAll,
        child: SizedBox(
          height: 44,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 17, color: ink),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.buttonSecondary.copyWith(fontSize: 12, color: ink),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PouringCompactCard extends StatelessWidget {
  const _PouringCompactCard({required this.order, required this.cocktail, required this.onTap});

  final CocktailOrder order;
  final Cocktail? cocktail;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final elapsed = DateTime.now().difference(order.preparedAt ?? order.createdAt);

    return Material(
      color: AppColors.signalWash,
      borderRadius: AppRadius.tileAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.tileAll,
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Row(
            children: [
              OrderThumb(image: cocktail?.image, size: 48),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cocktail?.title.translate(context) ?? '—',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.cardTitle.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _guestLine(l10n, order, wait: formatStopwatch(elapsed), buzzed: false),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption.copyWith(color: kSignalPale),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, size: 18, color: AppColors.signalLight),
            ],
          ),
        ),
      ),
    );
  }
}

class _NextUpBigCard extends StatelessWidget {
  const _NextUpBigCard({
    required this.order,
    required this.cocktail,
    required this.onStartPouring,
    required this.onSkip,
  });

  final CocktailOrder order;
  final Cocktail? cocktail;
  final VoidCallback onStartPouring;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final wait = formatWait(DateTime.now().difference(order.createdAt));
    final glassware = cocktail?.equipments
        .where((e) => e.kind == EquipmentKind.glassware)
        .map((e) => e.title.translate(context))
        .firstOrNull;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.sheet, borderRadius: AppRadius.cardAll),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OrderThumb(image: cocktail?.image, size: 74, radius: 16),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GuestInitial(name: order.guestName, size: 22),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _guestLine(l10n, order, wait: wait, buzzed: false),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.meta.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.inkBody,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 9),
                    Text(
                      cocktail?.title.translate(context) ?? '—',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.heading.copyWith(fontSize: 21, height: 1.05),
                    ),
                    const SizedBox(height: 10),
                    if (cocktail != null)
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          if (glassware != null && glassware.isNotEmpty) _MetaTag(glassware),
                          // With no method on file the chip is the count alone — never a
                          // dangling separator.
                          _MetaTag(
                            cocktail!.method == null
                                ? l10n.hostAllIngredientCount(cocktail!.ingredients.length)
                                : l10n.queueIngredientsMethodChip(
                                    cocktail!.ingredients.length,
                                    methodLabel(l10n, cocktail!.method!),
                                  ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (order.note case final note?) ...[
            const SizedBox(height: 12),
            OrderNoteChip(note: note),
          ],
          const SizedBox(height: 14),
          SizedBox(
            height: 54,
            child: Material(
              color: AppColors.ink,
              borderRadius: AppRadius.pillAll,
              child: InkWell(
                onTap: onStartPouring,
                borderRadius: AppRadius.pillAll,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.play_arrow, size: 20, color: AppColors.ground),
                    const SizedBox(width: 9),
                    Flexible(
                      child: Text(
                        l10n.queueStartPouring,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.buttonPrimary.copyWith(
                          fontSize: 14.5,
                          color: AppColors.ground,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: TextButton(
              onPressed: onSkip,
              child: Text(
                l10n.queueSkipCantMake,
                style: AppTypography.buttonSecondary.copyWith(
                  fontSize: 12,
                  color: AppColors.ink.withValues(alpha: .4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaTag extends StatelessWidget {
  const _MetaTag(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.fillMuted,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: AppTypography.meta.copyWith(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: AppColors.ink.withValues(alpha: .65),
        ),
      ),
    );
  }
}

class _NextUpCompactRow extends StatelessWidget {
  const _NextUpCompactRow({required this.order, required this.cocktail, required this.onPour});

  final CocktailOrder order;
  final Cocktail? cocktail;
  final VoidCallback onPour;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final wait = formatWait(DateTime.now().difference(order.createdAt));

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(color: AppColors.sheet, borderRadius: AppRadius.tileAll),
      child: Row(
        children: [
          OrderThumb(image: cocktail?.image, size: 48),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cocktail?.title.translate(context) ?? '—',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.cardTitle.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 6),
                Text(
                  _guestLine(l10n, order, wait: wait, buzzed: false),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: AppColors.fillMuted,
            borderRadius: AppRadius.pillAll,
            child: InkWell(
              onTap: onPour,
              borderRadius: AppRadius.pillAll,
              child: Container(
                constraints: const BoxConstraints(minHeight: AppSizes.minTap),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.center,
                child: Text(
                  l10n.queuePourPill,
                  style: AppTypography.cardTitle.copyWith(fontSize: 12, color: AppColors.ink),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InLineRow extends StatelessWidget {
  const _InLineRow({
    required this.order,
    required this.cocktail,
    required this.position,
    required this.onTap,
  });

  final CocktailOrder order;
  final Cocktail? cocktail;
  final int? position;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final wait = formatWait(DateTime.now().difference(order.createdAt));
    final isNew = DateTime.now().difference(order.createdAt) < const Duration(seconds: 60);

    return Material(
      color: AppColors.sheet,
      borderRadius: AppRadius.tileAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.tileAll,
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Row(
            children: [
              OrderThumb(image: cocktail?.image, size: 48),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cocktail?.title.translate(context) ?? '—',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.cardTitle.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _guestLine(l10n, order, wait: wait, buzzed: false),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption,
                    ),
                    if (order.note case final note?) ...[
                      const SizedBox(height: 7),
                      OrderNoteChip(note: note, small: true),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (isNew)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.signalWash,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                    l10n.queueNewTag.toUpperCase(),
                    style: AppTypography.label.copyWith(fontSize: 9, color: AppColors.signalLight),
                  ),
                )
              else if (position != null)
                Text('#$position', style: AppTypography.mono),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.stats, required this.topDrinkTitle});

  final BarNightStats stats;
  final String? topDrinkTitle;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    Widget stat(String label, String value) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: AppTypography.label.copyWith(fontSize: 10)),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.heading.copyWith(fontSize: 17, letterSpacing: -0.34),
          ),
        ],
      ),
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.sheet, borderRadius: AppRadius.tileAll),
      child: Row(
        children: [
          stat(l10n.queueStatPoured, '${stats.poured}'),
          const SizedBox(width: 10),
          stat(
            l10n.queueStatAvgWait,
            stats.averageWait == null ? l10n.queueStatEmpty : formatWait(stats.averageWait!),
          ),
          const SizedBox(width: 10),
          stat(l10n.queueStatTopDrink, topDrinkTitle ?? l10n.queueStatEmpty),
        ],
      ),
    );
  }
}

class _EmptyQueue extends StatelessWidget {
  const _EmptyQueue({required this.onInvite});

  final VoidCallback onInvite;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: AppColors.fillMuted, shape: BoxShape.circle),
          child: const Icon(Icons.local_bar, size: 26, color: AppColors.inkMeta),
        ),
        const SizedBox(height: 18),
        Text(
          l10n.queueEmptyBody,
          textAlign: TextAlign.center,
          style: AppTypography.body.copyWith(color: AppColors.ink.withValues(alpha: .5)),
        ),
        const SizedBox(height: 18),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 220),
          child: AuthPillButton(
            label: l10n.queueEmptyShowQr,
            icon: Icons.qr_code_2,
            height: 48,
            onPressed: onInvite,
          ),
        ),
      ],
    );
  }
}
