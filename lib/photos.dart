import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;



Future<String> fetchAlbum() async {
  final response = await http.get('http://bdmoniak.fr/application/list.php');
  if (response.statusCode == 200) {
    var decoded = utf8.decode(response.bodyBytes);

    return decoded;
  } else {
    return "Error";
  }

}

class PhotosPage extends StatefulWidget {
  @override
  _PhotosPageState createState() => _PhotosPageState();
}

class _PhotosPageState extends State<PhotosPage> {
  @override
  Widget build(BuildContext context) => FutureBuilder(
      future: fetchAlbum(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {

          List<String> _photos = snapshot.data.split("\n");
          for (int k = 0; k< _photos.length; k++){
            _photos[k] = "http://bdmoniak.fr/application/galerie/" + _photos[k];
          }
          _photos.removeLast();

          return Container(
              color: Color(0xFFD2DBE0),
              child :GridView.count(
            // Create a grid with 2 columns. If you change the scrollDirection to
            // horizontal, this produces 2 rows.
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            padding: const EdgeInsets.all(8),
            childAspectRatio: 1,
            // Generate 100 widgets that display their index in the List.
            children: _photos.map<Widget>((photo) {
              return _GridPhotoItem( photo: photo);
            }).toList(),
          ));

        }



        else {
          // We can show the loading view until the data comes back.
          debugPrint('Step 1, build loading widget');
          return CircularProgressIndicator();
        }
      },
    );

}


class _GridPhotoItem extends StatelessWidget {


  _GridPhotoItem({ @required this.photo });
  final String photo;



  @override
  Widget build(BuildContext context) {
    final Widget image = Material(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      clipBehavior: Clip.antiAlias,
      child: CachedNetworkImage(
        imageUrl: photo,
      ),
    );

    return image;

  }
}

