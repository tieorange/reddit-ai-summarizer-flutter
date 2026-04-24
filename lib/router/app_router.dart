import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/history/view/history_detail_page.dart';
import '../features/history/view/history_page.dart';
import '../features/input/view/input_page.dart';
import '../features/output/view/output_page.dart';
import '../features/settings/view/settings_page.dart';
import '../core/models/history_entry.dart';
import '../core/models/post_data.dart';

final appRouter = GoRouter(
  initialLocation: '/input',
  routes: [
    ShellRoute(
      builder: (context, state, child) => _ScaffoldWithNav(child: child),
      routes: [
        GoRoute(path: '/input', builder: (_, __) => const InputPage()),
        GoRoute(path: '/history', builder: (_, __) => const HistoryPage()),
        GoRoute(path: '/settings', builder: (_, __) => const SettingsPage()),
      ],
    ),
    GoRoute(
      path: '/output',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return OutputPage(
          postData: extra['postData'] as PostData,
          prompt: extra['prompt'] as String,
          url: extra['url'] as String,
        );
      },
    ),
    GoRoute(
      path: '/history/detail',
      builder: (context, state) {
        final entry = state.extra as HistoryEntry;
        return HistoryDetailPage(entry: entry);
      },
    ),
  ],
);

class _ScaffoldWithNav extends StatelessWidget {
  const _ScaffoldWithNav({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final index = location.startsWith('/history')
        ? 1
        : location.startsWith('/settings')
            ? 2
            : 0;
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) {
          switch (i) {
            case 0:
              context.go('/input');
            case 1:
              context.go('/history');
            case 2:
              context.go('/settings');
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.link), label: 'Input'),
          NavigationDestination(icon: Icon(Icons.history), label: 'History'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
