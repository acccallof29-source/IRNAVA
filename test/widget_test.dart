import 'package:flutter_test/flutter_test.dart';
import 'package:irnava/main.dart';

void main() {
  testWidgets('IRNAVA app starts', (WidgetTester tester) async {
    await tester.pumpWidget(const IrnavaApp());
    expect(find.text('IRNAVA'), findsWidgets);
  });
}
