import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';
import 'utility.dart';
import 'DBHelper.dart';
import 'Photo.dart';
import 'dart:async';
import 'pictures_page.dart';
import 'myhomepage.dart';

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
  var dbHelper = DBHelper();

  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String position = "Latitud: 0  Longitud: 0";

  saveImage() {
    widget.picture.readAsBytes().then((value) {
      setState(() {
        String imgString = Utility.base64String(value);
        Photo photo = Photo(
            id: 0,
            photoName: imgString,
            lat: lat,
            long: long,
            date: DateTime.now().toString(),
            userNotes: _controller.text);
        print(dbHelper.save(photo).toString());
      });
    });
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
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        reverse: true,
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
                    final multiPartText = await MultipartFile.fromString(
                        "Location: Lat=>$lat  Lon=>$long");
                    FormData formData = FormData.fromMap({
                      "image": multiPartFile,
                      "location": multiPartText,
                    });
                    final response = await dio.post(
                      "http://190.15.198.27:5000/tw/upload",
                      data: formData,
                    );
                    print(response.data['url'].toString());
                    var urlAuth = Uri.parse(response.data['url'].toString());
                    if (!await launchUrl(urlAuth)) {
                      throw Exception('Could not launch $urlAuth');
                    }
                  },
                )),
            Container(
              padding: const EdgeInsets.all(16),
              child: TextField(
                obscureText: false,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.note_alt_outlined),
                  border: OutlineInputBorder(),
                  labelText: 'User Note',
                ),
                controller: _controller,
                onSubmitted: (String value) async {
                  await showDialog<void>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Thanks!'),
                        content: Text(
                            'You typed "$value", which has length ${value.characters.length}.'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.all(16),
                child: FloatingActionButton(
                  child: Icon(Icons.save_as_rounded),
                  backgroundColor: Color.fromARGB(255, 26, 139, 214),
                  foregroundColor: Colors.white,
                  onPressed: () async {
                    saveImage();
                    await showDialog<void>(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Thanks!'),
                          content: Text('Your image was saved!'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                )),
            Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom))
          ],
        ),
      ),
    );
  }
}
