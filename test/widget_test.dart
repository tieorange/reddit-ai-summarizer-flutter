import 'package:flutter_test/flutter_test.dart';
import 'package:reddit_summarizer/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const RedditSummarizerApp());
    expect(find.byType(RedditSummarizerApp), findsOneWidget);
  });
}
