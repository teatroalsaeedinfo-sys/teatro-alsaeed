import 'package:flutter_test/flutter_test.dart';
import 'package:teatro_alsaeed_app/main.dart';

void main() {
  testWidgets('shows setup guidance when backend config is absent',
      (tester) async {
    await tester.pumpWidget(const TeatroBootstrap(configured: false));
    expect(find.text('تياترو الصعيد'), findsOneWidget);
    expect(
      find.textContaining('Supabase URL'),
      findsOneWidget,
    );
  });
}
