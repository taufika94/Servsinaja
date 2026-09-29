import '../models/user_model.dart';

class AuthService {
  // ═══ DUMMY USERS ═══
  static final List<User> _registeredUsers = [
    User(
      id: 'U1',
      name: 'Fika',
      email: 'fika@servisin.id',
      phone: '081234567890',
      password: '123456',
      address: 'Jl. Babarsari No. 45',
      province: 'DI Yogyakarta',
      city: 'Sleman',
      district: 'Depok',
      village: 'Caturtunggal',
      postalCode: '55281',
    ),
  ];

  static User? currentUser;
  static List<User> get registeredUsers => _registeredUsers;

  // ═══ LOGIN ═══
  static String? login(String email, String password) {
    if (email.isEmpty || password.isEmpty) {
      return 'Email dan password wajib diisi';
    }
    final user = _registeredUsers.firstWhere(
      (u) => u.email.toLowerCase() == email.toLowerCase(),
      orElse: () =>
          User(id: '', name: '', email: '', phone: '', password: ''),
    );
    if (user.id.isEmpty) return 'Email tidak terdaftar';
    if (user.password != password) return 'Password salah';
    currentUser = user;
    return null;
  }

  // ═══ REGISTER ═══
  static String? register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
  }) {
    if (name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty) {
      return 'Semua field wajib diisi';
    }
    if (!email.contains('@')) return 'Format email tidak valid';
    if (phone.length < 10) return 'Nomor HP minimal 10 digit';
    if (password.length < 6) return 'Password minimal 6 karakter';
    if (password != confirmPassword) return 'Konfirmasi password tidak sama';

    final exists = _registeredUsers
        .any((u) => u.email.toLowerCase() == email.toLowerCase());
    if (exists) return 'Email sudah terdaftar';

    final newUser = User(
      id: 'U${_registeredUsers.length + 1}',
      name: name,
      email: email,
      phone: phone,
      password: password,
    );
    _registeredUsers.add(newUser);
    currentUser = newUser;
    return null;
  }

  // ═══ LOGOUT ═══
  static void logout() {
    currentUser = null;
  }

  // ═══ UPDATE PROFIL ═══
  static String? updateProfile({
    required String name,
    required String email,
    required String phone,
  }) {
    if (currentUser == null) return 'User tidak login';
    if (name.isEmpty || email.isEmpty || phone.isEmpty) {
      return 'Semua field wajib diisi';
    }
    if (!email.contains('@')) return 'Format email tidak valid';
    if (phone.length < 10) return 'Nomor HP minimal 10 digit';

    // Cek duplikat email (kecuali user ini sendiri)
    final exists = _registeredUsers.any((u) =>
        u.id != currentUser!.id &&
        u.email.toLowerCase() == email.toLowerCase());
    if (exists) return 'Email sudah digunakan user lain';

    // Update
    currentUser!.name = name;
    currentUser!.email = email;
    currentUser!.phone = phone;
    return null;
  }

  // ═══ UPDATE ALAMAT ═══
  static String? updateAddress({
    required String address,
    required String province,
    required String city,
    required String district,
    required String village,
    required String postalCode,
  }) {
    if (currentUser == null) return 'User tidak login';
    if (address.isEmpty ||
        province.isEmpty ||
        city.isEmpty ||
        district.isEmpty ||
        village.isEmpty ||
        postalCode.isEmpty) {
      return 'Semua field alamat wajib diisi';
    }
    if (postalCode.length != 5) {
      return 'Kode pos harus 5 digit';
    }

    currentUser!.address = address;
    currentUser!.province = province;
    currentUser!.city = city;
    currentUser!.district = district;
    currentUser!.village = village;
    currentUser!.postalCode = postalCode;
    return null;
  }

  // ═══ UBAH PASSWORD ═══
  static String? changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) {
    if (currentUser == null) return 'User tidak login';
    if (oldPassword.isEmpty || newPassword.isEmpty) {
      return 'Semua field wajib diisi';
    }
    if (oldPassword != currentUser!.password) {
      return 'Password lama salah';
    }
    if (newPassword.length < 6) {
      return 'Password baru minimal 6 karakter';
    }
    if (newPassword != confirmPassword) {
      return 'Konfirmasi password tidak sama';
    }
    if (newPassword == oldPassword) {
      return 'Password baru harus berbeda dengan yang lama';
    }

    currentUser!.password = newPassword;
    return null;
  }
}