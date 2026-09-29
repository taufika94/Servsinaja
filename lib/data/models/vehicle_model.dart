class Vehicle {
  final String id;
  final String brand;
  final String model;
  final String plateNumber;
  final int year;
  final String color;
  bool isSelected;

  Vehicle({
    required this.id,
    required this.brand,
    required this.model,
    required this.plateNumber,
    required this.year,
    required this.color,
    this.isSelected = false,
  });
}