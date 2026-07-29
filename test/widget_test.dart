import 'package:flutter_test/flutter_test.dart';
import 'package:houslice/app.dart';
import 'package:houslice/injection_container.dart' as di;

void main() {
  testWidgets('App boots to splash then onboarding in demo mode',
      (tester) async {
    await di.init(useFirebase: false);
    await tester.pumpWidget(const HousliceApp());
    expect(find.text('HOUSLICE'), findsOneWidget);

    // Let the splash timer fire and the session check resolve; with no
    // signed-in user the app should land on onboarding.
    await tester.pump(const Duration(milliseconds: 1700));
    await tester.pumpAndSettle();
    expect(find.text('Next'), findsOneWidget);
  });
}
