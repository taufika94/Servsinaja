# 📄 README.md — Instruksi Instalasi & Setup

Berikut file **README.md** lengkap untuk project **ServisinAja**. Copy-paste ke root project kamu.

---

```markdown
# 🏍️ ServisinAja — Aplikasi Booking Servis Motor

Aplikasi mobile Flutter untuk booking servis motor, multi-kendaraan, lacak servis,
dan manajemen riwayat servis. Dibuat dengan **Flutter** dan **Dart**.

---

## 📋 Daftar Isi

- [Prasyarat](#-prasyarat)
- [Konfigurasi SDK](#-konfigurasi-sdk)
- [Instalasi Dependensi](#-instalasi-dependensi)
- [Menjalankan Proyek](#-menjalankan-proyek)
- [Build Production](#-build-production)
- [Struktur Project](#-struktur-project)
- [Troubleshooting](#-troubleshooting)

---

## 🔧 Prasyarat

Sebelum memulai, pastikan **komputer kamu** sudah terpasang:

| Tool | Versi Minimum | Cek Versi |
|------|---------------|-----------|
| **Flutter SDK** | `>= 3.0.0` | `flutter --version` |
| **Dart SDK** | `>= 3.0.0` (bundled with Flutter) | `dart --version` |
| **Android Studio** / **VS Code** | Versi terbaru | — |
| **Android SDK** / **Xcode** | Untuk build mobile | `flutter doctor` |
| **Git** | Versi terbaru | `git --version` |

### Cek Environment

Jalankan:

```bash
flutter doctor
```

Semua item harus **✓ hijau**. Kalau ada yang merah (✗), install dulu tool-nya.

---

## 📦 Konfigurasi SDK

### 1. Install Flutter SDK

#### **Windows / macOS / Linux**

1. Download Flutter SDK dari [flutter.dev/get-started](https://flutter.dev/get-started)
2. Extract ke folder, misal:
   - Windows: `C:\src\flutter`
   - macOS/Linux: `~/development/flutter`

3. Tambahkan `flutter/bin` ke **PATH**:

   **Windows (PowerShell):**
   ```powershell
   [Environment]::SetEnvironmentVariable(
     "Path",
     $env:Path + ";C:\src\flutter\bin",
     [EnvironmentVariableTarget]::User
   )
   ```

   **macOS / Linux (bash/zsh):**
   ```bash
   echo 'export PATH="$PATH:$HOME/development/flutter/bin"' >> ~/.zshrc
   source ~/.zshrc
   ```

4. Verifikasi:
   ```bash
   flutter --version
   ```

### 2. Aktifkan Platform Target

```bash
# Untuk Android
flutter config --enable-android

# Untuk iOS (khusus macOS)
flutter config --enable-ios

# Untuk Web (Chrome)
flutter config --enable-web

# Untuk Desktop (opsional)
flutter config --enable-windows-desktop
flutter config --enable-macos-desktop
flutter config --enable-linux-desktop
```

### 3. Cek Versi SDK yang Dibutuhkan

Buka `pubspec.yaml`, cek bagian:

```yaml
environment:
  sdk: '>=3.0.0 <4.0.0'
```

Pastikan versi Flutter kamu **sesuai** dengan range di atas.

---

## 📥 Instalasi Dependensi

### 1. Clone Repository

```bash
git clone https://github.com/username/servisinaja.git
cd servisinaja
```

### 2. Install Dependensi Flutter

```bash
flutter pub get
```

Perintah ini akan mengunduh semua package yang tercantum di `pubspec.yaml`,
termasuk:

| Package | Fungsi |
|---------|--------|
| `google_fonts` | Font Poppins |
| `intl` | Format tanggal & mata uang |
| `flutter_lints` | Linting |

### 3. Cek Kesehatan Project

```bash
flutter doctor -v
```

### 4. (Opsional) Reset Cache

Kalau ada error aneh, coba:

```bash
flutter clean
flutter pub get
```

---

## ▶️ Menjalankan Proyek

### A. Jalankan di **Chrome (Web)** — Paling Cepat

```bash
flutter run -d chrome
```

Atau kalau ada banyak device:
```bash
flutter devices
flutter run -d <device-id>
```

### B. Jalankan di **Android Emulator**

1. Buka **Android Studio** → **Device Manager** → **Create Device**
2. Pilih device (misal Pixel 5) → **Next** → **Finish**
3. Jalankan emulator
4. Di terminal:
   ```bash
   flutter run
   ```

### C. Jalankan di **Physical Device (Android)**

1. Aktifkan **Developer Options** + **USB Debugging** di HP
2. Sambungkan HP ke laptop via USB
3. Cek device:
   ```bash
   flutter devices
   ```
4. Jalankan:
   ```bash
   flutter run
   ```

### D. Jalankan di **iOS Simulator** (macOS only)

```bash
open -a Simulator
flutter run
```

### E. Hot Reload & Hot Restart

Saat app sudah jalan:

| Aksi | Shortcut |
|------|----------|
| **Hot Reload** (perubahan cepat) | `r` |
| **Hot Restart** (reset state) | `R` |
| **Quit** | `q` |

---

## 🚀 Build Production

### Android — APK

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### Android — App Bundle (Play Store)

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

### iOS — IPA (macOS only)

```bash
flutter build ipa --release
```

### Web

```bash
flutter build web --release
```

Output: `build/web/`

---

## 📁 Struktur Project

```
lib/
├── core/
│   ├── constants/          # Warna, spacing, text style
│   │   ├── app_colors.dart
│   │   ├── app_spacing.dart
│   │   └── app_text_styles.dart
│   └── utils/              # Helper (currency formatter, dll)
│       └── currency_formatter.dart
│
├── data/
│   ├── dummy/              # Data dummy (DummyData, AuthService)
│   │   ├── dummy_data.dart
│   │   └── auth_service.dart
│   └── models/             # Model (Vehicle, Service, dll)
│       ├── vehicle_model.dart
│       ├── service_model.dart
│       ├── service_history_model.dart
│       └── ...
│
├── presentation/
│   ├── screen/             # Layar / halaman
│   │   ├── home_screen.dart
│   │   ├── activity_screen.dart
│   │   ├── booking_summary_screen.dart
│   │   └── ...
│   └── widgets/            # Widget reusable
│       └── ...
│
└── main.dart               # Entry point

assets/
├── images/
│   ├── motor/              # Gambar motor (vario.jpg, nmax.jpg, beat.jpg)
│   ├── workshop/           # Gambar bengkel
│   └── avatar/             # Avatar chat
└── ...
```

---

## 🐛 Troubleshooting

### ❌ `flutter: command not found`

**Solusi:** Flutter belum masuk PATH. Ulangi [Konfigurasi SDK](#-konfigurasi-sdk) langkah 1.

---

### ❌ `Library not defined` / `Failed to initialize`

**Solusi:** 
```bash
flutter clean
flutter pub get
flutter run
```

Kalau masih error, cek import yang salah di file terkait.

---

### ❌ `Unable to load asset: assets/images/...`

**Solusi:** 
1. Cek file ada di folder `assets/images/...`
2. Cek `pubspec.yaml` sudah daftarkan folder:
   ```yaml
   flutter:
     assets:
       - assets/images/
       - assets/images/motor/
   ```
3. Jalankan:
   ```bash
   flutter pub get
   ```

---

### ❌ `CocoaPods not installed` (macOS/iOS)

**Solusi:**
```bash
sudo gem install cocoapods
cd ios
pod install
cd ..
flutter run
```

---

### ❌ `Gradle build failed` (Android)

**Solusi:**
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

---

### ❌ App stuck di splash / blank

**Solusi:**
1. Cek log di terminal tempat `flutter run`
2. Cari baris error merah
3. Cek console di Chrome DevTools (kalau web)

---

### ❌ Hot reload tidak bekerja

**Solusi:** Coba **Hot Restart** (`R` huruf besar), atau stop + run ulang.

---

## 📚 Referensi

- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Flutter Packages](https://pub.dev/)

---

## 👥 Tim

- **Developer:** [Nama Kamu]
- **Email:** [email@example.com]

---

## 📄 Lisensi

Project ini dilisensikan under **MIT License** — lihat file `LICENSE` untuk detail.

---

## ✅ Checklist Cepat

Sekali setup pertama kali:

```bash
# 1. Cek Flutter
flutter --version
flutter doctor

# 2. Clone & masuk folder
git clone <repo-url>
cd servisinaja

# 3. Install dependensi
flutter pub get

# 4. Jalankan (Chrome)
flutter run -d chrome
```

Selesai! 🎉
```

---

## 📝 Cara Pakai README Ini

### 1. Buat File `README.md` di Root Project

```
servisinaja/
├── README.md       ← letakkan di sini
├── pubspec.yaml
├── lib/
└── ...
```

### 2. Sesuaikan dengan Project Kamu

Ganti bagian berikut:
- `https://github.com/username/servisinaja.git` → URL repo kamu
- `[Nama Kamu]` → nama kamu
- `[email@example.com]` → email kamu

### 3. Preview README

Buka di GitHub → akan otomatis di-render jadi halaman cantik.

Atau preview di VS Code:
- Klik kanan file `README.md` → **Open Preview** (`Ctrl+Shift+V`)

---

## 🎯 Highlight Isi README

| Section | Isi |
|---------|-----|
| **Prasyarat** | Cek versi Flutter, Dart, tools |
| **Konfigurasi SDK** | Install Flutter, PATH, aktifkan platform |
| **Instalasi Dependensi** | `flutter pub get`, cek doctor |
| **Menjalankan** | Chrome, Android, iOS — step by step |
| **Build Production** | APK, App Bundle, IPA, Web |
| **Struktur Project** | Peta folder |
| **Troubleshooting** | Solusi error umum |
| **Referensi** | Link dokumentasi |

---

## 💡 Tambahan (Opsional)

Kalau mau lebih lengkap, tambahkan file:

### `.gitignore` (kalau belum ada)

```gitignore
# Flutter/Dart
.dart_tool/
.packages
build/
.flutter-plugins
.flutter-plugins-dependencies

# IDE
.idea/
.vscode/
*.iml

# OS
.DS_Store
Thumbs.db

# Env
.env
```

### `LICENSE` (MIT License)

```markdown
MIT License

Copyright (c) 2024 [Nama Kamu]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## 🚀 Setelah README Dibuat

1. **Commit** ke Git:
   ```bash
   git add README.md
   git commit -m "docs: tambah instruksi instalasi"
   git push
   ```

2. **Cek di GitHub** → halaman repo akan menampilkan README otomatis

3. **Share ke tim** → tinggal kirim link repo, mereka ikuti langkahnya

