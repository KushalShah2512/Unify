import 'package:flutter/material.dart';

import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const GigsyApp());
}

class GigsyApp extends StatelessWidget {
  const GigsyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Gigsy',
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}