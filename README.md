# 📍 GPS Location App with Google Maps - Modul 13

Aplikasi **GPS Location App** ini adalah proyek **Flutter** yang dikembangkan sebagai bagian dari **Praktikum Modul 13**. Aplikasi ini tidak hanya menampilkan koordinat dan alamat pengguna, tetapi juga memvisualisasikan lokasi tersebut secara real-time di atas peta digital menggunakan **Google Maps API**.

Mahasiswa mempelajari integrasi layanan berbasis lokasi (LBS), konversi koordinat (Reverse Geocoding), serta manajemen API Key Google Cloud Platform untuk menampilkan peta interaktif.

## 📘 Tentang Proyek

- **Nama Proyek**: gps_location_app
- **Deskripsi**: Aplikasi pelacak lokasi real-time yang menampilkan posisi pengguna pada Google Maps, dilengkapi dengan marker dan detail alamat (Kecamatan & Kota).
- **Framework**: Flutter
- **Bahasa**: Dart
- **State Management**: `setState()`
- **API Service**: Google Maps Platform (Maps SDK for Android)

## ✨ Fitur Utama

- **Real-time Location**: Mendeteksi lokasi terkini pengguna menggunakan GPS (Fine/Coarse Location).
- **Interactive Map**: Menampilkan peta Google Maps yang dapat digeser dan di-zoom.
- **Smart Camera**: Kamera peta otomatis bergerak dan fokus ke lokasi pengguna saat terdeteksi.
- **Reverse Geocoding**: Mengubah koordinat (Latitude/Longitude) menjadi nama jalan, kecamatan, dan kota.
- **Custom UI**: Tampilan antarmuka modern dengan font Poppins dan indikator loading.
- **Permission Handling**: Menangani permintaan izin lokasi dan error handling jika GPS mati atau izin ditolak.

## 🧰 Tools & Packages

Proyek ini dibangun menggunakan teknologi dan paket berikut:

- **Flutter SDK**
- **VS Code / Android Studio**
- **Google Cloud Platform (Console)** - Untuk manajemen API Key.
- **Dependencies (`pubspec.yaml`):**
  - `geolocator`: ^14.0.2 (Akses GPS)
  - `geocoding`: ^4.0.0 (Konversi Alamat)
  - `Maps_flutter`: ^2.14.0 (Widget Peta)
  - `google_fonts`: ^6.3.2 (Tipografi)

## 🎯 Tujuan Praktikum

Praktikum ini bertujuan untuk:

1. Memahami konsep dasar pengambilan lokasi perangkat menggunakan sensor GPS pada aplikasi berbasis Flutter.
2. Mempelajari penerapan paket `geolocator` dan `geocoding` untuk memperoleh serta mengonversi koordinat lokasi menjadi alamat.
3. **Mengimplementasikan Google Maps SDK** untuk memvisualisasikan data lokasi pada peta digital.
4. Melakukan konfigurasi **API Key** dan `AndroidManifest.xml` untuk akses layanan Google Cloud.
5. Menerapkan penanganan izin akses lokasi dan _error handling_ agar aplikasi berfungsi dengan aman dan stabil.

## ⚙️ Konfigurasi & Instalasi

Untuk menjalankan proyek ini, diperlukan konfigurasi API Key Google Maps:

### 1. Dapatkan API Key

Buat proyek di [Google Cloud Console](https://console.cloud.google.com/), aktifkan **Maps SDK for Android**, dan buat API Key.

### 2. Konfigurasi Android Manifest

Buka file `android/app/src/main/AndroidManifest.xml` dan tambahkan meta-data berikut di dalam tag `<application>`:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="MASUKKAN_API_KEY_ANDA_DISINI"/>
```

### 3. Install Dependencies

Jalankan perintah berikut di terminal:

```bash
flutter pub get
```

### 4. Run App

Pastikan emulator/device memiliki Google Play Services, lalu jalankan:

```bash
flutter run
```
