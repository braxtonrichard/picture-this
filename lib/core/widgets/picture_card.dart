import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';

import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';

/// The core visual unit of Discover: a full-bleed photo with a soft
/// gradient scrim and a couple of lines of type over it. Every masonry
/// tile, vibe card, and recommendation card is one of these — that
/// repetition is what makes the feed feel like Pinterest instead of a
/// list of rows.
class PictureCard extends StatelessWidget {
  const PictureCard({
    required this.imageUrl,
    required this.title,
    super.key,
    this.subtitle,
    this.aspectRatio = 1,
    this.onTap,
    this.trailing,
  });

  final String imageUrl;
  final String title;
  final String? subtitle;
  final double aspectRatio;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.appColors;

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (BuildContext context, String url) =>
                    Shimmer.fromColors(
                      baseColor: colors.surfaceMuted,
                      highlightColor: colors.surface,
                      child: Container(color: colors.surfaceMuted),
                    ),
                errorWidget: (BuildContext context, String url, Object err) =>
                    Container(
                      color: colors.surfaceMuted,
                      child: Icon(
                        Icons.image_outlined,
                        color: colors.textSecondary,
                      ),
                    ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const <double>[0.5, 1],
                      colors: <Color>[
                        Colors.black.withValues(alpha: 0),
                        Colors.black.withValues(alpha: 0.55),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: AppSpacing.md,
                right: AppSpacing.md,
                bottom: AppSpacing.md,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(color: Colors.white),
                    ),
                    if (subtitle != null) ...<Widget>[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null)
                Positioned(
                  top: AppSpacing.sm,
                  right: AppSpacing.sm,
                  child: trailing!,
                ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 260.ms).slideY(begin: 0.02, end: 0);
  }
}
