import 'package:financeapp/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Uygulama açıldığında dashboard karşılama metni görünür',
      (WidgetTester tester) async {
    // ProviderScope, Riverpod provider'larının çalışması için gereklidir.
    await tester.pumpWidget(const ProviderScope(child: FinanceApp()));
    await tester.pumpAndSettle();

    expect(find.text('Hoş geldin 👋'), findsOneWidget);
  });
}
