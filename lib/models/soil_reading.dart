import 'package:cloud_firestore/cloud_firestore.dart';

class SoilReading {
  final String id;
  final double temperature;
  final double moisture;
  final DateTime timestamp;

  SoilReading({
    required this.id,
    required this.temperature,
    required this.moisture,
    required this.timestamp,
  });

  factory SoilReading.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return SoilReading(
      id: doc.id,
      temperature: data['temperature']?.toDouble() ?? 0.0,
      moisture: data['moisture']?.toDouble() ?? 0.0,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'temperature': temperature,
      'moisture': moisture,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}