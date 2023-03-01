import 'package:flutter/material.dart';
import 'dart:io' as io;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'utility.dart';
import 'DBHelper.dart';
import 'Photo.dart';
import 'dart:async';

class PicturesPage extends StatefulWidget {
  const PicturesPage({super.key});

  @override
  State<PicturesPage> createState() => _PicturesPageState();
}

class _PicturesPageState extends State<PicturesPage> {
  late DBHelper dbHelper;
  late List<Photo> images;

  @override
  void initState() {
    super.initState();
    images = [];
    dbHelper = DBHelper();
    refreshImages();
  }

  gridView() {
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: GridView.count(
        crossAxisCount: 1,
        childAspectRatio: 1.0,
        mainAxisSpacing: 4.0,
        crossAxisSpacing: 4.0,
        children: images.map((photo) {
          return Utility.imageFromBase64String(photo.photoName);
        }).toList(),
      ),
    );
  }

  refreshImages() {
    dbHelper.getPhotos().then((imgs) {
      setState(() {
        images.clear();
        images.addAll(imgs);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Show saved pictures"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            _buildPhotoList(images),
          ],
        ),
      ),
    );
  }
}

Widget _buildPhotoList(List<Photo> photoList) {
  return Expanded(
    child: ListView.builder(
      padding: EdgeInsets.all(10.0),
      itemCount: photoList.length,
      itemBuilder: (BuildContext context, int index) {
        return Row(
          children: <Widget>[
            Expanded(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.all(10),
                          child: Utility.imageFromBase64String(
                              photoList[index].photoName),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Lat:'),
                        Text(photoList[index].lat.toString()),
                        Text("\n"),
                        Text('Long:'),
                        Text(photoList[index].lat.toString()),
                        Text("\n"),
                        Text('Date:'),
                        Text(photoList[index].date),
                        Text("\n"),
                        Text('User Notes:'),
                        Text(photoList[index].userNotes),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        );
      },
    ),
  );
}
