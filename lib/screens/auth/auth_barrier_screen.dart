import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/auth.dart';
import '../../theme/theme.dart';
import '../../utils/app_router.dart';
import '../../utils/localization_helper.dart';
import '../../widgets/auth/auth_barrier_sheet.dart';
import '../../widgets/auth/auth_controls.dart';
import '../../widgets/common/glass.dart';

/// Flow 03 · screen 01, as a whole screen.
///
/// The barrier is normally a sheet over the thing it interrupted. A guarded
/// route opened cold — from a link, or from a tab restored on launch — has no
/// such thing behind it, and [AuthGuard] renders this instead: the same
/// argument, the same sheet, over a held photograph rather than over a draft.
///
/// It deliberately does not invent the draft the artboard shows behind its
/// scrim. There is nothing there to name, and naming a party that does not
/// exist would be a worse lie than an empty backdrop.
class AuthBarrierScreen extends StatelessWidget {
  const AuthBarrierScreen({
    super.key,
    this.redirectPath,
    this.reason = AuthReason.hostParty,
  });

  /// The path to land on once someone is signed in.
  final String? redirectPath;

  /// What was being attempted, which decides the argument the sheet makes.
  final AuthReason reason;

  static const _backdrop = 'assets/images/onboarding/cosmopolitan.jpg';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.sizeOf(context).height * 0.42,
            child: const Stack(
              fit: StackFit.expand,
              children: [
                Image(image: AssetImage(_backdrop), fit: BoxFit.cover),
                PhotoScrim(),
              ],
            ),
          ),

          // The barrier holds its backdrop back rather than competing with it.
          const ColoredBox(color: Color(0xBD0B0B0C), child: SizedBox.expand()),

          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(
                  left: AppSpacing.screenEdge - 5,
                  top: 8,
                ),
                child: AuthIconAction(
                  icon: Icons.close,
                  onGlass: true,
                  semanticLabel: context.l10n.authClose,
                  onTap: () => _leave(context),
                ),
              ),
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: ConstrainedBox(
              // The backdrop is allowed to shrink to a sliver, but the sheet
              // must never grow past the screen: on a short phone with the
              // text turned up the argument scrolls instead.
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.92,
              ),
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.sheet,
                  borderRadius: AppRadius.sheetTop,
                  boxShadow: [kSheetShadow],
                ),
                child: SafeArea(
                  top: false,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: AuthBarrierSheet(
                      reason: reason,
                      redirectPath: redirectPath,
                      embedded: true,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _leave(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.explore);
    }
  }
}
