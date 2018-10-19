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
  String _nextChapterId;
  String _currentChapterId;
  ScrollController _scrollController = ScrollController();

  Future<List<MangaImageInfo>> _loadChapter() async {
    List<MangaImageInfo> images = await DBProvider.dbManager.fetchWithPredicate(
        MangaImageInfoDescription(), "chapterId = '$_currentChapterId'");
    if (images.isEmpty) {
      var requestInfo = RequestInfo.json(
          type: RequestType.get,
          url: UrlFormatter().chapter(_currentChapterId).toString());
      var response = await BaseService().performRequest(requestInfo);
      images = (response["images"] as List)
          .reversed
          .map((imageArray) =>
              MangaImageInfo.fromArray(_currentChapterId, imageArray))
          .toList();
      await DBProvider.dbManager.insertBatch(
          description: MangaImageInfoDescription(), entities: images);
    }

    return images;
  }

  @override
  void initState() {
    _currentChapterId = widget.chapterId;
    _loadData();
    super.initState();
  }

  void _loadData() async {
    setState(() {
      _images = null;
    });
    var images = await _loadChapter();
    var nextChapterId = await _getNextChapterId();
    setState(() {
      _images = images;
      _nextChapterId = nextChapterId;
      _updateLastReadDate();
    });
  }

  void _updateLastReadDate() async {
    ChapterInfo chapterInfo = await DBProvider.dbManager
        .fetchByKey(ChapterInfoDescription(), _currentChapterId);
    chapterInfo.lastReadDate = DateTime.now().millisecondsSinceEpoch;
    DBProvider.dbManager
        .insert(description: ChapterInfoDescription(), entity: chapterInfo);
  }

  Future<String> _getNextChapterId() async {
    var currentChapter = await DBProvider.dbManager
        .fetchByKey(ChapterInfoDescription(), _currentChapterId);
    var nextChapters = await DBProvider.dbManager.fetchWithPredicate(
        ChapterInfoDescription(),
        "mangaId = '${currentChapter.mangaId}' AND number > ${currentChapter.number}",
        ordering: "number ASC");
    return nextChapters.first.id;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [];
    if (_images != null) {
      var images = _imagesList();
      widgets.addAll(images);
    }
    widgets.add(Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.0),
        child: RaisedButton(
          child: Text("Next chapter"),
          onPressed: () {
            _currentChapterId = _nextChapterId;
            _scrollController.jumpTo(0.0);
            _loadData();
          },
        )));
    return Scaffold(
        body: _images != null
            ? ListView(
                children: widgets,
                controller: _scrollController,
              )
            : Center(child: CircularProgressIndicator()));
  }

  List<Widget> _imagesList() {
    return _images
        .map((imageInfo) => AspectRatio(
            aspectRatio: imageInfo.width / imageInfo.height,
            child: _pageImage(UrlFormatter().image(imageInfo.url).toString())))
        .toList()
        .cast<Widget>();
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
