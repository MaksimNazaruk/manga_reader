import 'dart:async';
import 'package:flutter/material.dart';
import 'package:manga_reader/Services/BaseService.dart';
import 'package:manga_reader/Services/UrlFormatter.dart';
import 'package:manga_reader/Model/MangaModel.dart';
import 'package:manga_reader/Pages/ReadingPage.dart';

class MangaDetailPage extends StatefulWidget {
  final String mangaId;

  MangaDetailPage(this.mangaId);

  @override
  State<StatefulWidget> createState() => _MangaDetailPageState();
}

class _MangaDetailPageState extends State<MangaDetailPage> {
  FullMangaInfo _mangaInfo;

  Future<FullMangaInfo> _loadManga() async {
    var requestInfo = RequestInfo.json(
        type: RequestType.get,
        url: UrlFormatter().manga(widget.mangaId).toString());
    var response = await BaseService().performRequest(requestInfo);
    if (response != null) {
      return FullMangaInfo.fromMap(widget.mangaId, response);
    } else {
      return null;
    }
  }

  @override
  void initState() {
    _loadManga().then((mangaInfo) {
      setState(() {
        _mangaInfo = mangaInfo;
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
        body: _mangaInfo != null
            ? ListView(children: _description())
            : Center(child: CircularProgressIndicator()));
  }

  List<Widget> _description() {
    List<Widget> widgets = [
      Text(_mangaInfo.title),
      Text("Made by ${_mangaInfo.author ?? "N\A"}"),
      Text(_mangaInfo.description)
    ];
    widgets.addAll(_mangaInfo.chapters.map((chapter) => RaisedButton(
          color: Theme.of(context).accentColor,
          child: Text("Read chapter ${chapter.number}: ${chapter.title}"),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ReadingPage(chapter.id)));
          },
        )));
    return widgets;
  }
}
