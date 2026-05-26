// lib/data/models/ticket_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class TicketModel {
  final String customerUid;
  final String carId;
  final String carBrand;
  final String carPlate;
  final String tasks;
  final String status; // 'pending' -> 'waiting' -> 'processing' -> 'completed'
  final DateTime createdAt;

  TicketModel({
    required this.customerUid,
    required this.carId,
    required this.carBrand,
    required this.carPlate,
    required this.tasks,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'customerUid': customerUid,
      'carId': carId,
      'carBrand': carBrand,
      'carPlate': carPlate,
      'tasks': tasks,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}