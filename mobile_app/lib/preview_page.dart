import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';

class PreviewPage extends StatefulWidget {
  const PreviewPage({Key? key, required this.picture}) : super(key: key);

  final XFile picture;

  @override
  State<PreviewPage> createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage> {
  late double lat = 0;
  late bool flag = true;
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
    if (flag) {
      flag = false;
      _getCurrentLocation().then((value) {
        lat = value.latitude;
        long = value.longitude;
        setState(() {
          position = "Latitud: $lat  Longitud: $long";
        });
      });
    }

    return position;
  }

  Future uploadRequest(String url, String filePath) async {
    final dio = Dio();
    dio.options.contentType = "multipart/form-data";
    final multiPartFile = await MultipartFile.fromFile(
      filePath,
      filename: filePath.split('/').last,
    );
    FormData formData = FormData.fromMap({
      "file": multiPartFile,
    });
    final response = await dio.post(
      url,
      data: formData,
    );
    return response.data;
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
            Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(16),
                child: FloatingActionButton(
                  child: Icon(Icons.upload_file_rounded),
                  backgroundColor: Color.fromARGB(255, 26, 139, 214),
                  foregroundColor: Colors.white,
                  onPressed: () async {
                    final dio = Dio();
                    dio.options.contentType = "multipart/form-data";
                    final multiPartFile = await MultipartFile.fromFile(
                      widget.picture.path,
                      filename: widget.picture.name,
                    );
                    FormData formData = FormData.fromMap({
                      "image": multiPartFile,
                      "location": "que te calienta donde estoy",
                    });
                    final response = await dio.post(
                      "http://190.15.198.27:5000/tw/upload",
                      data: formData,
                    );
                  },
                ))
          ],
        ),
      ),
    );
  }
}
