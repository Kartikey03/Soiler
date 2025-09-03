import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/soil_reading.dart';

class DataProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<SoilReading> _readings = [];
  SoilReading? _latestReading;
  bool _isLoading = false;

  List<SoilReading> get readings => _readings;
  SoilReading? get latestReading => _latestReading;
  bool get isLoading => _isLoading;

  String get _userId => _auth.currentUser?.uid ?? '';

  Future<void> saveReading(double temperature, double moisture) async {
    if (_userId.isEmpty) return;

    try {
      final reading = SoilReading(
        id: '',
        temperature: temperature,
        moisture: moisture,
        timestamp: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('readings')
          .add(reading.toFirestore());

      _latestReading = reading;
      notifyListeners();
    } catch (e) {
      print('Error saving reading: $e');
    }
  }

  Future<void> loadReadings() async {
    if (_userId.isEmpty) return;

    try {
      _isLoading = true;
      notifyListeners();

      final querySnapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('readings')
          .orderBy('timestamp', descending: true)
          .get();

      _readings = querySnapshot.docs
          .map((doc) => SoilReading.fromFirestore(doc))
          .toList();

      if (_readings.isNotEmpty) {
        _latestReading = _readings.first;
      }
    } catch (e) {
      print('Error loading readings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Stream<List<SoilReading>> getReadingsStream() {
    if (_userId.isEmpty) return Stream.empty();

    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('readings')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => SoilReading.fromFirestore(doc))
        .toList());
  }
}