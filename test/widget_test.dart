import 'package:flutter_test/flutter_test.dart';
import 'package:trtravel/main.dart';

void main() {
  testWidgets('App renders main screen', (WidgetTester tester) async {
    await tester.pumpWidget(const TrTravelApp());
    expect(find.text('Itinéraire'), findsOneWidget);
    expect(find.text('Journal'), findsOneWidget);
    expect(find.text('Carte'), findsOneWidget);
  });
}
