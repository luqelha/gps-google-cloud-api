import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lokasi Saya',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
      ),
      home: const LocationScreen(),
    );
  }
}

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  String? kecamatan;
  String? kota;
  bool isLoading = false;
  String? errorMessage;
  bool _isMyLocationEnabled = false;
  bool _isMapReady = false;

  GoogleMapController? _controllerInstance;
  LatLng? _currentPosition;

  static const CameraPosition _initialCamera = CameraPosition(
    target: LatLng(-6.200000, 106.816666), // Jakarta
    zoom: 14.0,
  );

  @override
  void dispose() {
    _controllerInstance?.dispose();
    _controllerInstance = null;
    super.dispose();
  }

  Future<void> _getLocation() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
      kecamatan = null;
      kota = null;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Layanan lokasi tidak aktif. Mohon aktifkan GPS.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Izin lokasi ditolak oleh pengguna.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(
          'Izin lokasi ditolak permanen. Ubah di pengaturan aplikasi.',
        );
      }

      // ✅ Ambil posisi GPS
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // ✅ Ambil nama lokasi
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        final newPosition = LatLng(position.latitude, position.longitude);

        setState(() {
          kecamatan = place.subLocality ?? "-";
          kota = place.subAdministrativeArea ?? "-";
          _currentPosition = newPosition;
          _isMyLocationEnabled = true;
        });

        // ✅ Animasi kamera HANYA jika benar-benar perlu
        if (_isMapReady && _controllerInstance != null) {
          await Future.delayed(const Duration(milliseconds: 800));

          try {
            await _controllerInstance!.moveCamera(
              CameraUpdate.newLatLngZoom(newPosition, 15),
            );
          } catch (e) {
            debugPrint('Camera move error: $e');
          }
        }
      } else {
        throw Exception('Tidak dapat menemukan informasi alamat.');
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString().replaceAll("Exception: ", "");
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Set<Marker> _createMarker() {
    if (_currentPosition == null) return {};
    return {
      Marker(
        markerId: const MarkerId('currentLocation'),
        position: _currentPosition!,
        infoWindow: const InfoWindow(title: 'Lokasi Anda Sekarang'),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final mapHeight = screenHeight * 0.45;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lokasi Saya', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1A237E),
      ),
      body: Column(
        children: [
          // ✅ SOLUSI ULTIMATE: Wrap dalam RepaintBoundary
          RepaintBoundary(
            child: Container(
              width: screenWidth,
              height: mapHeight,
              color: Colors.grey[200],
              child: GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: _initialCamera,
                onMapCreated: (GoogleMapController controller) async {
                  await Future.delayed(const Duration(milliseconds: 200));

                  if (!mounted) return;

                  _controllerInstance = controller;

                  // Tandai map sudah ready SETELAH delay
                  await Future.delayed(const Duration(milliseconds: 300));
                  if (mounted) {
                    setState(() {
                      _isMapReady = true;
                    });
                  }
                },
                markers: _createMarker(),
                myLocationEnabled: _isMyLocationEnabled,
                myLocationButtonEnabled: false,
                compassEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                indoorViewEnabled: false,
                trafficEnabled: false,
                buildingsEnabled: false,
                rotateGesturesEnabled: false,
                tiltGesturesEnabled: false,
                minMaxZoomPreference: const MinMaxZoomPreference(8, 20),
                padding: EdgeInsets.zero,
                gestureRecognizers: {},
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(20.0),
                        child: isLoading
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(20.0),
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : (errorMessage != null)
                            ? Text(
                                errorMessage!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 14,
                                ),
                              )
                            : (kecamatan == null && kota == null)
                            ? const Text(
                                'Tekan tombol untuk menampilkan lokasi.',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 14),
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on,
                                        color: Color(0xFF1A237E),
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Kelurahan/Kecamatan:',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 28),
                                    child: Text(
                                      kecamatan ?? '-',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_city,
                                        color: Color(0xFF1A237E),
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Kota:',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 28),
                                    child: Text(
                                      kota ?? '-',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: isLoading ? null : _getLocation,
                      icon: const Icon(Icons.my_location, color: Colors.white),
                      label: const Text(
                        'TAMPILKAN LOKASI SAAT INI',
                        style: TextStyle(fontSize: 15, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A237E),
                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        elevation: 5.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
