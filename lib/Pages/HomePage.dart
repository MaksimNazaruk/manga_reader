import 'dart:async';
import 'package:flutter/material.dart';
import 'package:manga_reader/Services/BaseService.dart';
import 'package:manga_reader/Services/UrlFormatter.dart';
import 'package:manga_reader/Model/MangaModel.dart';
import 'package:manga_reader/Model/DBProvider.dart';
import 'package:manga_reader/Pages/Widgets/PosterCell.dart';
import 'package:manga_reader/Pages/MangaDetailPage.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<MangaInfo> _mangaList = [];
  String _searchTitle;

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
        body: Column(
          children: [
            Material(
              color: Theme.of(context).backgroundColor,
              elevation: 30.0,
              child: Padding(
                padding: EdgeInsets.fromLTRB(8.0, 0.0, 0.0, 0.0),
                child: Row(
                  children: [
                    Icon(Icons.search),
                    Expanded(
                      child: TextField(
                        onChanged: (newSearchValue) {
                          _searchTitle = newSearchValue;
                        },
                        onSubmitted: (_) {
                          _performSearch();
                        },
                      ),
                    ),
                    FlatButton(
                      child: Text("Search"),
                      onPressed: () {
                        _performSearch();
                      },
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                padding: EdgeInsets.all(8.0),
                childAspectRatio: 3.5 / 5.0,
                children: _cells(),
              ),
            ),
          ],
        ));
  }

  Future<List<MangaInfo>> _loadList() async {
    List<MangaInfo> mangas = await DBProvider.dbManager.fetchAll(
        MangaInfoDescription(),
        ordering: "isFavourite DESC, hits DESC");

    if (mangas == null || mangas.isEmpty) {
      var requestInfo = RequestInfo.json(
          type: RequestType.get, url: UrlFormatter().list().toString());
      var response = await BaseService().performRequest(requestInfo);
      mangas = (response["manga"] as List)
          .map((mangaMap) => MangaInfo.fromShortMap(mangaMap))
          .toList();
      await DBProvider.dbManager
          .insertBatch(description: MangaInfoDescription(), entities: mangas);
    }

    return mangas;
  }

  void _performSearch() {
    if (_searchTitle?.isNotEmpty ?? false) {
      DBProvider.dbManager
          .fetchWithPredicate(MangaInfoDescription(),
              "title LIKE '%$_searchTitle%' COLLATE NOCASE")
          .then((searchResultList) {
        setState(() {
          _mangaList = searchResultList;
        });
      });
    } else {
      DBProvider.dbManager
          .fetchAll(MangaInfoDescription(),
              ordering: "isFavourite DESC, hits DESC")
          .then((allMangas) {
        setState(() {
          _mangaList = allMangas;
        });
      });
    }
  }

  List<Widget> _cells() {
    return _mangaList.map((manga) {
      return PosterCell(
          title: manga.title,
          posterUrl: manga.posterUrl != null
              ? UrlFormatter().image(manga.posterUrl).toString()
              : null,
          hits: manga.hits,
          onTap: (() {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => MangaDetailPage(manga.id)));
          }));
    }).toList();
  }
}
