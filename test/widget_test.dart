// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties and correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:namer_app/src/models/app_state.dart';

import 'package:namer_app/main.dart';

void main() {
  testWidgets('Home screen shows idea label', (WidgetTester tester) async {
    final initialState = MyAppState();
    await initialState.setAuth('test_token', {'email': 'test@example.com', 'name': 'Test User'});
    
    await tester.pumpWidget(MyApp(initialState: initialState));

    // wait for frames
    await tester.pumpAndSettle();

    expect(find.text('A random idea:'), findsOneWidget);
  });
}
