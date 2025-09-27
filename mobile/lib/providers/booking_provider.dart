import 'package:flutter/foundation.dart';
import '../models/booking.dart';
import '../models/service.dart';
import '../services/api_service.dart';

class BookingProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  BookingProvider() {
    _apiService.initialize();
  }

  List<BookingWithDetails> _bookings = [];
  List<Service> _services = [];
  bool _isLoading = false;
  String? _error;

  List<BookingWithDetails> get bookings => _bookings;
  List<Service> get services => _services;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchBookings() async {
    _setLoading(true);
    _clearError();

    try {
      _bookings = await _apiService.getBookings();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchServices() async {
    _setLoading(true);
    _clearError();

    try {
      _services = await _apiService.getServices();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createBooking(CreateBookingRequest request) async {
    _setLoading(true);
    _clearError();

    try {
      final newBooking = await _apiService.createBooking(request);
      _bookings.add(newBooking);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateBooking(String id, Map<String, dynamic> updates) async {
    _setLoading(true);
    _clearError();

    try {
      final updatedBooking = await _apiService.updateBooking(id, updates);
      final index = _bookings.indexWhere((booking) => booking.booking.id == id);
      if (index != -1) {
        _bookings[index] = updatedBooking;
        notifyListeners();
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> cancelBooking(String id) async {
    _setLoading(true);
    _clearError();

    try {
      await _apiService.cancelBooking(id);
      _bookings.removeWhere((booking) => booking.booking.id == id);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  List<BookingWithDetails> getBookingsByStatus(BookingStatus status) {
    return _bookings.where((booking) => booking.booking.status == status).toList();
  }

  List<Service> getServicesByCategory(ServiceType category) {
    return _services.where((service) => service.category == category).toList();
  }

  Service? getServiceById(String id) {
    try {
      return _services.firstWhere((service) => service.id == id);
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