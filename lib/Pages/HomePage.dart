import 'dart:async';
import 'package:flutter/material.dart';
import 'package:manga_reader/Services/BaseService.dart';
import 'package:manga_reader/Services/UrlFormatter.dart';
import 'package:manga_reader/Model/MangaModel.dart';
import 'package:manga_reader/Pages/Widgets/PosterCell.dart';
import 'package:manga_reader/Pages/MangaDetailPage.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<ShortMangaInfo> _mangaList = [];

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
      appBar: AppBar(
        title: Text("Manga List"),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        padding: EdgeInsets.all(8.0),
        childAspectRatio: 3.5 / 5.0,
        children: _cells(),
      ),
    );
  }

  Future<List<ShortMangaInfo>> _loadList() async {
    var requestInfo = RequestInfo.json(
        type: RequestType.get, url: UrlFormatter().listPage(0).toString());
    var response = await BaseService().performRequest(requestInfo);
    List<ShortMangaInfo> mangas = (response["manga"] as List)
        .map((mangaMap) => ShortMangaInfo.fromMap(mangaMap))
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
          onTap: (() {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => MangaDetailPage(manga.id)));
          }));
    }).toList();
  }
}
