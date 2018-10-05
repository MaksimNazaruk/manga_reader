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
  List<Widget> _cells = [];

  @override
  void initState() {
    _loadList().then((cells) {
      setState(() {
        _cells = cells;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.teal,
          accentColor: Colors.tealAccent,
        ),
        home: Scaffold(
          body: GridView.count(
            crossAxisCount: 2,
            children: _cells,
          ),
        ));
  }

  Future<List<Widget>> _loadList() async {
    var requestInfo = RequestInfo.json(
        type: RequestType.get, url: UrlFormatter().listPage(0).toString());
    var response = await BaseService().performRequest(requestInfo);
    List<Manga> mangas = (response["manga"] as List)
        .map((mangaMap) => Manga.fromShortMap(mangaMap))
        .toList();
    var cells = mangas.map((manga) {
      return Padding(
          padding: EdgeInsets.all(4.0),
          child: Column(
            children: <Widget>[
              AspectRatio(
                  aspectRatio: 5.0 / 3.0,
                  child: Container(
                      child: manga.posterUrl != null
                          ? CachedNetworkImage(
                              imageUrl: UrlFormatter()
                                  .image(manga.posterUrl)
                                  .toString(),
                              placeholder:
                                  Center(child: CircularProgressIndicator()),
                              errorWidget: Center(child: Icon(Icons.error)),
                            )
                          : Center(child: Icon(Icons.find_in_page)))),
              Text(
                manga.title,
                maxLines: 2,
              )
            ],
          ));
    }).toList();

    return cells;
  }
}
