import 'package:flutter/material.dart';

import '../../theme/theme.dart';

/// Flow 05 · screen 01 — one of the host's own parties under the hero: a
/// draft waiting to be resumed, a live one to go back to, or last night's
/// recap. The whole card is the tap target; the pill only names the verb.
class HostPartyCard extends StatelessWidget {
  const HostPartyCard({
    super.key,
    required this.title,
    required this.meta,
    required this.actionLabel,
    required this.onTap,
    this.icon = Icons.drafts_outlined,
    this.image,
    this.actionColor = AppColors.ink,
  });

  final String title;
  final String meta;
  final String actionLabel;
  final VoidCallback onTap;
  final IconData icon;

  /// An asset path; when set it replaces the icon tile.
  final String? image;
  final Color actionColor;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$title, $meta. $actionLabel',
      excludeSemantics: true,
      child: Material(
        color: AppColors.sheet,
        borderRadius: AppRadius.cardAll,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.cardAll,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                _leading(),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.section.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.32,
                          height: 1.1,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        meta,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.meta.copyWith(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                          color: AppColors.ink.withValues(alpha: .5),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 13),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 9,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.fillStrong,
                    borderRadius: AppRadius.pillAll,
                  ),
                  child: Text(
                    actionLabel,
                    style: AppTypography.cardTitle.copyWith(
                      fontSize: 12,
                      color: actionColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _leading() {
    const size = 50.0;
    final radius = BorderRadius.circular(14);

    if (image != null) {
      return ClipRRect(
        borderRadius: radius,
        child: Image.asset(image!, width: size, height: size, fit: BoxFit.cover),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: AppColors.signalWash, borderRadius: radius),
      child: Icon(icon, size: 23, color: AppColors.signalLight),
    );
  }
}
