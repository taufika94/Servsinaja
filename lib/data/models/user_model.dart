class User {
  final String id;
  String name;
  String email;
  String phone;
  String password;

  // ═══ ALAMAT LENGKAP ═══
  String address; // alamat lengkap (nama jalan)
  String province; // provinsi
  String city; // kabupaten/kota
  String district; // kecamatan
  String village; // kelurahan/desa
  String postalCode; // kode pos

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    this.address = '',
    this.province = '',
    this.city = '',
    this.district = '',
    this.village = '',
    this.postalCode = '',
  });

  // Helper: alamat lengkap 1 baris
  String get fullAddress {
    final parts = [address, village, district, city, province, postalCode]
        .where((s) => s.isNotEmpty)
        .toList();
    return parts.isEmpty ? 'Belum ada alamat' : parts.join(', ');
  }

  // Helper: alamat singkat (untuk header)
  String get shortAddress {
    if (city.isEmpty && province.isEmpty) return 'Belum ada alamat';
    return [city, province].where((s) => s.isNotEmpty).join(', ');
  }
}
