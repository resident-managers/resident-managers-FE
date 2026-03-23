// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:quan_ly_dan_cu/app_user.dart';

void main() {
  testWidgets('App shows login screen', (WidgetTester tester) async {
    dotenv.loadFromString(
      envString:
          'GRAPHQL_ENDPOINT=https://known-leech-fresh.ngrok-free.app/graphql',
    );

    await tester.pumpWidget(const ProviderScope(child: AppUser()));
    await tester.pumpAndSettle();

    expect(find.text('Quản lý dân cư'), findsOneWidget);
    expect(find.text('Đăng nhập'), findsOneWidget);
  });
}
