import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:goflutterbank/core/router/app.router.dart';
import 'package:goflutterbank/core/theme/app.theme.dart';

void main() {
  runApp(const ProviderScope(child: LumoApp()));
}

class LumoApp extends ConsumerWidget {
  const LumoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Lumo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}
