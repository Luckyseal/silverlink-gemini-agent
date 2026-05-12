import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:silverlink_gemini_agent/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('SilverLink shell renders settings entrypoint', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const SilverLinkApp());
    await tester.pump(const Duration(milliseconds: 800));
    expect(find.byTooltip('設定'), findsOneWidget);
  });
}
