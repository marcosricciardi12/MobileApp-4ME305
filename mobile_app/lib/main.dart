import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';

void main() => runApp(const MobileApp());

class MobileApp extends StatelessWidget {
  const MobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: "Mobile App",
      home: Inicio(),
    );
  }
}

class Inicio extends StatefulWidget {
  const Inicio({super.key});

  @override
  State<Inicio> createState() => _InicioState();
}

class _InicioState extends State<Inicio> {

  late double lat = 0;
  late double long = 0;
  late LatLng position = LatLng( lat , long);
  late GoogleMapController mapController;

  late LatLng _center =  LatLng(-32.888153965240924, -68.86453057731511);

  void _onMapCreated(GoogleMapController controller) {
      mapController = controller;
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if(!serviceEnabled) {
      return Future.error('Location service is disabled');
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error("Location permission is deneid");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error("Impossible to resolve");
    }
    return await Geolocator.getCurrentPosition();
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 100, 120, 200),
        title: const Text("MobileApp"),
        centerTitle: true,
      leading: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Image.asset(
            "assets/logoMR.png",
          ),
        ),
      ),
      body: ListView(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(20.0),
            child: const Center(
              child: Text("Welcome to Mobile App!"),
            )
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.45,
            padding: const EdgeInsets.all(15.0),
            child: GoogleMap(
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              mapType: MapType.normal,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: true,
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 11.0,
              ),
              markers: {
                  Marker(
                    markerId: const MarkerId('current'),
                    position: LatLng(lat, long),
                  )
                },
                gestureRecognizers: < Factory < OneSequenceGestureRecognizer >> [
                  new Factory < OneSequenceGestureRecognizer > (
                      () => new EagerGestureRecognizer(),
                  ),
                ].toSet()
            ),
            ),
            Container(
              alignment: Alignment.topRight,
              padding: const EdgeInsets.only(right: 16.0),
              child: FloatingActionButton(
                child: Icon(Icons.location_pin),  
                backgroundColor: Colors.green,  
                foregroundColor: Colors.white,  
                onPressed: () {
                  _getCurrentLocation().then((value){
                    lat = value.latitude;
                    long = value.longitude;
                    setState(() {
                      position = LatLng(lat, long);
                      _center = LatLng(lat, long);
                      print(position);

                      mapController.animateCamera(CameraUpdate.newCameraPosition(
                        CameraPosition(
                          bearing: 0,
                          target: _center,
                          zoom: 17.0,
                        ),
        ));
                    });
                  });
                  
                }, 
              )
            )
        ],
      )
    );
  }
}