import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../screens/auth/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/pets/pets_screen.dart';
import '../screens/pets/add_pet_screen.dart';
import '../screens/bookings/bookings_screen.dart';
import '../screens/bookings/create_booking_screen.dart';
import '../screens/services/services_screen.dart';
import '../screens/profile/profile_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final isLoggedIn = authProvider.isLoggedIn;

      // Splash screen handling
      if (state.fullPath == '/splash') {
        return null; // Allow splash screen
      }

      // If not logged in and trying to access protected routes
      if (!isLoggedIn && !_isAuthRoute(state.fullPath!)) {
        return '/login';
      }

      // If logged in and trying to access auth routes
      if (isLoggedIn && _isAuthRoute(state.fullPath!)) {
        return '/home';
      }

      return null; // No redirect needed
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainNavigation(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/pets',
            builder: (context, state) => const PetsScreen(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (context, state) => const AddPetScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/services',
            builder: (context, state) => const ServicesScreen(),
          ),
          GoRoute(
            path: '/bookings',
            builder: (context, state) => const BookingsScreen(),
            routes: [
              GoRoute(
                path: 'create',
                builder: (context, state) => const CreateBookingScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
  );

  static bool _isAuthRoute(String path) {
    return path == '/login' || path == '/register' || path == '/splash';
  }
}

class MainNavigation extends StatelessWidget {
  final Widget child;

  const MainNavigation({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _calculateSelectedIndex(context),
        onTap: (index) => _onItemTapped(index, context),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pets),
            label: 'My Pets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.design_services),
            label: 'Services',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_online),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  static int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).fullPath!;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/pets')) return 1;
    if (location.startsWith('/services')) return 2;
    if (location.startsWith('/bookings')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        GoRouter.of(context).go('/home');
        break;
      case 1:
        GoRouter.of(context).go('/pets');
        break;
      case 2:
        GoRouter.of(context).go('/services');
        break;
      case 3:
        GoRouter.of(context).go('/bookings');
        break;
      case 4:
        GoRouter.of(context).go('/profile');
        break;
    }
  }
}