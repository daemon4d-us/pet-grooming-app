class Service {
  final String id;
  final String providerId;
  final String name;
  final String description;
  final ServiceType category;
  final double price;
  final int duration; // in minutes
  final bool available;
  final DateTime createdAt;
  final DateTime updatedAt;

  Service({
    required this.id,
    required this.providerId,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.duration,
    required this.available,
    required this.createdAt,
    required this.updatedAt,
  });

  String get formattedPrice => '\$${price.toStringAsFixed(2)}';
  String get formattedDuration => '${duration} min';

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'],
      providerId: json['provider_id'],
      name: json['name'],
      description: json['description'],
      category: ServiceType.fromString(json['category']),
      price: json['price'].toDouble(),
      duration: json['duration'],
      available: json['available'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'provider_id': providerId,
      'name': name,
      'description': description,
      'category': category.value,
      'price': price,
      'duration': duration,
      'available': available,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

enum ServiceType {
  grooming('grooming'),
  sitting('sitting'),
  walking('walking'),
  training('training'),
  boarding('boarding');

  const ServiceType(this.value);
  final String value;

  static ServiceType fromString(String value) {
    return ServiceType.values.firstWhere((type) => type.value == value);
  }

  String get displayName {
    switch (this) {
      case ServiceType.grooming:
        return 'Grooming';
      case ServiceType.sitting:
        return 'Pet Sitting';
      case ServiceType.walking:
        return 'Dog Walking';
      case ServiceType.training:
        return 'Training';
      case ServiceType.boarding:
        return 'Boarding';
    }
  }
}

class CreateServiceRequest {
  final String name;
  final String description;
  final ServiceType category;
  final double price;
  final int duration;
  final bool available;

  CreateServiceRequest({
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.duration,
    this.available = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'category': category.value,
      'price': price,
      'duration': duration,
      'available': available,
    };
  }
}