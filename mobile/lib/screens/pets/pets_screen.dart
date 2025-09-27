import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../providers/pet_provider.dart';

class PetsScreen extends StatefulWidget {
  const PetsScreen({super.key});

  @override
  State<PetsScreen> createState() => _PetsScreenState();
}

class _PetsScreenState extends State<PetsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PetProvider>(context, listen: false).fetchPets();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Pets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.go('/pets/add'),
          ),
        ],
      ),
      body: Consumer<PetProvider>(
        builder: (context, petProvider, child) {
          if (petProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (petProvider.error != null) {
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
                    'Error loading pets',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    petProvider.error!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => petProvider.fetchPets(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (petProvider.pets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.pets,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No pets added yet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your first pet to get started',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => context.go('/pets/add'),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Pet'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => petProvider.fetchPets(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: petProvider.pets.length,
              itemBuilder: (context, index) {
                final pet = petProvider.pets[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundImage: pet.photoUrl != null
                                  ? NetworkImage(pet.photoUrl!)
                                  : null,
                              child: pet.photoUrl == null
                                  ? Icon(
                                      _getPetIcon(pet.species),
                                      size: 30,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    pet.name,
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                  Text(
                                    '${pet.species}${pet.breed != null ? ' • ${pet.breed}' : ''}',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  if (pet.age != null)
                                    Text(
                                      '${pet.age} years old',
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                ],
                              ),
                            ),
                            PopupMenuButton<String>(
                              onSelected: (value) async {
                                if (value == 'edit') {
                                  // TODO: Navigate to edit pet screen
                                } else if (value == 'delete') {
                                  _showDeleteConfirmation(context, pet.id, pet.name);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Edit'),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Delete'),
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (pet.notes != null && pet.notes!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            pet.notes!,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            if (pet.weight != null)
                              Chip(
                                label: Text('${pet.weight} kg'),
                                avatar: const Icon(Icons.monitor_weight, size: 16),
                              ),
                            if (pet.color != null) ...[
                              const SizedBox(width: 8),
                              Chip(
                                label: Text(pet.color!),
                                avatar: const Icon(Icons.palette, size: 16),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/pets/add'),
        child: const Icon(Icons.add),
      ),
    );
  }

  IconData _getPetIcon(String species) {
    switch (species.toLowerCase()) {
      case 'dog':
        return Icons.pets;
      case 'cat':
        return Icons.pets;
      case 'bird':
        return Icons.flight;
      case 'fish':
        return Icons.phishing;
      case 'rabbit':
        return Icons.cruelty_free;
      default:
        return Icons.pets;
    }
  }

  void _showDeleteConfirmation(BuildContext context, String petId, String petName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Pet'),
        content: Text('Are you sure you want to delete $petName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final petProvider = Provider.of<PetProvider>(context, listen: false);
              await petProvider.deletePet(petId);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$petName has been deleted')),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}