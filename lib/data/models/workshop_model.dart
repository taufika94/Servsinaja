class Workshop {
  final String id;
  final String name;
  final String address;
  final double distanceKm;     // ← base distance (dari data dummy)
  final double rating;
  final int reviewCount;
  final String image;
  final bool isOpen;
  final String openTime;
  final String closeTime;
  final double latitude;
  final double longitude;

  Workshop({
    required this.id,
    required this.name,
    required this.address,
    required this.distanceKm,
    required this.rating,
    required this.reviewCount,
    required this.image,
    this.isOpen = true,
    this.openTime = '08:00',
    this.closeTime = '17:00',
    required this.latitude,
    required this.longitude,
  });

  // ═══ Copy with dynamic distance ═══
  Workshop copyWith({double? distanceKm}) {
    return Workshop(
      id: id,
      name: name,
      address: address,
      distanceKm: distanceKm ?? this.distanceKm,
      rating: rating,
      reviewCount: reviewCount,
      image: image,
      isOpen: isOpen,
      openTime: openTime,
      closeTime: closeTime,
      latitude: latitude,
      longitude: longitude,
    );
  }
}