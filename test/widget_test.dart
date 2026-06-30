import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('SharedPreferences basic test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    expect(prefs, isNotNull);

    await prefs.setString('test', 'value');
    expect(prefs.getString('test'), 'value');
  });

  testWidgets('Widget test placeholder', (WidgetTester tester) async {
    expect(1 + 1, 2);
  });
}
