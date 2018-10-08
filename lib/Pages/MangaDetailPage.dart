import 'dart:async';
import 'package:flutter/material.dart';
import 'package:manga_reader/Services/BaseService.dart';
import 'package:manga_reader/Services/UrlFormatter.dart';
import 'package:manga_reader/Model/MangaModel.dart';

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
            ? ListView(children: [
                Text(_mangaInfo.title),
                Text("Made by ${_mangaInfo.author ?? "N\A"}"),
                Text(_mangaInfo.description),
                RaisedButton(
                  child: Text("Read"),
                  onPressed: () {},
                )
              ])
            : Center(child: CircularProgressIndicator()));
  }
}
