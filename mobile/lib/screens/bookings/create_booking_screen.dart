import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../providers/booking_provider.dart';
import '../../providers/pet_provider.dart';
import '../../models/booking.dart';
import '../../models/pet.dart';
import '../../models/service.dart';

class CreateBookingScreen extends StatefulWidget {
  const CreateBookingScreen({super.key});

  @override
  State<CreateBookingScreen> createState() => _CreateBookingScreenState();
}

class _CreateBookingScreenState extends State<CreateBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  Pet? _selectedPet;
  Service? _selectedService;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final petProvider = Provider.of<PetProvider>(context, listen: false);
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);

    await Future.wait([
      petProvider.fetchPets(),
      bookingProvider.fetchServices(),
    ]);
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _createBooking() async {
    if (_formKey.currentState!.validate() && _validateForm()) {
      final scheduledDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      final request = CreateBookingRequest(
        petId: _selectedPet!.id,
        serviceId: _selectedService!.id,
        scheduledTime: scheduledDateTime,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );

      final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
      await bookingProvider.createBooking(request);

      if (mounted && bookingProvider.error == null) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking created successfully!')),
        );
      }
    }
  }

  bool _validateForm() {
    if (_selectedPet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a pet')),
      );
      return false;
    }
    if (_selectedService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a service')),
      );
      return false;
    }
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date')),
      );
      return false;
    }
    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a time')),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Service'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        actions: [
          Consumer<BookingProvider>(
            builder: (context, bookingProvider, child) {
              return TextButton(
                onPressed: bookingProvider.isLoading ? null : _createBooking,
                child: bookingProvider.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Book'),
              );
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Pet Selection
              Text(
                'Select Pet',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Consumer<PetProvider>(
                builder: (context, petProvider, child) {
                  if (petProvider.pets.isEmpty) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Icon(Icons.pets, size: 48, color: Colors.grey),
                            const SizedBox(height: 8),
                            const Text('No pets found'),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () => context.go('/pets/add'),
                              child: const Text('Add Pet'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return Wrap(
                    spacing: 8,
                    children: petProvider.pets.map((pet) {
                      final isSelected = _selectedPet?.id == pet.id;
                      return FilterChip(
                        label: Text(pet.name),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedPet = selected ? pet : null;
                          });
                        },
                        avatar: Icon(
                          Icons.pets,
                          size: 16,
                          color: isSelected ? Colors.white : null,
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Service Selection
              Text(
                'Select Service',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Consumer<BookingProvider>(
                builder: (context, bookingProvider, child) {
                  if (bookingProvider.services.isEmpty) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Icon(Icons.design_services, size: 48, color: Colors.grey),
                            SizedBox(height: 8),
                            Text('No services available'),
                          ],
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: bookingProvider.services.map((service) {
                      final isSelected = _selectedService?.id == service.id;
                      return Card(
                        elevation: isSelected ? 4 : 1,
                        color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
                        child: ListTile(
                          leading: Icon(
                            _getServiceIcon(service.category),
                            color: isSelected ? Theme.of(context).primaryColor : null,
                          ),
                          title: Text(service.name),
                          subtitle: Text(
                            '${service.category.displayName} • ${service.formattedDuration}',
                          ),
                          trailing: Text(
                            service.formattedPrice,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Theme.of(context).primaryColor : null,
                            ),
                          ),
                          onTap: service.available
                              ? () {
                                  setState(() {
                                    _selectedService = isSelected ? null : service;
                                  });
                                }
                              : null,
                          enabled: service.available,
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Date & Time Selection
              Text(
                'Select Date & Time',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Card(
                      child: ListTile(
                        leading: const Icon(Icons.calendar_today),
                        title: Text(_selectedDate == null
                            ? 'Select Date'
                            : DateFormat('MMM dd, yyyy').format(_selectedDate!)),
                        onTap: _selectDate,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Card(
                      child: ListTile(
                        leading: const Icon(Icons.access_time),
                        title: Text(_selectedTime == null
                            ? 'Select Time'
                            : _selectedTime!.format(context)),
                        onTap: _selectTime,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Notes
              Text(
                'Additional Notes',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Special instructions or requests',
                  hintText: 'Any special care instructions, preferences, or notes...',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),

              // Booking Summary
              if (_selectedPet != null && _selectedService != null) ...[
                Text(
                  'Booking Summary',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SummaryRow(
                          label: 'Pet',
                          value: _selectedPet!.name,
                        ),
                        _SummaryRow(
                          label: 'Service',
                          value: _selectedService!.name,
                        ),
                        if (_selectedDate != null && _selectedTime != null)
                          _SummaryRow(
                            label: 'Date & Time',
                            value: '${DateFormat('MMM dd, yyyy').format(_selectedDate!)} at ${_selectedTime!.format(context)}',
                          ),
                        _SummaryRow(
                          label: 'Duration',
                          value: _selectedService!.formattedDuration,
                        ),
                        const Divider(),
                        _SummaryRow(
                          label: 'Total Price',
                          value: _selectedService!.formattedPrice,
                          isTotal: true,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Error Display
              Consumer<BookingProvider>(
                builder: (context, bookingProvider, child) {
                  if (bookingProvider.error != null) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          border: Border.all(color: Colors.red[200]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red[700]),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                bookingProvider.error!,
                                style: TextStyle(color: Colors.red[700]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              // Book Button
              Consumer<BookingProvider>(
                builder: (context, bookingProvider, child) {
                  return ElevatedButton(
                    onPressed: bookingProvider.isLoading ? null : _createBooking,
                    child: bookingProvider.isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Confirm Booking'),
                  );
                },
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
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
                : Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            value,
            style: isTotal
                ? Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    )
                : Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}