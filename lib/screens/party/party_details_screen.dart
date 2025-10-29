import 'package:flutter/material.dart';
import 'package:party_bar/models/models.dart';
import 'package:party_bar/services/party_service.dart';
import 'package:party_bar/utils/localization_helper.dart';
import 'package:party_bar/widgets/party/party_invitation_code.dart';
import 'package:party_bar/widgets/party/party_cocktails_list.dart';
import 'package:party_bar/widgets/party/party_info_editor.dart';
import 'package:party_bar/widgets/party/party_status_control.dart';

class PartyDetailsScreen extends StatefulWidget {
  final String partyId;

  const PartyDetailsScreen({super.key, required this.partyId});

  @override
  State<PartyDetailsScreen> createState() => _PartyDetailsScreenState();
}

class _PartyDetailsScreenState extends State<PartyDetailsScreen> {
  final PartyService _partyService = PartyService();
  Party? _party;
  List<Cocktail> _cocktails = [];
  bool _isLoading = true;
  bool _isUpdating = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPartyData();
  }

  Future<void> _loadPartyData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final party = await _partyService.getPartyById(widget.partyId);
      if (party == null) {
        setState(() {
          _error = 'Party not found';
          _isLoading = false;
        });
        return;
      }

      // TODO: Load cocktails from cocktail service
      // For now, using empty list
      setState(() {
        _party = party;
        _cocktails = [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _updatePartyInfo(String name, String? description) async {
    if (_party == null) return;

    setState(() => _isUpdating = true);

    try {
      await _partyService.updateParty(
        widget.partyId,
        name: name,
        description: description,
      );

      setState(() {
        _party = _party!.copyWith(name: name, description: description);
        _isUpdating = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.saveChanges),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isUpdating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updatePartyStatus(PartyStatus newStatus) async {
    if (_party == null) return;

    setState(() => _isUpdating = true);

    try {
      await _partyService.updatePartyStatus(widget.partyId, newStatus);

      setState(() {
        _party = _party!.copyWith(status: newStatus);
        _isUpdating = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Party status updated'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isUpdating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _removeCocktail(String cocktailId) async {
    if (_party == null) return;

    setState(() => _isUpdating = true);

    try {
      final updatedIds = List<String>.from(_party!.availableCocktailIds)
        ..remove(cocktailId);

      await _partyService.updateAvailableCocktails(widget.partyId, updatedIds);

      setState(() {
        _party = _party!.copyWith(availableCocktailIds: updatedIds);
        _cocktails.removeWhere((c) => c.id == cocktailId);
        _isUpdating = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cocktail removed'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isUpdating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _addCocktails() {
    // TODO: Navigate to cocktail selection screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add cocktails - Coming Soon!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show loading state in both AppBar and body while data is being fetched
    if (_isLoading || _party == null) {
      return Scaffold(
        appBar: AppBar(title: Text(context.l10n.loading), elevation: 0),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Show error state
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error'), elevation: 0),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
              const SizedBox(height: 16),
              Text(
                _error!,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadPartyData,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Main content - party is loaded
    return Scaffold(
      appBar: AppBar(title: Text(_party!.name), elevation: 0),
      body: RefreshIndicator(
        onRefresh: _loadPartyData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Party Info Editor Widget
                PartyInfoEditor(
                  name: _party!.name,
                  description: _party!.description,
                  onSave: _updatePartyInfo,
                  onCancel: () {},
                ),
                const SizedBox(height: 16),

                // Invitation Code Widget
                PartyInvitationCode(
                  joinCode: _party!.joinCode,
                  partyName: _party!.name,
                ),
                const SizedBox(height: 16),

                // Party Status Control Widget
                PartyStatusControl(
                  currentStatus: _party!.status,
                  onStatusChange: _updatePartyStatus,
                  isUpdating: _isUpdating,
                ),
                const SizedBox(height: 16),

                // Party Cocktails List Widget
                PartyCocktailsList(
                  cocktailIds: _party!.availableCocktailIds,
                  cocktails: _cocktails,
                  onRemove: _removeCocktail,
                  onAddCocktails: _addCocktails,
                  isLoading: _isUpdating,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
