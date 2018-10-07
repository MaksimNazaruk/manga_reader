class ShortMangaInfo {
  final String id;
  final String title;
  final String alias;
  final String posterUrl;

  // Manga(this.id, this.title, this.alias, List<dynamic> chapters) {
  //   this.chapters = chapters.map((chapterArray) => Chapter(chapterArray)).toList();
  // }

  ShortMangaInfo(this.id, this.title, this.alias, this.posterUrl);

  factory ShortMangaInfo.fromMap(Map<String, dynamic> map) {
    return ShortMangaInfo(map["i"], map["t"], map["a"], map["im"]);
  }
}

class FullMangaInfo {
  String id;
  String title;
  String posterUrl;
  // String artist;
  String author;
  String description;
  List<String> categories;
  List<ChapterInfo> chapters;

  // Manga(this.id, this.title, this.alias, List<dynamic> chapters) {
  //   this.chapters = chapters.map((chapterArray) => Chapter(chapterArray)).toList();
  // }

  // FullMangaInfo(this.id, this.title, this.akaTitle, this.alias, this.posterUrl);

  FullMangaInfo.fromMap(String id, Map<String, dynamic> map) {
    this.id = id;
    title = map["title"];
    author = map["author"];
    description = map["description"];
    chapters = (map["chapters"] as List).reversed.map((chapterArray) => ChapterInfo.fromArray(chapterArray)).toList();
  }
}

class ChapterInfo {
  final double number;
  final double date;
  final String title;
  final String id;

  ChapterInfo(this.number, this.date, this.title, this.id);

  factory ChapterInfo.fromArray(List<dynamic> array) {
    return ChapterInfo((array[0] as num).toDouble(), array[1], array[2], array[3]);
  }
}

class MangaImageInfo {
  final double index;
  final String url;
  final int width;
  final int height;

  MangaImageInfo(this.index, this.url, this.width, this.height);

  factory MangaImageInfo.fromArray(List<dynamic> array) {
    return MangaImageInfo((array[0] as num).toDouble(), array[1], array[2], array[3]);
  }
}
