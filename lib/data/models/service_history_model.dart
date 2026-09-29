class ServiceHistory {
  final String id;
  final String ticketNumber;
  final String vehicleId;
  final String vehicleName;
  final String plateNumber;
  final String serviceType;
  final DateTime date;
  final int totalPrice;
  final String status;
  final String workshop;
  final int currentKm;

  ServiceHistory({
    required this.id,
    required this.ticketNumber,
    required this.vehicleId,
    required this.vehicleName,
    required this.plateNumber,
    required this.serviceType,
    required this.date,
    required this.totalPrice,
    required this.status,
    required this.workshop,
    this.currentKm = 0,
  });
}

class ChatMessage {
  final String id;
  final String sender;
  final String message;
  final DateTime timestamp;
  final bool isUser;

  ChatMessage({
    required this.id,
    required this.sender,
    required this.message,
    required this.timestamp,
    required this.isUser,
  });
}