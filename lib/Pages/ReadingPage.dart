import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:manga_reader/Services/BaseService.dart';
import 'package:manga_reader/Services/UrlFormatter.dart';
import 'package:manga_reader/Model/MangaModel.dart';
import 'package:manga_reader/Model/DBProvider.dart';
import 'package:manga_reader/Services/CachedImageLoader.dart';
import 'package:manga_reader/Pages/Widgets/LoadingImage.dart';

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
    SystemChrome.setEnabledSystemUIOverlays([]);
    super.initState();
  }

  @override
    void dispose() {
      SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
      super.dispose();
    }

  void _loadData() async {
    setState(() {
      _images = null;
    });
    var images = await _loadChapter();
    var nextChapterId = await _getNextChapterId();
    if (mounted) {
      setState(() {
        _images = images;
        _nextChapterId = nextChapterId;
        _updateLastReadDate();
      });
    }
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
    return nextChapters.first?.id;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _images != null
          ? ListView.builder(
              controller: _scrollController,
              itemBuilder: (context, index) =>
                  index < _images.length ? _page(index) : _nextChapterButton(),
              itemCount: _images.length + 1) // +1 for the 'Next chapter' button
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  Widget _nextChapterButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      child: RaisedButton(
        child: Text("Next chapter"),
        onPressed: () {
          _currentChapterId = _nextChapterId;
          _scrollController.jumpTo(0.0);
          _loadData();
        },
      ),
    );
  }

  Widget _page(int index) {
    var imageInfo = _images[index];
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0),
      child: AspectRatio(
        aspectRatio: imageInfo.width / imageInfo.height,
        child: _pageImage(
          UrlFormatter().image(imageInfo.url).toString(),
        ),
      ),
    );
  }

  Widget _pageImage(String imageUrl) {
    return imageUrl != null
        ? LoadingImage(
            fit: BoxFit.cover,
            imageData:
                CachedImageLoader.loader.loadImage(fullImageUrl: imageUrl),
            loadingIndicator: Center(child: CircularProgressIndicator()),
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
