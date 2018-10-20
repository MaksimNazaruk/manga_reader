import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';

class LoadingImage extends StatefulWidget {
  final Future<Uint8List> imageData;
  final Widget loadingIndicator;
  final BoxFit fit;
  LoadingImage(
      {this.imageData, this.loadingIndicator, this.fit = BoxFit.contain});

  @override
  State<StatefulWidget> createState() => _LoadingImageState();
}

class _LoadingImageState extends State<LoadingImage> {
  Uint8List _loadedImageData;

  @override
  void initState() {
    _loadImage();
    super.initState();
  }

  void _loadImage() async {
    var data = await widget.imageData;
    if (mounted) {
      setState(() {
        _loadedImageData = data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      firstChild:
          _loadedImageData != null ? Container() : widget.loadingIndicator,
      secondChild: _loadedImageData == null
          ? Container()
          : Image.memory(
              _loadedImageData,
              fit: widget.fit,
            ),
      crossFadeState: _loadedImageData == null
          ? CrossFadeState.showFirst
          : CrossFadeState.showSecond,
      duration: Duration(milliseconds: 300),
      alignment: Alignment.center,
    );
  }
}
