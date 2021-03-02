import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:photo_view/photo_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:google_fonts/google_fonts.dart';

class News {
  final int id;
  final String titre;
  final DateTime date;
  final String content;
  final String images;

  News({this.id, this.titre, this.date, this.content, this.images});

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      id: int.parse(json['ID']),
      titre: json['titre'] as String,
      date: DateTime.parse(json['date']),
      content: json['contenu'] as String,
      images: json['images'] as String,
    );
  }
}

List<News> parseNews(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

  return parsed.map<News>((json) => News.fromJson(json)).toList();
}

_lastNews(int id) async {
  final prefs = await SharedPreferences.getInstance();
  //print('Last news: $id .');
  await prefs.setInt('lastNewsId', id);
}


Future<List<News>> fetchNews(http.Client client) async {
  final response =
      await client.get('http://bdmoniak.fr/application/produits/lire_news.php');
  var mesNews = await compute(parseNews, response.body);

  _lastNews(mesNews[0].id);
  client.close();
  return mesNews;
}



class HomePage extends StatelessWidget {
  HomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<News>>(
        future: fetchNews(http.Client()),
        builder: (context, snapshot) {
          if (snapshot.hasError) print(snapshot.error);

          return snapshot.hasData
              ? NewsList(news: snapshot.data)
              : Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class NewsList extends StatelessWidget {
  final List<News> news;

  NewsList({Key key, this.news}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    news.add(News(
        id: 0,
        titre: "Mentions légales",
        content: "En utilisant cette application, vous acceptez que ce qui y est publié n'est "
            "pas de la responsabilité de ses développeurs.",
        date: DateTime.parse("2020-12-01 12:00:00"),
        images: ""));
    return Container(
      color: ReplyColors.blue100,
      child: ListView.separated(
          itemCount: news.length,
          padding: const EdgeInsets.all(8),
          separatorBuilder: (BuildContext context, int index) => Divider(),
          itemBuilder: (context, index) {
            return Container(
                color: ReplyColors.white50,
                child: _NewsView(id: index, news: news[index]));
          }),
    );
  }
}

class _NewsView extends StatelessWidget {
  const _NewsView({
    @required this.id,
    @required this.news,
  })  : assert(id != null),
        assert(news != null);

  final int id;
  final News news;

  @override
  Widget build(BuildContext context) {
    final textTheme = _buildLightTextTheme(Theme.of(context).textTheme);

    return InkWell(
      child: Builder(
        builder: (context) {
          return ConstrainedBox(
            constraints: BoxConstraints(minHeight: 80),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text((() {
                              if (news.date.minute == 0){
                                return 'Le ${news.date.day}/${news.date.month} à ${news.date.hour}h ';
                              }
                              else if (news.date.minute < 10){
                                return 'Le ${news.date.day}/${news.date.month} à ${news.date.hour}h0${news.date.minute} ';
                              }
                              else{
                                return 'Le ${news.date.day}/${news.date.month} à ${news.date.hour}h${news.date.minute} ';
                              }
                            }()),
                              style: textTheme.caption,
                            ),
                            const SizedBox(height: 4),
                            Text(news.titre, style: textTheme.headline5),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                      end: 20,
                    ),
                    child: Text(
                      news.content,
                      style: textTheme.bodyText2,
                    ),
                  ),
                  if (news.images.length != 0) ...[
                    Flexible(
                      fit: FlexFit.loose,
                      child: Column(
                        children: [
                          SizedBox(height: 20),
                          PicturePreview(url: news.images),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class PicturePreview extends StatelessWidget {
  final String url;
  const PicturePreview({
    this.url,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) {
              return FullScreenImage(
                imageUrl:
                url,
                tag: url,
              );
            }));
      },
      child: Hero(
        child: SizedBox(
          height: 250,
          child: Padding(
            padding: const EdgeInsetsDirectional.only(end: 4),
            child: Center(child: CachedNetworkImage(
              imageUrl: url,
            ))
          ),
        ),
        tag: url,
      ),
    );

  }
}


class FullScreenImage extends StatelessWidget {
  final String imageUrl;
  final String tag;

  const FullScreenImage({Key key, this.imageUrl, this.tag}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: GestureDetector(
        child: Center(
          child: Hero(
            tag: tag,
            child: Container(
                child: PhotoView(
                  imageProvider: CachedNetworkImageProvider(imageUrl),
                  minScale: PhotoViewComputedScale.contained ,
                  maxScale: PhotoViewComputedScale.covered * 5,
                )
            ),
          ),
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}


double letterSpacingOrNone(double letterSpacing) =>
    kIsWeb ? 0.0 : letterSpacing;

class ReplyColors {
  static const Color white50 = Color(0xFFFFFFFF);

  static const Color black800 = Color(0xFF121212);
  static const Color black900 = Color(0xFF000000);

  static const Color blue50 = Color(0xFFEEF0F2);
  static const Color blue100 = Color(0xFFD2DBE0);
  static const Color blue200 = Color(0xFFADBBC4);
  static const Color blue300 = Color(0xFF8CA2AE);
  static const Color blue600 = Color(0xFF4A6572);
  static const Color blue700 = Color(0xFF344955);
  static const Color blue800 = Color(0xFF232F34);

  static const Color white50Alpha060 = Color(0x99FFFFFF);

  static const Color blue50Alpha060 = Color(0x99EEF0F2);

  static const Color black900Alpha020 = Color(0x33000000);
  static const Color black900Alpha087 = Color(0xDE000000);
  static const Color black900Alpha060 = Color(0x99000000);

  static const Color greyLabel = Color(0xFFAEAEAE);
  static const Color darkBottomAppBarBackground = Color(0xFF2D2D2D);
  static const Color darkDrawerBackground = Color(0xFF353535);
  static const Color darkCardBackground = Color(0xFF1E1E1E);
  static const Color darkChipBackground = Color(0xFF2A2A2A);
  static const Color lightChipBackground = Color(0xFFE5E5E5);
}

TextTheme _buildLightTextTheme(TextTheme base) {
  return base.copyWith(
    headline4: GoogleFonts.workSans(
      fontWeight: FontWeight.w600,
      fontSize: 34,
      letterSpacing: letterSpacingOrNone(0.4),
      height: 0.9,
      color: ReplyColors.black900,
    ),
    headline5: GoogleFonts.workSans(
      fontWeight: FontWeight.bold,
      fontSize: 24,
      letterSpacing: letterSpacingOrNone(0.27),
      color: ReplyColors.black900,
    ),
    headline6: GoogleFonts.workSans(
      fontWeight: FontWeight.w600,
      fontSize: 20,
      letterSpacing: letterSpacingOrNone(0.18),
      color: ReplyColors.black900,
    ),
    subtitle2: GoogleFonts.workSans(
      fontWeight: FontWeight.w600,
      fontSize: 14,
      letterSpacing: letterSpacingOrNone(-0.04),
      color: ReplyColors.black900,
    ),
    bodyText1: GoogleFonts.workSans(
      fontWeight: FontWeight.normal,
      fontSize: 18,
      letterSpacing: letterSpacingOrNone(0.2),
      color: ReplyColors.black900,
    ),
    bodyText2: GoogleFonts.workSans(
      fontWeight: FontWeight.normal,
      fontSize: 14,
      letterSpacing: letterSpacingOrNone(-0.05),
      color: ReplyColors.black900,
    ),
    caption: GoogleFonts.workSans(
      fontWeight: FontWeight.normal,
      fontSize: 12,
      letterSpacing: letterSpacingOrNone(0.2),
      color: ReplyColors.black900,
    ),
  );
}
