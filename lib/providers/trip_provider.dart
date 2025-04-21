import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/trip.dart';

class TripProvider extends ChangeNotifier {
  late Box<Trip> _tripBox;
  List<Trip> _trips = [];

  TripProvider() {
    _initializeBox();
  }

  Future<void> _initializeBox() async {
    _tripBox = Hive.box<Trip>('trips');
    await loadTrips();
  }

  List<Trip> get trips => _trips;
  Future<void> loadTrips() async {
    _trips = _tripBox.values.toList();
    notifyListeners();
  }

  Future<void> addTrip(Trip trip) async {
    await _tripBox.add(trip);
    _trips.add(trip);
    notifyListeners();
  }

  Future<void> updateTrip(Trip trip) async {
    await trip.save();
    loadTrips(); // Reload to ensure correct order
    notifyListeners();
  }

  Future<void> deleteTrip(Trip trip) async {
    await trip.delete();
    _trips.remove(trip);
    notifyListeners();
  }

  Future<void> toggleTripCompletion(Trip trip) async {
    trip.isCompleted = !trip.isCompleted;
    await trip.save();
    notifyListeners();
  }

  Future<void> deleteAllTrips() async {
    await _tripBox.clear();
    _trips.clear();
    notifyListeners();
  }
} 