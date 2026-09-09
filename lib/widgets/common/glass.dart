import 'dart:ui';

import 'package:flutter/material.dart';

import '../../theme/theme.dart';

/// A translucent blurred surface.
///
/// Glass only reads correctly over photography — on [AppColors.ground] use a
/// [AppColors.sheet] or [AppColors.row] fill instead.
class GlassSurface extends StatelessWidget {
  const GlassSurface({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.borderRadius = AppRadius.pillAll,
    this.color = AppColors.glass,
    this.stroke,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final Color color;
  final Color? stroke;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: AppSizes.glassBlur,
          sigmaY: AppSizes.glassBlur,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color,
            borderRadius: borderRadius,
            border: stroke == null ? null : Border.all(color: stroke!),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: onTap,
              borderRadius: borderRadius,
              child: Padding(padding: padding, child: child),
            ),
          ),
        ),
      ),
    );
  }
}

/// Circular glass affordance for icon actions floating over a photo.
class GlassIconButton extends StatelessWidget {
  const GlassIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.size = AppSizes.minTap,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final button = SizedBox(
      width: size,
      height: size,
      child: GlassSurface(
        borderRadius: BorderRadius.circular(size / 2),
        onTap: onTap,
        child: Icon(icon, size: size * 0.44, color: AppColors.ink),
      ),
    );

    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}

/// Applies the one approved scrim so a photo can carry UI at the top and
/// dissolve into the ground at the bottom.
class PhotoScrim extends StatelessWidget {
  const PhotoScrim({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppColors.photoScrim),
      child: child ?? const SizedBox.expand(),
    );
  }
}
