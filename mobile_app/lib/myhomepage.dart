import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:mobile_app/camera_page.dart';
import 'package:camera/camera.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late double lat = 0;
  late double long = 0;
  late LatLng position = LatLng(lat, long);
  late GoogleMapController mapController;
  late LatLng _center = LatLng(-32.888153965240924, -68.86453057731511);
  late Future<LoginData> futureloginData;

  Future<LoginData> logintw() async {
    final response =
        await http.get(Uri.parse('http://190.15.198.27:5000/tw/auth'));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return LoginData.fromJson(jsonDecode(response.body));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load album');
    }
  }

  Future<void> _launchUrl() async {
    futureloginData = logintw();
    Uri urlAuth;
    futureloginData.then((value) {
      setState(() async {
        urlAuth = Uri.parse(value.url);
        if (!await launchUrl(urlAuth)) {
          throw Exception('Could not launch $urlAuth');
        }
      });
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
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
                )),
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
                  gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
                    new Factory<OneSequenceGestureRecognizer>(
                      () => new EagerGestureRecognizer(),
                    ),
                  ].toSet()),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Container(
                    alignment: Alignment.topLeft,
                    padding: const EdgeInsets.only(left: 16.0),
                    child: FloatingActionButton(
                      child: Icon(Icons.camera_outlined),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      onPressed: () async {
                        await availableCameras().then((value) => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => CameraPage(cameras: value))));
                      },
                    )),
                Container(
                    alignment: Alignment.topRight,
                    padding: const EdgeInsets.only(right: 16.0),
                    child: FloatingActionButton(
                      child: Icon(Icons.location_pin),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      onPressed: () {
                        _getCurrentLocation().then((value) {
                          lat = value.latitude;
                          long = value.longitude;
                          setState(() {
                            position = LatLng(lat, long);
                            _center = LatLng(lat, long);
                            print(position);

                            mapController
                                .animateCamera(CameraUpdate.newCameraPosition(
                              CameraPosition(
                                bearing: 0,
                                target: _center,
                                zoom: 17.0,
                              ),
                            ));
                          });
                        });
                      },
                    )),
              ],
            ),
            Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(16),
                child: FloatingActionButton(
                  child: Icon(Icons.login),
                  backgroundColor: Color.fromARGB(255, 26, 139, 214),
                  foregroundColor: Colors.white,
                  onPressed: _launchUrl,
                )),
          ],
        ));
  }
}

class LoginData {
  final String message;
  final String url;

  const LoginData({
    required this.message,
    required this.url,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      message: json['message'],
      url: json['url'],
    );
  }
}
