import 'package:flutter/material.dart';
import '../../generated/l10n/app_localizations.dart';
import '../../models/models.dart';

class CreatePartyForm extends StatefulWidget {
  final Function(Party) onPartyCreated;

  const CreatePartyForm({super.key, required this.onPartyCreated});

  @override
  State<CreatePartyForm> createState() => _CreatePartyFormState();
}

class _CreatePartyFormState extends State<CreatePartyForm> {
  final TextEditingController _partyNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isCreating = false;

  @override
  void dispose() {
    _partyNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _createParty() async {
    if (_partyNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).pleaseEnterPartyName),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isCreating = true;
    });

    // Simulate party creation
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      final party = Party(
        id: 'party_${DateTime.now().millisecondsSinceEpoch}',
        name: _partyNameController.text.trim(),
        hostId: 'current_user_id',
        hostName: 'Current User',
        availableCocktailIds: [],
        joinCode: _generateJoinCode(),
        createdAt: DateTime.now(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      );

      setState(() {
        _isCreating = false;
      });

      widget.onPartyCreated(party);
    }
  }

  String _generateJoinCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    return String.fromCharCodes(
      Iterable.generate(6, (_) => chars.codeUnitAt(random % chars.length)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        // Party Name
        Text(
          l10n.partyDetails,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _partyNameController,
            decoration: InputDecoration(
              labelText: l10n.partyNameLabel,
              hintText: l10n.partyNameHint,
              prefixIcon: Icon(
                Icons.celebration,
                color: Colors.deepPurple.shade400,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Theme.of(context).cardColor,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Description
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: l10n.partyDescriptionLabel,
              hintText: l10n.partyDescriptionHint,
              prefixIcon: Icon(
                Icons.description,
                color: Colors.deepPurple.shade400,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Theme.of(context).cardColor,
            ),
          ),
        ),

        const SizedBox(height: 32),

        // Create Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isCreating ? null : _createParty,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
            ),
            child: _isCreating
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    l10n.createPartyButton,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }
}
