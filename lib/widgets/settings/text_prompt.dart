import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import '../../utils/localization_helper.dart';

/// A one-field dialog — the guest-name change, an allergen typed in. Small
/// enough that a whole sheet would be more chrome than the task.
Future<String?> promptForText(
  BuildContext context, {
  required String title,
  String initialValue = '',
  String? hint,
}) {
  final l10n = context.l10n;
  final controller = TextEditingController(text: initialValue);

  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.sheet,
      title: Text(title, style: AppTypography.cardTitle),
      content: TextField(
        controller: controller,
        autofocus: true,
        style: AppTypography.body.copyWith(color: AppColors.ink),
        decoration: hint == null ? null : InputDecoration(hintText: hint),
        onSubmitted: (value) => Navigator.of(context).pop(value),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.cancel)),
        TextButton(
          onPressed: () => Navigator.of(context).pop(controller.text),
          child: Text(l10n.save),
        ),
      ],
    ),
  );
}
