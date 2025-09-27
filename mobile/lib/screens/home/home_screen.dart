import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../providers/pet_provider.dart';
import '../../providers/booking_provider.dart';
import '../../models/service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final petProvider = Provider.of<PetProvider>(context, listen: false);
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);

    await Future.wait([
      petProvider.fetchPets(),
      bookingProvider.fetchServices(),
      bookingProvider.fetchBookings(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet Grooming'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // TODO: Implement notifications
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  final user = authProvider.user;
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            child: Text(
                              user?.firstName.substring(0, 1).toUpperCase() ?? 'U',
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome back,',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                Text(
                                  user?.firstName ?? 'User',
                                  style: Theme.of(context).textTheme.headlineSmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Quick Actions
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.pets,
                      title: 'My Pets',
                      subtitle: 'Manage your pets',
                      onTap: () => context.go('/pets'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.book_online,
                      title: 'Book Service',
                      subtitle: 'Schedule grooming',
                      onTap: () => context.go('/services'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Recent Bookings
              Text(
                'Recent Bookings',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Consumer<BookingProvider>(
                builder: (context, bookingProvider, child) {
                  final recentBookings = bookingProvider.bookings.take(3).toList();

                  if (recentBookings.isEmpty) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Icon(
                              Icons.book_online,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No bookings yet',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Book your first service to get started',
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => context.go('/services'),
                              child: const Text('Browse Services'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: recentBookings.map((booking) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Icon(
                              _getServiceIcon(booking.service.category),
                            ),
                          ),
                          title: Text(booking.service.name),
                          subtitle: Text(
                            '${booking.pet.name} • ${booking.booking.scheduledTime.day}/${booking.booking.scheduledTime.month}',
                          ),
                          trailing: Chip(
                            label: Text(booking.booking.status.displayName),
                            backgroundColor: _getStatusColor(booking.booking.status),
                          ),
                          onTap: () => context.go('/bookings'),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.go('/bookings'),
                child: const Text('View All Bookings'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getServiceIcon(ServiceType category) {
    switch (category) {
      case ServiceType.grooming:
        return Icons.content_cut;
      case ServiceType.sitting:
        return Icons.home;
      case ServiceType.walking:
        return Icons.directions_walk;
      case ServiceType.training:
        return Icons.school;
      case ServiceType.boarding:
        return Icons.hotel;
    }
  }

  Color _getStatusColor(status) {
    switch (status.toString()) {
      case 'BookingStatus.pending':
        return Colors.orange[100]!;
      case 'BookingStatus.confirmed':
        return Colors.blue[100]!;
      case 'BookingStatus.completed':
        return Colors.green[100]!;
      case 'BookingStatus.cancelled':
        return Colors.red[100]!;
      default:
        return Colors.grey[100]!;
    }
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}