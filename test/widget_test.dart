import 'package:flutter_test/flutter_test.dart';

import 'package:nampak/main.dart';

void main() {
  testWidgets('shows Supabase config guidance when dart defines are missing', (
    tester,
  ) async {
    await tester.pumpWidget(const MissingSupabaseConfigApp());

    expect(find.text('Nampak'), findsOneWidget);
    expect(find.text('Supabase is not configured yet.'), findsOneWidget);
  });
}
