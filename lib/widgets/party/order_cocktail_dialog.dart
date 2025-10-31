import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/models.dart';
import '../../utils/localization_helper.dart';

/// Dialog for ordering a cocktail with optional special requests
class OrderCocktailDialog extends StatefulWidget {
  final Cocktail cocktail;
  final VoidCallback onConfirm;

  const OrderCocktailDialog({
    super.key,
    required this.cocktail,
    required this.onConfirm,
  });

  @override
  State<OrderCocktailDialog> createState() => _OrderCocktailDialogState();
}

class _OrderCocktailDialogState extends State<OrderCocktailDialog> {
  final TextEditingController _specialRequestsController =
      TextEditingController();

  @override
  void dispose() {
    _specialRequestsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        context.l10n.orderConfirmation(
          widget.cocktail.title.translate(context),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.orderConfirmMessage(
              widget.cocktail.title.translate(context),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _specialRequestsController,
            decoration: InputDecoration(
              labelText:
                  '${context.l10n.specialRequests} ${context.l10n.optional}',
              hintText: context.l10n.specialRequestsHint,
              border: const OutlineInputBorder(),
            ),
            maxLines: 2,
            maxLength: 200,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: Text(context.l10n.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            context.pop(_specialRequestsController.text.trim());
            widget.onConfirm();
          },
          child: Text(context.l10n.orderNow),
        ),
      ],
    );
  }
}
