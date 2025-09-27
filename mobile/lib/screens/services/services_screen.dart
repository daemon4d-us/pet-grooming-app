import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../providers/booking_provider.dart';
import '../../models/service.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  ServiceType? _selectedCategory;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BookingProvider>(context, listen: false).fetchServices();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Services'),
      ),
      body: Consumer<BookingProvider>(
        builder: (context, bookingProvider, child) {
          if (bookingProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (bookingProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading services',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    bookingProvider.error!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => bookingProvider.fetchServices(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final services = _selectedCategory == null
              ? bookingProvider.services
              : bookingProvider.getServicesByCategory(_selectedCategory!);

          if (bookingProvider.services.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.design_services,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No services available',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Category Filter
              Container(
                height: 60,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _CategoryChip(
                      label: 'All',
                      isSelected: _selectedCategory == null,
                      onTap: () {
                        setState(() {
                          _selectedCategory = null;
                        });
                      },
                    ),
                    ...ServiceType.values.map(
                      (category) => _CategoryChip(
                        label: category.displayName,
                        isSelected: _selectedCategory == category,
                        onTap: () {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Services List
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => bookingProvider.fetchServices(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: services.length,
                    itemBuilder: (context, index) {
                      final service = services[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      _getServiceIcon(service.category),
                                      color: Theme.of(context).primaryColor,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          service.name,
                                          style: Theme.of(context).textTheme.titleMedium,
                                        ),
                                        Text(
                                          service.category.displayName,
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: Colors.grey[600],
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        service.formattedPrice,
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              color: Theme.of(context).primaryColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      Text(
                                        service.formattedDuration,
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: Colors.grey[600],
                                            ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              if (service.description.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Text(
                                  service.description,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  if (!service.available)
                                    const Chip(
                                      label: Text('Unavailable'),
                                      backgroundColor: Colors.red,
                                    )
                                  else
                                    const Chip(
                                      label: Text('Available'),
                                      backgroundColor: Colors.green,
                                    ),
                                  const Spacer(),
                                  ElevatedButton(
                                    onPressed: service.available
                                        ? () => _bookService(context, service)
                                        : null,
                                    child: const Text('Book Now'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
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

  void _bookService(BuildContext context, service) {
    // Navigate to booking creation with service pre-selected
    context.go('/bookings/create');
    // TODO: Pass service ID to booking screen
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
        checkmarkColor: Theme.of(context).primaryColor,
      ),
    );
  }
}