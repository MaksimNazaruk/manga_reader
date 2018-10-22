import 'dart:typed_data';
import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

enum ImageStorage { documents, cache }

class _LoadOperation {
  final Completer<Uint8List> completer;
  final String url;

  _LoadOperation(this.completer, this.url);
}

class CachedImageLoader {
  List<_LoadOperation> _queue = [];
  // _LoadOperation _currentOperation;
  bool _processingQueue = false;

  Future<Uint8List> loadImage(
      {String fullImageUrl, bool prioritize = false}) async {
    _LoadOperation operation =
        _LoadOperation(Completer<Uint8List>(), fullImageUrl);
    if (prioritize) {
      _queue.insert(0, operation);
    } else {
      _queue.add(operation);
    }
    if (!_processingQueue) {
      _processingQueue = true;
      _processQueue();
    }
    return operation.completer.future;
  }

  void _processQueue() async {
    print("!@! start processing queue");
    while (_queue.isNotEmpty) {
      var operation = _queue.first;
      print("!@! start processing operation ${operation.url}");
      var imageData = await _loadImage(fullImageUrl: operation.url);
      print("!@! end processing operation ${operation.url}");
      operation.completer.complete(imageData);
      _queue.removeAt(0);
    }
    _processingQueue = false;
    print("!@! end processing queue");
  }

  Future<Uint8List> _loadImage({String fullImageUrl}) async {
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
    // file.lastModified()
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
