import 'pet.dart';
import 'service.dart';
import 'user.dart';

class Booking {
  final String id;
  final String userId;
  final String petId;
  final String serviceId;
  final String providerId;
  final DateTime scheduledTime;
  final BookingStatus status;
  final String? notes;
  final double totalPrice;
  final DateTime createdAt;
  final DateTime updatedAt;

  Booking({
    required this.id,
    required this.userId,
    required this.petId,
    required this.serviceId,
    required this.providerId,
    required this.scheduledTime,
    required this.status,
    this.notes,
    required this.totalPrice,
    required this.createdAt,
    required this.updatedAt,
  });

  String get formattedPrice => '\$${totalPrice.toStringAsFixed(2)}';

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      userId: json['user_id'],
      petId: json['pet_id'],
      serviceId: json['service_id'],
      providerId: json['provider_id'],
      scheduledTime: DateTime.parse(json['scheduled_time']),
      status: BookingStatus.fromString(json['status']),
      notes: json['notes'],
      totalPrice: json['total_price'].toDouble(),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'pet_id': petId,
      'service_id': serviceId,
      'provider_id': providerId,
      'scheduled_time': scheduledTime.toIso8601String(),
      'status': status.value,
      'notes': notes,
      'total_price': totalPrice,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

enum BookingStatus {
  pending('pending'),
  confirmed('confirmed'),
  inProgress('in_progress'),
  completed('completed'),
  cancelled('cancelled');

  const BookingStatus(this.value);
  final String value;

  static BookingStatus fromString(String value) {
    return BookingStatus.values.firstWhere((status) => status.value == value);
  }

  String get displayName {
    switch (this) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.inProgress:
        return 'In Progress';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
    }
  }
}

class BookingWithDetails {
  final Booking booking;
  final Pet pet;
  final Service service;
  final User user;

  BookingWithDetails({
    required this.booking,
    required this.pet,
    required this.service,
    required this.user,
  });

  factory BookingWithDetails.fromJson(Map<String, dynamic> json) {
    return BookingWithDetails(
      booking: Booking.fromJson(json),
      pet: Pet.fromJson(json['pet']),
      service: Service.fromJson(json['service']),
      user: User.fromJson(json['user']),
    );
  }
}

class CreateBookingRequest {
  final String petId;
  final String serviceId;
  final DateTime scheduledTime;
  final String? notes;

  CreateBookingRequest({
    required this.petId,
    required this.serviceId,
    required this.scheduledTime,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'pet_id': petId,
      'service_id': serviceId,
      'scheduled_time': scheduledTime.toIso8601String(),
      'notes': notes,
    };
  }
}