import 'dart:typed_data';
import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

enum ImageStorage { documents, cache }

class CachedImageLoader {
  Future<String> _localImageUrl(
      {String shortImageUrl, ImageStorage storage}) async {
    var cacheDir = await getTemporaryDirectory();
    return cacheDir.path + shortImageUrl;
  }

  Future<Uint8List> _loadImage({String imageUrl}) async {
    var imageData = await File(imageUrl).readAsBytes();
    return Uint8List.fromList(imageData);
  }

  Future<void> _saveImage({String imageUrl, Uint8List imageData}) async {
    await File(imageUrl).writeAsBytes(imageData.toList());
  }
}
