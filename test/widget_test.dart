import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:inventory_pro/app.dart';

void main() {
  testWidgets('App should render without errors', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: InventoryProApp(),
      ),
    );

    expect(find.text('Inventory Pro'), findsWidgets);
  });
}
