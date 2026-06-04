import 'package:flutter_test/flutter_test.dart';
import 'package:clarity/main.dart';
import 'package:clarity/core/constants/app_strings.dart';

void main() {
  testWidgets('Onboarding screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ClarityApp());

    // Verify that the Onboarding screen shows the app name.
    expect(find.text(AppStrings.appName), findsOneWidget);
    expect(find.text(AppStrings.welcomeTitle), findsOneWidget);

    // Verify that the "Sign Up" button is present.
    expect(find.text(AppStrings.signUp), findsOneWidget);
  });
}
