class PickupLocation {
  final double latitude;
  final double longitude;
  final String address;
  final String? shortName;
  final String? note;

  PickupLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
    this.shortName,
    this.note,
  });

  String get coords => '$latitude,$longitude';

  String get displayAddress {
    if (note != null && note!.isNotEmpty) {
      return '$address\n($note)';
    }
    return address;
  }

  Map<String, dynamic> toMap() => {
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
        'shortName': shortName,
        'note': note,
      };

  factory PickupLocation.fromMap(Map<String, dynamic> map) {
    return PickupLocation(
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      address: map['address'] as String,
      shortName: map['shortName'] as String?,
      note: map['note'] as String?,
    );
  }
}