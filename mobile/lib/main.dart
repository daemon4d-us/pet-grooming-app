import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/app_config.dart';
import 'providers/auth_provider.dart';
import 'providers/pet_provider.dart';
import 'providers/booking_provider.dart';
import 'screens/auth/splash_screen.dart';
import 'utils/theme.dart';
import 'utils/router.dart';

void main() {
  runApp(const PetGroomingApp());
}

class PetGroomingApp extends StatelessWidget {
  const PetGroomingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PetProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
      ],
      child: MaterialApp.router(
        title: 'Pet Grooming',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}