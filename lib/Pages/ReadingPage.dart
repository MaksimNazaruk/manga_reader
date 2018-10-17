import 'dart:async';
import 'package:flutter/material.dart';
import 'package:manga_reader/Services/BaseService.dart';
import 'package:manga_reader/Services/UrlFormatter.dart';
import 'package:manga_reader/Model/MangaModel.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:manga_reader/Model/DBProvider.dart';

class ReadingPage extends StatefulWidget {
  final String chapterId;

  ReadingPage(this.chapterId);

  @override
  State<StatefulWidget> createState() => _ReadingPageState();
}

class _ReadingPageState extends State<ReadingPage> {
  List<MangaImageInfo> _images;

  Future<List<MangaImageInfo>> _loadChapter() async {
    List<MangaImageInfo> images = await DBProvider.dbManager.fetchWithPredicate(
        MangaImageInfoDescription(), "chapterId = '${widget.chapterId}'");
    if (images.isEmpty) {
      var requestInfo = RequestInfo.json(
          type: RequestType.get,
          url: UrlFormatter().chapter(widget.chapterId).toString());
      var response = await BaseService().performRequest(requestInfo);
      images = (response["images"] as List)
          .reversed
          .map((imageArray) =>
              MangaImageInfo.fromArray(widget.chapterId, imageArray))
          .toList();
      await DBProvider.dbManager.insertBatch(
          description: MangaImageInfoDescription(), entities: images);
    }

    return images;
  }

  @override
  void initState() {
    _loadChapter().then((images) {
      setState(() {
        _images = images;
        _updateLastReadDate();
      });
    });
    super.initState();
  }

  void _updateLastReadDate() async {
    ChapterInfo chapterInfo = await DBProvider.dbManager
        .fetchByKey(ChapterInfoDescription(), widget.chapterId);
    chapterInfo.lastReadDate = DateTime.now().millisecondsSinceEpoch;
    DBProvider.dbManager
        .insert(description: ChapterInfoDescription(), entity: chapterInfo);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: _images != null
            ? ListView(children: _imagesList())
            : Center(child: CircularProgressIndicator()));
  }

  List<Widget> _imagesList() {
    return _images
        .map((imageInfo) => AspectRatio(
            aspectRatio: imageInfo.width / imageInfo.height,
            child: _pageImage(UrlFormatter().image(imageInfo.url).toString())))
        .toList();
  }

  Widget _pageImage(String imageUrl) {
    return imageUrl != null
        ? CachedNetworkImage(
            fit: BoxFit.cover,
            imageUrl: imageUrl,
            placeholder: Center(child: CircularProgressIndicator()),
            errorWidget: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                  Icon(Icons.error, size: 64.0),
                  SizedBox(height: 4.0),
                  Text("Couldn't load page T__T")
                ])),
          )
        : Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.find_in_page, size: 64.0),
            SizedBox(height: 4.0),
            Text("No page? o_O")
          ]));
  }
}
