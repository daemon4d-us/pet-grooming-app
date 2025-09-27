class Pet {
  final String id;
  final String ownerId;
  final String name;
  final String species;
  final String? breed;
  final int? age;
  final double? weight;
  final String? color;
  final String? notes;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  Pet({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.species,
    this.breed,
    this.age,
    this.weight,
    this.color,
    this.notes,
    this.photoUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'],
      ownerId: json['owner_id'],
      name: json['name'],
      species: json['species'],
      breed: json['breed'],
      age: json['age'],
      weight: json['weight']?.toDouble(),
      color: json['color'],
      notes: json['notes'],
      photoUrl: json['photo_url'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'name': name,
      'species': species,
      'breed': breed,
      'age': age,
      'weight': weight,
      'color': color,
      'notes': notes,
      'photo_url': photoUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class CreatePetRequest {
  final String name;
  final String species;
  final String? breed;
  final int? age;
  final double? weight;
  final String? color;
  final String? notes;
  final String? photoUrl;

  CreatePetRequest({
    required this.name,
    required this.species,
    this.breed,
    this.age,
    this.weight,
    this.color,
    this.notes,
    this.photoUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'species': species,
      'breed': breed,
      'age': age,
      'weight': weight,
      'color': color,
      'notes': notes,
      'photo_url': photoUrl,
    };
  }
}