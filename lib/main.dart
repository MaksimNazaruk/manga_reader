import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:manga_reader/Services/BaseService.dart';
import 'package:manga_reader/Services/UrlFormatter.dart';
import 'package:manga_reader/Model/MangaModel.dart';

void main() => runApp(App());

class App extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AppState();
}

class _AppState extends State<App> {
  List<Manga> _mangaList = [];

  @override
  void initState() {
    _loadList().then((mangas) {
      setState(() {
        _mangaList = mangas;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Manga Reader',
        theme: ThemeData(
            brightness: Brightness.dark,
            accentColor: Color(0xFFCDDC39),
            disabledColor: Color(0xFF607D8B),
            scaffoldBackgroundColor: Color(0xFF455A64)),
        home: Scaffold(
          body: GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 3.0 / 5.0,
            children: _cells(),
          ),
        ));
  }

  Future<List<Manga>> _loadList() async {
    var requestInfo = RequestInfo.json(
        type: RequestType.get, url: UrlFormatter().listPage(0).toString());
    var response = await BaseService().performRequest(requestInfo);
    List<Manga> mangas = (response["manga"] as List)
        .map((mangaMap) => Manga.fromShortMap(mangaMap))
        .toList();

    return mangas;
  }

  List<Widget> _cells() {
    return _mangaList.map((manga) {
      return TileCell(
        title: manga.title,
        posterUrl: manga.posterUrl != null
            ? UrlFormatter().image(manga.posterUrl).toString()
            : null,
        onTap: (() {}),
      );
    }).toList();
  }
}

class TileCell extends StatelessWidget {
  final String title;
  final String posterUrl;
  final VoidCallback onTap;

  TileCell({this.title, this.posterUrl, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AspectRatio(
            aspectRatio: 3.5 / 5.0,
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(4.0)),
              child: Container(
                  color: Theme.of(context).disabledColor,
                  child: posterUrl != null
                      ? CachedNetworkImage(
                          fit: BoxFit.cover,
                          imageUrl: posterUrl,
                          placeholder:
                              Center(child: CircularProgressIndicator()),
                          errorWidget: Center(child: Icon(Icons.error)),
                        )
                      : Center(child: Icon(Icons.find_in_page, size: 64.0,))),
            ),
          ),
          SizedBox(
            height: 4.0,
          ),
          Text(
            title,
            maxLines: 2,
            textAlign: TextAlign.start,
            overflow: TextOverflow.ellipsis,
          )
        ],
      ),
    );
  }
}
