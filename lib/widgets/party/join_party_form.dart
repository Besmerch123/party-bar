import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:party_bar/utils/app_router.dart';
import '../../services/party_service.dart';
import '../../utils/localization_helper.dart';

class JoinPartyForm extends StatefulWidget {
  const JoinPartyForm({super.key});

  @override
  State<JoinPartyForm> createState() => _JoinPartyFormState();
}

class _JoinPartyFormState extends State<JoinPartyForm> {
  final TextEditingController _partyCodeController = TextEditingController();
  final TextEditingController _guestNameController = TextEditingController();
  final PartyService _partyService = PartyService();
  bool _isLoading = false;

  @override
  void dispose() {
    _partyCodeController.dispose();
    _guestNameController.dispose();
    super.dispose();
  }

  void _joinParty() async {
    if (_partyCodeController.text.trim().isEmpty ||
        _guestNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.pleaseEnterNameAndCode),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Join party using PartyService
      final party = await _partyService.joinPartyByCode(
        _partyCodeController.text.trim().toUpperCase(),
      );

      if (party == null) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.partyNotFound),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        context.push(
          '${AppRoutes.activePartyGuest}/${party.id}',
          extra: {
            'party': party,
            'guestName': _guestNameController.text.trim(),
          },
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _scanQRCode() {
    // TODO: Implement QR code scanning when feature is ready
    // For now, show a mock result
    _partyCodeController.text = 'PARTY1';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.qrCodeScannedSuccess),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Guest Name Input
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
            controller: _guestNameController,
            decoration: InputDecoration(
              labelText: context.l10n.yourName,
              hintText: context.l10n.enterYourName,
              prefixIcon: Icon(Icons.person, color: Colors.blue.shade400),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Theme.of(context).cardColor,
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Party Code Input
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
            controller: _partyCodeController,
            decoration: InputDecoration(
              labelText: context.l10n.partyCode,
              hintText: context.l10n.enterPartyCode,
              prefixIcon: Icon(Icons.tag, color: Colors.blue.shade400),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Theme.of(context).cardColor,
            ),
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
              LengthLimitingTextInputFormatter(6),
            ],
          ),
        ),

        const SizedBox(height: 30),

        // QR Code Scan Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _scanQRCode,
            icon: const Icon(Icons.qr_code_scanner),
            label: Text(context.l10n.scanQRCode),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: Colors.blue.shade300),
              foregroundColor: Colors.blue.shade600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Join Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _joinParty,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    context.l10n.joinParty,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
