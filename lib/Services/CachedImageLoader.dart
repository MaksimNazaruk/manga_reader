import 'dart:typed_data';
import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

enum ImageStorage { documents, cache }

class CachedImageLoader {
  Future<String> _localImageUrl(
      {String shortImageUrl, ImageStorage storage}) async {
    Directory directory;
    switch (storage) {
      case ImageStorage.cache:
        directory = await getTemporaryDirectory();
        break;
      case ImageStorage.documents:
        directory = await getApplicationDocumentsDirectory();
        break;
    }
    return directory.path + shortImageUrl;
  }

  Future<Uint8List> _loadLocalImage({String imageUrl}) async {
    var imageData = await File(imageUrl).readAsBytes();
    return Uint8List.fromList(imageData);
  }

  Future<void> _saveLocalImage({String imageUrl, Uint8List imageData}) async {
    await File(imageUrl).writeAsBytes(imageData.toList());
  }

  Future<Uint8List> _loadNetworkImage({String imageUrl}) async {
    var request = await HttpClient().getUrl(Uri(path: imageUrl));
    var response = await request.close();
    List<int> buffer = [];
    await for (var data in response) {
      buffer.addAll(data);
    }
    return Uint8List.fromList(buffer);
  }
}
