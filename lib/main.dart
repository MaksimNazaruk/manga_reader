import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:manga_reader/Services/BaseService.dart';
import 'package:manga_reader/Services/UrlFormatter.dart';
import 'package:manga_reader/Model/MangaModel.dart';

void main() => runApp(App());

class App extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AppState();
}

class _AppState extends State<App> {
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
    return MaterialApp(
        title: 'Manga Reader',
        theme: ThemeData(
            brightness: Brightness.dark,
            accentColor: Color(0xFFCDDC39),
            splashColor: Color(0xFFCDDC39),
            scaffoldBackgroundColor: Color(0xFF455A64),
            backgroundColor: Color(0xFF607D8B),
            primaryColor: Color(0xFFA4B02D),
            disabledColor: Color(0xFFBDBDBD)),
        home: Scaffold(
          body: Padding(
              padding: EdgeInsets.all(8.0),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                childAspectRatio: 3.5 / 5.0,
                children: _cells(),
              )),
        ));
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
      return TileCell(
        title: manga.title,
        posterUrl: manga.posterUrl != null
            ? UrlFormatter().image(manga.posterUrl).toString()
            : null,
        onTap: (() {}),
      );
    }).toList();
  }
}

class TileCell extends StatelessWidget {
  final String title;
  final String posterUrl;
  final VoidCallback onTap;

  TileCell({this.title, this.posterUrl, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        AspectRatio(
          aspectRatio: 3.5 / 5.0,
          child: Container(
              color: Theme.of(context).disabledColor,
              child: _posterImage(posterUrl)),
        ),
        Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                  height: 50.0,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment(0.0, 1.0),
                        end: Alignment(0.0, -1.0),
                        colors: <Color>[
                          Theme.of(context).primaryColor.withAlpha(245),
                          Theme.of(context).primaryColor.withAlpha(0)
                        ],
                      ),
                    ),
                  )),
              Container(
                  color: Theme.of(context).primaryColor.withAlpha(245),
                  child: Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Text(
                        title,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ))),
            ]),
        Material(
          color: Colors.transparent,
          child: InkWell(
            splashColor: Theme.of(context).splashColor.withAlpha(128),
            onTap: onTap,
          ),
        )
      ],
    );
  }

  Widget _posterImage(String posterUrl) {
    return posterUrl != null
        ? CachedNetworkImage(
            fit: BoxFit.cover,
            imageUrl: posterUrl,
            placeholder: Center(child: CircularProgressIndicator()),
            errorWidget: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                  Icon(Icons.error, size: 64.0),
                  SizedBox(height: 4.0),
                  Text("Couldn't load poster")
                ])),
          )
        : Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                Icon(Icons.find_in_page, size: 64.0),
                SizedBox(height: 4.0),
                Text("No poster")
              ]));
  }
}
