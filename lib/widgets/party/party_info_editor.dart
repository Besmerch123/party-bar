import 'package:flutter/material.dart';
import 'package:party_bar/utils/localization_helper.dart';

/// Widget to edit party name and description
class PartyInfoEditor extends StatelessWidget {
  final String name;
  final String? description;
  final Function(String name, String? description) onSave;
  final VoidCallback onCancel;

  const PartyInfoEditor({
    super.key,
    required this.name,
    this.description,
    required this.onSave,
    required this.onCancel,
  });

  void _showEditDialog(BuildContext context) {
    final nameController = TextEditingController(text: name);
    final descriptionController = TextEditingController(text: description);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.editPartyInfo),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: context.l10n.partyNameLabel,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return context.l10n.pleaseEnterPartyName;
                  }
                  return null;
                },
                maxLength: 50,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: context.l10n.partyDescriptionLabel,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
                maxLength: 200,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onCancel();
            },
            child: Text(context.l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final newName = nameController.text.trim();
                final newDescription = descriptionController.text.trim();
                onSave(newName, newDescription.isEmpty ? null : newDescription);
                Navigator.of(context).pop();
              }
            },
            child: Text(context.l10n.saveChanges),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _showEditDialog(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline),
                      const SizedBox(width: 8),
                      Text(
                        context.l10n.partyDetails,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Icon(Icons.edit, size: 20),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                context.l10n.partyNameLabel,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (description != null && description!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  context.l10n.partyDescriptionLabel,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(description!, style: const TextStyle(fontSize: 14)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
