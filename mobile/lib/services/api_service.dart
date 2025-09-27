import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config/app_config.dart';
import '../models/user.dart';
import '../models/pet.dart';
import '../models/service.dart';
import '../models/booking.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  Dio? _dio;
  final _storage = const FlutterSecureStorage();
  bool _isInitialized = false;

  void initialize() {
    if (_isInitialized) return;

    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: AppConfig.connectTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add HTTP client adapter to handle SSL certificates and DNS issues
    (_dio!.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate = (HttpClient client) {
      client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      client.connectionTimeout = const Duration(seconds: 30);
      client.idleTimeout = const Duration(seconds: 30);
      // Add custom user agent
      client.userAgent = 'Pet Grooming App/1.0';
      return client;
    };

    _dio!.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await getAuthToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          await clearAuthToken();
        }
        handler.next(error);
      },
    ));

    _isInitialized = true;
  }

  // Auth methods
  Future<void> saveAuthToken(String token) async {
    await _storage.write(key: AppConfig.authTokenKey, value: token);
  }

  Future<String?> getAuthToken() async {
    return await _storage.read(key: AppConfig.authTokenKey);
  }

  Future<void> clearAuthToken() async {
    await _storage.delete(key: AppConfig.authTokenKey);
  }

  Future<bool> isLoggedIn() async {
    final token = await getAuthToken();
    return token != null;
  }

  // API Endpoints

  // Authentication
  Future<LoginResponse> login(LoginRequest request) async {
    final response = await _dio!.post('/auth/login', data: request.toJson());
    return LoginResponse.fromJson(response.data);
  }

  Future<User> register(CreateUserRequest request) async {
    final response = await _dio!.post('/auth/register', data: request.toJson());
    return User.fromJson(response.data);
  }

  // User
  Future<User> getProfile() async {
    final response = await _dio!.get('/users/profile');
    return User.fromJson(response.data);
  }

  // Pets
  Future<List<Pet>> getPets() async {
    final response = await _dio!.get('/pets');
    return (response.data as List).map((json) => Pet.fromJson(json)).toList();
  }

  Future<Pet> createPet(CreatePetRequest request) async {
    final response = await _dio!.post('/pets', data: request.toJson());
    return Pet.fromJson(response.data);
  }

  Future<Pet> getPet(String id) async {
    final response = await _dio!.get('/pets/$id');
    return Pet.fromJson(response.data);
  }

  Future<Pet> updatePet(String id, Map<String, dynamic> updates) async {
    final response = await _dio!.put('/pets/$id', data: updates);
    return Pet.fromJson(response.data);
  }

  Future<void> deletePet(String id) async {
    await _dio!.delete('/pets/$id');
  }

  // Services
  Future<List<Service>> getServices() async {
    final response = await _dio!.get('/services');
    return (response.data as List).map((json) => Service.fromJson(json)).toList();
  }

  Future<Service> getService(String id) async {
    final response = await _dio!.get('/services/$id');
    return Service.fromJson(response.data);
  }

  Future<Service> createService(CreateServiceRequest request) async {
    final response = await _dio!.post('/provider/services', data: request.toJson());
    return Service.fromJson(response.data);
  }

  // Bookings
  Future<List<BookingWithDetails>> getBookings() async {
    final response = await _dio!.get('/bookings');
    return (response.data as List)
        .map((json) => BookingWithDetails.fromJson(json))
        .toList();
  }

  Future<BookingWithDetails> createBooking(CreateBookingRequest request) async {
    final response = await _dio!.post('/bookings', data: request.toJson());
    return BookingWithDetails.fromJson(response.data);
  }

  Future<BookingWithDetails> getBooking(String id) async {
    final response = await _dio!.get('/bookings/$id');
    return BookingWithDetails.fromJson(response.data);
  }

  Future<BookingWithDetails> updateBooking(
      String id, Map<String, dynamic> updates) async {
    final response = await _dio!.put('/bookings/$id', data: updates);
    return BookingWithDetails.fromJson(response.data);
  }

  Future<void> cancelBooking(String id) async {
    await _dio!.delete('/bookings/$id');
  }
}