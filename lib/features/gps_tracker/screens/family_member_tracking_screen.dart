import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:famconnect/features/common/ui/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FamilyMemberTrackingScreen extends StatefulWidget {
  const FamilyMemberTrackingScreen({super.key});

  @override
  State<FamilyMemberTrackingScreen> createState() => _FamilyMemberTrackingScreenState();
}

class _FamilyMemberTrackingScreenState extends State<FamilyMemberTrackingScreen> {
  Set<Marker> _markers = {};
  LatLng? _centerPosition;

  @override
  void initState() {
    super.initState();
    loadFamilyLocations();
  }

  void loadFamilyLocations() {
    FirebaseFirestore.instance

        .collection('family_locations')
        .snapshots()
        .listen((snapshot) {
      Set<Marker> updatedMarkers = {};
      LatLng? firstLocation;

      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (data.containsKey('latitude') && data.containsKey('longitude')) {
          final lat = data['latitude'] as double;
          final lng = data['longitude'] as double;
          final position = LatLng(lat, lng);

          updatedMarkers.add(
            Marker(
              markerId: MarkerId(doc.id),
              position: position,
              infoWindow: InfoWindow(
                title: 'Family Member ${doc.id}',
                snippet: 'Lat: ${lat.toStringAsFixed(5)}, Lng: ${lng.toStringAsFixed(5)}',
              ),
            ),
          );

          firstLocation ??= position;
        }
      }

      setState(() {
        _markers = updatedMarkers;
        _centerPosition ??= firstLocation;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: ('Track Your Family')),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _centerPosition ?? const LatLng(24.9051, 91.8588),
          zoom: 12.4,
        ),
        markers: _markers,
        onMapCreated: (controller) {
          if (_centerPosition != null) {
            controller.animateCamera(
              CameraUpdate.newLatLng(_centerPosition!),
            );
          }
        },
      ),
    );
  }
}
