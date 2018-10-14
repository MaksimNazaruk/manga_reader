import 'dart:async';
import 'package:flutter/material.dart';
import 'package:manga_reader/Services/BaseService.dart';
import 'package:manga_reader/Services/UrlFormatter.dart';
import 'package:manga_reader/Model/DBProvider.dart';
import 'package:manga_reader/Model/MangaModel.dart';
import 'package:manga_reader/Pages/ReadingPage.dart';
import 'package:manga_reader/Strings.dart';

class MangaDetailPage extends StatefulWidget {
  final String mangaId;

  MangaDetailPage(this.mangaId);

  @override
  State<StatefulWidget> createState() => _MangaDetailPageState();
}

class _MangaDetailPageState extends State<MangaDetailPage> {
  MangaInfo _mangaInfo;
  List<ChapterInfo> _chapters;

  Future<MangaInfo> _loadManga() async {
    var fetchResult = await DBProvider.dbManager.fetchWithPredicate(
        MangaInfoDescription(),
        "id = '${widget.mangaId}' AND fullInfoLoaded = 1");
    MangaInfo manga = fetchResult.isNotEmpty ? fetchResult.first : null;
    if (manga == null) {
      var requestInfo = RequestInfo.json(
          type: RequestType.get,
          url: UrlFormatter().manga(widget.mangaId).toString());
      var response = await BaseService().performRequest(requestInfo);
      if (response != null) {
        manga = MangaInfo.fromFullMap(widget.mangaId, response);
        await DBProvider.dbManager
            .insert(description: MangaInfoDescription(), entity: manga);
      }
    }

    return manga;
  }

  @override
  void initState() {
    _loadManga().then((mangaInfo) {
      mangaInfo.chapters.then((chapters) {
        setState(() {
          _mangaInfo = mangaInfo;
          _chapters = chapters;
        });
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_mangaInfo?.title ?? "Loading..."),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.0),
        child: _mangaInfo != null
            ? ListView(children: _description(context))
            : Center(child: CircularProgressIndicator()),
      ),
    );
  }

  List<Widget> _description(BuildContext context) {
    List<Widget> widgets = [
      Padding(
          padding: EdgeInsets.symmetric(vertical: 10.0),
          child: Text(
            _mangaInfo.title,
            style: Theme.of(context).textTheme.title,
          )),
      Padding(
          padding: EdgeInsets.symmetric(vertical: 10.0),
          child: Text("Author:\n${_mangaInfo.author ?? "N\A"}")),
      Padding(
          padding: EdgeInsets.symmetric(vertical: 10.0),
          child: Text("Categories:\n${_mangaInfo.categories.join(", ")}")),
      Padding(
          padding: EdgeInsets.symmetric(vertical: 10.0),
          child: Text("Description:\n${_mangaInfo.description}"))
    ];

    widgets.addAll(_chapters
        .map((chapter) => RaisedButton(
              color: Theme.of(context).accentColor,
              child: Text(
                  "Chapter ${chapter.number.toStringAsFixed(chapter.number.truncateToDouble() == chapter.number ? 0 : 2)}: ${chapter.title}"),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ReadingPage(chapter.id)));
              },
            ))
        .toList());

    return widgets;
  }
}
