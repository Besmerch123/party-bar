import 'package:flutter/material.dart';

/// Opens a bottom sheet on the convention every Flow's sheet shares: a
/// transparent route so the sheet draws its own themed top (background,
/// drag handle, shape all come from [ThemeData.bottomSheetTheme]), and
/// [isScrollControlled] so it can grow to fit a keyboard or a tall body.
///
/// [useSafeArea] defaults to true — clear of the notch and the home
/// indicator — but a couple of call sites already account for the bottom
/// inset in their own content and pass false to keep their existing look.
Future<T?> showAppSheet<T>(
  BuildContext context,
  WidgetBuilder builder, {
  bool useSafeArea = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    useSafeArea: useSafeArea,
    builder: builder,
  );
}
