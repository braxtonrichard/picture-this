import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A primary [ElevatedButton] with a built-in loading spinner, so every
/// async action (sign in, log an experience, submit a reflection) shows
/// the same calm loading state instead of screens rolling their own.
class PtButton extends StatelessWidget {
  const PtButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: loading ? null : onPressed,
      child: loading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                valueColor: AlwaysStoppedAnimation<Color>(
                  context.appColors.background,
                ),
              ),
            )
          : Text(label),
    );
  }
}
