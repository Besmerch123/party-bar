import 'package:flutter/material.dart';
import 'package:party_bar/models/models.dart';
import 'package:party_bar/services/cocktail_service.dart';
import 'package:party_bar/services/party_service.dart';
import 'package:party_bar/utils/localization_helper.dart';
import 'package:party_bar/widgets/party/add_cocktails_bottom_sheet.dart';
import 'package:party_bar/widgets/cocktails/cocktail_list_item.dart';

/// Widget to display and manage party cocktails list
class PartyCocktailsList extends StatefulWidget {
  final String partyId;
  final List<String> initialCocktailIds;

  const PartyCocktailsList({
    super.key,
    required this.partyId,
    required this.initialCocktailIds,
  });

  @override
  State<PartyCocktailsList> createState() => _PartyCocktailsListState();
}

class _PartyCocktailsListState extends State<PartyCocktailsList> {
  final CocktailService _cocktailService = CocktailService();
  final PartyService _partyService = PartyService();

  List<Cocktail> _cocktails = [];
  bool _isLoading = false;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _loadCocktails();
  }

  @override
  void didUpdateWidget(PartyCocktailsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload cocktails if the initial IDs changed
    if (oldWidget.initialCocktailIds != widget.initialCocktailIds) {
      _loadCocktails();
    }
  }

  Future<void> _loadCocktails() async {
    if (widget.initialCocktailIds.isEmpty) {
      setState(() {
        _cocktails = [];
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      final cocktails = await _cocktailService.getCocktailsByIds(
        widget.initialCocktailIds,
      );

      if (mounted) {
        setState(() {
          _cocktails = cocktails;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load cocktails: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _removeCocktail(String cocktailId) async {
    setState(() => _isUpdating = true);

    try {
      await _partyService.removeCocktailFromParty(widget.partyId, cocktailId);

      if (mounted) {
        setState(() {
          _cocktails.removeWhere((c) => c.id == cocktailId);
          _isUpdating = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.removeCocktail),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUpdating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove cocktail: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _addCocktails() async {
    // Get the IDs of already added cocktails
    final alreadyAddedIds = _cocktails.map((c) => c.id).toList();

    // Show the bottom sheet and wait for the result
    final selectedCocktails = await AddCocktailsBottomSheet.show(
      context,
      alreadyAddedCocktailIds: alreadyAddedIds,
    );

    // If user cancelled or no cocktails selected, do nothing
    if (selectedCocktails == null || selectedCocktails.isEmpty) {
      return;
    }

    // Filter out cocktails that are already added
    final newCocktails = selectedCocktails
        .where((cocktail) => !alreadyAddedIds.contains(cocktail.id))
        .toList();

    if (newCocktails.isEmpty) {
      // All selected cocktails are already added
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.cocktailsAlreadyAdded),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    setState(() => _isUpdating = true);

    try {
      // Add cocktails to the party
      await _partyService.addCocktailsToParty(
        widget.partyId,
        newCocktails.map((c) => c.id).toList(),
      );

      // Update local state
      if (mounted) {
        setState(() {
          _cocktails.addAll(newCocktails);
          _isUpdating = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.l10n.cocktailsAddedSuccess(newCocktails.length),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUpdating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.failedToAddCocktails(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
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
                    Icon(Icons.local_bar),
                    const SizedBox(width: 8),
                    Text(
                      context.l10n.partyCocktails,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: (_isLoading || _isUpdating) ? null : _addCocktails,
                  icon: const Icon(Icons.add),
                  label: Text(context.l10n.addCocktails),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_cocktails.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.local_bar_outlined,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.l10n.noCocktailsAdded,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _cocktails.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final cocktail = _cocktails[index];
                  return CocktailListItem(
                    cocktail: cocktail,
                    onRemove: () => _removeCocktail(cocktail.id),
                    isUpdating: _isUpdating,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
