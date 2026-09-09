import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import '../common/app_chip.dart';

/// A sample order shown on step 03.
///
/// Illustration, not the real queue — the working card lives in
/// `widgets/party/order_card.dart`. It exists here only to show what a host
/// sees, so it is deliberately inert and excluded from the semantics tree.
class MockOrderCard extends StatelessWidget {
  const MockOrderCard({
    super.key,
    required this.image,
    required this.title,
    required this.subtitle,
    required this.statusLabel,
    this.quantity,
    this.tone = ChipTone.neutral,
    this.dimmed = false,
  });

  final String image;
  final String title;
  final String subtitle;
  final String statusLabel;
  final int? quantity;
  final ChipTone tone;

  /// Older orders sit back so the newest one reads first.
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Opacity(
        opacity: dimmed ? .62 : 1,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: const BoxDecoration(
            color: AppColors.sheet,
            borderRadius: AppRadius.tileAll,
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: Image.asset(
                  image,
                  width: 44,
                  height: 44,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        text: title,
                        children: [
                          if (quantity != null)
                            TextSpan(
                              text: '  ×$quantity',
                              style: AppTypography.measure.copyWith(
                                fontSize: 12,
                                color: AppColors.inkMeta,
                              ),
                            ),
                        ],
                      ),
                      style: AppTypography.cardTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTypography.meta.copyWith(
                        fontSize: 12,
                        height: 1.0,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              StatusChip(label: statusLabel, tone: tone),
            ],
          ),
        ),
      ),
    );
  }
}
