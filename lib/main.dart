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
          primarySwatch: Colors.blue,
        ),
        home: Scaffold(
          body: ListView(
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
      return Row(
        children: <Widget>[
          SizedBox(
              height: 70.0,
              width: 50.0,
              child: CachedNetworkImage(
                imageUrl: UrlFormatter().image(manga.posterUrl).toString(),
                placeholder: Center(child: CircularProgressIndicator()),
                errorWidget: Center(child: Icon(Icons.error)),
              )),
          Expanded(child: Text(manga.title))
        ],
      );
    }).toList();

    return cells;
  }
}
