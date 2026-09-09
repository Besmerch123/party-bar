import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:party_bar/main.dart';

void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App launches on the splash', (WidgetTester tester) async {
    await tester.pumpWidget(PartyBarApp(showWelcome: true));
    await tester.pump();

    expect(find.text('PartyBar'), findsOneWidget);
    expect(
      find.text('Your shelf. Their orders.\nOne bar, all night.'),
      findsOneWidget,
    );
  });
}
