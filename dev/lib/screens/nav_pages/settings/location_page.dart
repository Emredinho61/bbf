import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MosqueLocationPage extends StatefulWidget {
  const MosqueLocationPage({super.key});

  @override
  State<MosqueLocationPage> createState() => MosqueLocationPageState();
}

class MosqueLocationPageState extends State<MosqueLocationPage> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(
      48.011885215126476,
      7.824162285408069,
    ), // Should be correct lat/long values ig
    zoom: 14.5,
  );

  static const CameraPosition _mosquePosition = CameraPosition(
    bearing: 192.8,
    target: LatLng(
      48.011885215126476,
      7.824162285408069,
    ),
    tilt: 59.4,
    zoom: 19.2,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Moschee Standort")),
      body: GoogleMap(
        mapType: MapType.hybrid,
        initialCameraPosition: _initialPosition,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToMosque,
        label: const Text('Zur Moschee'),
        icon: const Icon(Icons.location_pin),
      ),
    );
  }

  Future<void> _goToMosque() async {
    final GoogleMapController controller = await _controller.future;
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(_mosquePosition),
    );
  }
}
