import 'package:flutter/material.dart';
import 'package:manga_reader/Model/MangaModel.dart';

class MangaDetailPage extends StatefulWidget {
  final Manga manga;

  MangaDetailPage(this.manga);

  @override
  State<StatefulWidget> createState() => _MangaDetailPageState();
}

class _MangaDetailPageState extends State<MangaDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.manga.title),
      ),
      body: Center(child: Text(widget.manga.title)),
    );
  }
}
