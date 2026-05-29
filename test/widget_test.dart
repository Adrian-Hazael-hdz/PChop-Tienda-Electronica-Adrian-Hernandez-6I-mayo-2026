import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/app/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Verifica que la app construye sin errores
    await tester.pumpWidget(const MyApp());
    expect(find.byType(MyApp), findsOneWidget);
  });
}
