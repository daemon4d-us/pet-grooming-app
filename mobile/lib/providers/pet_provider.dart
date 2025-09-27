import 'package:flutter/foundation.dart';
import '../models/pet.dart';
import '../services/api_service.dart';

class PetProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  PetProvider() {
    _apiService.initialize();
  }

  List<Pet> _pets = [];
  bool _isLoading = false;
  String? _error;

  List<Pet> get pets => _pets;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchPets() async {
    _setLoading(true);
    _clearError();

    try {
      _pets = await _apiService.getPets();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createPet(CreatePetRequest request) async {
    _setLoading(true);
    _clearError();

    try {
      final newPet = await _apiService.createPet(request);
      _pets.add(newPet);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updatePet(String id, Map<String, dynamic> updates) async {
    _setLoading(true);
    _clearError();

    try {
      final updatedPet = await _apiService.updatePet(id, updates);
      final index = _pets.indexWhere((pet) => pet.id == id);
      if (index != -1) {
        _pets[index] = updatedPet;
        notifyListeners();
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deletePet(String id) async {
    _setLoading(true);
    _clearError();

    try {
      await _apiService.deletePet(id);
      _pets.removeWhere((pet) => pet.id == id);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Pet? getPetById(String id) {
    try {
      return _pets.firstWhere((pet) => pet.id == id);
    } catch (e) {
      return null;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }
}