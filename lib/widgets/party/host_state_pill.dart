import 'dart:async';

import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import '../../utils/localization_helper.dart';
import '../common/glass.dart';

enum HostPillTone { closed, live, paused }

/// Flow 05 — the one pill that says what state the bar is in: a grey dot
/// for closed and draft, a glowing signal dot for live, solid amber with a
/// pause glyph for paused. Always over a photo.
class HostStatePill extends StatelessWidget {
  const HostStatePill({
    super.key,
    required this.label,
    this.tone = HostPillTone.closed,
  });

  final String label;
  final HostPillTone tone;

  @override
  Widget build(BuildContext context) {
    final paused = tone == HostPillTone.paused;
    final ink = paused ? AppColors.ground : AppColors.ink;

    final Widget marker = switch (tone) {
      HostPillTone.closed => Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(
          color: AppColors.ink.withValues(alpha: .4),
          shape: BoxShape.circle,
        ),
      ),
      HostPillTone.live => Container(
        width: 7,
        height: 7,
        decoration: const BoxDecoration(
          color: AppColors.signal,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: AppColors.signal, blurRadius: 8)],
        ),
      ),
      HostPillTone.paused => const Icon(
        Icons.pause,
        size: 14,
        color: AppColors.ground,
      ),
    };

    return GlassSurface(
      color: paused ? AppColors.low.withValues(alpha: .9) : AppColors.glass,
      padding: EdgeInsets.fromLTRB(tone == HostPillTone.closed ? 12 : 8, 6, 12, 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          marker,
          const SizedBox(width: 8),
          Text(
            label.toUpperCase(),
            style: AppTypography.label.copyWith(color: ink),
          ),
        ],
      ),
    );
  }
}

/// "LIVE · 1H12M", counting from when the bar opened. Ticks twice a minute —
/// the pill shows minutes, so anything faster is wasted frames.
class LiveElapsedPill extends StatefulWidget {
  const LiveElapsedPill({super.key, required this.since});

  /// Null while the server has not stamped Go live yet; reads as just now.
  final DateTime? since;

  static String format(Duration elapsed) {
    final minutes = elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
    return '${elapsed.inHours}h${minutes}m';
  }

  @override
  State<LiveElapsedPill> createState() => _LiveElapsedPillState();
}

class _LiveElapsedPillState extends State<LiveElapsedPill> {
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final elapsed = now.difference(widget.since ?? now);
    return HostStatePill(
      label: context.l10n.hostLivePill(
        LiveElapsedPill.format(elapsed.isNegative ? Duration.zero : elapsed),
      ),
      tone: HostPillTone.live,
    );
  }
}
