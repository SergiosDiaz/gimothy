import 'package:flutter_test/flutter_test.dart';
import 'package:gimothy/main.dart';

void main() {
  testWidgets('Gimothy app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const GimothyApp());
    expect(find.text('GIMOTHY'), findsOneWidget);
  });
}
