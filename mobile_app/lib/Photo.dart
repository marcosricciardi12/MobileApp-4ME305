import 'dart:ffi';

class Photo {
  late int id;
  late String photoName;
  late double lat;
  late double long;
  late String date = DateTime.now().toString();
  late String userNotes;

  Photo({
    required this.id,
    required this.photoName,
    required this.lat,
    required this.long,
    required this.date,
    required this.userNotes,
  });

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'photoName': photoName,
      'lat': lat,
      'long': long,
      'date': date,
      'userNotes': userNotes,
    };
    return map;
  }

  Photo.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    photoName = map['photoName'];
    lat = map['lat'];
    long = map['long'];
    date = map['date'];
    userNotes = map['userNotes'];
  }
}
