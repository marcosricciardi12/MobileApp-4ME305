import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:geolocator/geolocator.dart';

class PreviewPage extends StatefulWidget {
  const PreviewPage({Key? key, required this.picture}) : super(key: key);

  final XFile picture;

  @override
  State<PreviewPage> createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage> {
  late double lat = 0;

  late double long = 0;
  String position = "Latitud: 0  Longitud: 0";
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

  String location() {
    _getCurrentLocation().then((value) {
      lat = value.latitude;
      long = value.longitude;
      setState(() {
        position = "Latitud: $lat  Longitud: $long";
      });
    });
    return position;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preview Page')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.file(File(widget.picture.path),
                fit: BoxFit.cover, width: 250),
            const SizedBox(height: 24),
            Text(widget.picture.name),
            Text(location()),
          ],
        ),
      ),
    );
  }
}
