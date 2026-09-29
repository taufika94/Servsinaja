import 'vehicle_model.dart';
import 'service_model.dart';

class Booking {
  final String id;
  final String ticketNumber;
  final List<Vehicle> vehicles;
  final List<VehicleServiceConfig> configs;
  final DateTime scheduleDate;
  final String scheduleTime;
  final String workshop;
  final int totalPrice;
  final int totalDuration;
  final DateTime createdAt;
  final String status;

  Booking({
    required this.id,
    required this.ticketNumber,
    required this.vehicles,
    required this.configs,
    required this.scheduleDate,
    required this.scheduleTime,
    required this.workshop,
    required this.totalPrice,
    required this.totalDuration,
    required this.createdAt,
    this.status = 'Menunggu Konfirmasi',
  });
}