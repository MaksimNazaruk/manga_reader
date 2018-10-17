import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PosterCell extends StatelessWidget {
  final String title;
  final String posterUrl;
  final bool isFavourite;
  final VoidCallback onTap;

  PosterCell({this.title, this.posterUrl, this.isFavourite, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(8.0),
      clipBehavior: Clip.antiAlias,
      elevation: 3.0,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          AspectRatio(
            aspectRatio: 3.5 / 5.0,
            child: Container(
                color: Theme.of(context).disabledColor,
                child: _posterImage(posterUrl)),
          ),
          Column(
              // mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                    height: 25.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: _statusIcons,
                    )),
                Expanded(child: Material(color: Colors.transparent)),
                SizedBox(
                    height: 50.0,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment(0.0, 1.0),
                          end: Alignment(0.0, -1.0),
                          colors: <Color>[
                            Theme.of(context).backgroundColor.withAlpha(245),
                            Theme.of(context).backgroundColor.withAlpha(0)
                          ],
                        ),
                      ),
                    )),
                Container(
                    color: Theme.of(context).backgroundColor.withAlpha(245),
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
      ),
    );
  }

  List<Widget> get _statusIcons {
    double iconSize = 22.0;
    List<Widget> icons = [];
    if (isFavourite) {
      icons.add(Icon(Icons.star, size: iconSize));
    }
    return icons;
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
                  Icon(Icons.error, size: 32.0),
                  SizedBox(height: 4.0),
                  Text(
                    "Couldn't load poster",
                    textAlign: TextAlign.center,
                  )
                ])),
          )
        : Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.find_in_page, size: 32.0),
            SizedBox(height: 4.0),
            Text(
              "No poster",
              textAlign: TextAlign.center,
            )
          ]));
  }
}
