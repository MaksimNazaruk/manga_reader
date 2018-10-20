import 'dart:typed_data';
import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

enum ImageStorage { documents, cache }

class CachedImageLoader {
  Future<Uint8List> loadImage({String fullImageUrl}) async {
    // print("!@! loading $fullImageUrl");
    var imageName = fullImageUrl.split("/").last;
    var localUrl =
        await _localImageUrl(imageName: imageName, storage: ImageStorage.cache);
    var image = await _loadLocalImage(imageUrl: localUrl);
    if (image == null) {
      image = await _loadNetworkImage(imageUrl: fullImageUrl);
      await _saveLocalImage(imageUrl: localUrl, imageData: image);
    }
    return image;
  }

  Future<String> _localImageUrl(
      {String imageName, ImageStorage storage}) async {
    Directory directory;
    switch (storage) {
      case ImageStorage.cache:
        directory = await getTemporaryDirectory();
        break;
      case ImageStorage.documents:
        directory = await getApplicationDocumentsDirectory();
        break;
    }
    return directory.path + imageName;
  }

  Future<Uint8List> _loadLocalImage({String imageUrl}) async {
    var file = File(imageUrl);
    var exists = await file.exists();
    if (exists) {
      var imageData = await file.readAsBytes();
      return Uint8List.fromList(imageData);
    } else {
      return null;
    }
  }

  Future<void> _saveLocalImage({String imageUrl, Uint8List imageData}) async {
    await File(imageUrl).writeAsBytes(imageData.toList());
  }

  Future<Uint8List> _loadNetworkImage({String imageUrl}) async {
    var uri = Uri.parse(imageUrl);
    var request = await HttpClient().getUrl(uri);
    var response = await request.close();
    List<int> buffer = [];
    await for (var data in response) {
      buffer.addAll(data);
    }
    return Uint8List.fromList(buffer);
  }
}
