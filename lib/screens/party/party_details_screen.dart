import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:party_bar/models/models.dart';
import 'package:party_bar/screens/party/draft_party_screen.dart';
import 'package:party_bar/screens/party/party_ending.dart';
import 'package:party_bar/services/party_service.dart';
import 'package:party_bar/services/auth_service.dart';
import 'package:party_bar/utils/app_router.dart';
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
  final AuthService _authService = AuthService();
  Party? _party;
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

      setState(() {
        _party = party;
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

      final endedParty = _party!.copyWith(status: newStatus);
      setState(() {
        _party = endedParty;
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

      // Flow 04 screen 08: once a party ends, ask what ran out — but only
      // as a courtesy. A stats query that fails or hangs must never stop
      // the host from seeing their status change go through, so this is
      // fire-and-forget from the caller's point of view and swallows its
      // own errors down to "just the party name" whenever anything about
      // the pour tally cannot be read.
      if (newStatus == PartyStatus.ended && mounted) {
        final args = await ranOutArgsFor(endedParty);
        if (mounted) context.push(AppRoutes.barRanOut, extra: args);
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

    // Flow 05 · screen 07 — a draft has its own screen until it goes live.
    if (_party!.isDraft) {
      return DraftPartyScreen(
        party: _party!,
        onPartyChanged: (party) => setState(() => _party = party),
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
                  party: _party!,
                  currentUserId: _authService.currentUser?.uid ?? '',
                  onStatusChange: _updatePartyStatus,
                  isUpdating: _isUpdating,
                ),
                const SizedBox(height: 16),

                // Party Cocktails List Widget
                PartyCocktailsList(
                  partyId: widget.partyId,
                  initialCocktailIds: _party!.availableCocktailIds,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
