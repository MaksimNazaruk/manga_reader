import 'dart:async';
import 'package:flutter/material.dart';
import 'package:manga_reader/Services/BaseService.dart';
import 'package:manga_reader/Services/UrlFormatter.dart';
import 'package:manga_reader/Model/MangaModel.dart';
import 'package:manga_reader/Pages/Widgets/PosterCell.dart';

class HomePage extends StatefulWidget {
  @override
    State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
    return Scaffold(
          body: Padding(
              padding: EdgeInsets.all(8.0),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                childAspectRatio: 3.5 / 5.0,
                children: _cells(),
              )),
        );
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
      return PosterCell(
        title: manga.title,
        posterUrl: manga.posterUrl != null
            ? UrlFormatter().image(manga.posterUrl).toString()
            : null,
        onTap: (() {}),
      );
    }).toList();
  }

}