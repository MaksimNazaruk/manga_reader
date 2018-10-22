import 'dart:typed_data';
import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

enum ImageStorage { documents, cache }

class _LoadOperation {
  Completer<Uint8List> completer;
  final String url;

  _LoadOperation(this.url){
    completer = Completer();
  }
}

class CachedImageLoader {

  static CachedImageLoader loader = CachedImageLoader();

  List<_LoadOperation> _queue = [];
  // _LoadOperation _currentOperation;
  bool _processingQueue = false;

  Future<Uint8List> loadImage(
      {String fullImageUrl, bool prioritize = false}) {
    _LoadOperation operation =
        _LoadOperation(fullImageUrl);
    if (prioritize) {
      _queue.insert(0, operation);
    } else {
      _queue.add(operation);
    }
    if (!_processingQueue) {
      _processQueue();
    }
    return operation.completer.future;
  }

  void _processQueue() async {
    _processingQueue = true;
    while (_queue.isNotEmpty) {
      var operation = _queue.first;
      var imageData = await _loadImage(fullImageUrl: operation.url);
      operation.completer.complete(imageData);
      _queue.remove(operation);
    }
    _processingQueue = false;
  }

  Future<Uint8List> _loadImage({String fullImageUrl}) async {
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
    // file.lastModified() // TODO: use to clear cache
    if (exists) {
      var imageData = await file.readAsBytes();
      return Uint8List.fromList(imageData);
    } else {
      return null;
    }
  }

  Future<void> _saveLocalImage({String imageUrl, Uint8List imageData}) async {
    List<int> intImageData = await uint8ListToIntListAsync(imageData);
    await File(imageUrl).writeAsBytes(intImageData);
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

  Future<List<int>> uint8ListToIntListAsync(Uint8List uintList) {
    return Future.microtask((){
      return uintList.toList();
    });
  }
}
