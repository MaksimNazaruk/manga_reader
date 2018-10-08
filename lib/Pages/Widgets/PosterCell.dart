import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PosterCell extends StatelessWidget {
  final String title;
  final String posterUrl;
  final int hits;
  final VoidCallback onTap;

  PosterCell({this.title, this.posterUrl, this.hits, this.onTap});

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
        Banner(message: "$hits", location: BannerLocation.topEnd,),
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
