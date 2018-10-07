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
  // final String id; // TODO: get id somehow
  String title;
  String akaTitle;
  String posterUrl;
  String artist;
  String autor;
  List<ChapterInfo> chapters;

  // Manga(this.id, this.title, this.alias, List<dynamic> chapters) {
  //   this.chapters = chapters.map((chapterArray) => Chapter(chapterArray)).toList();
  // }

  // FullMangaInfo(this.id, this.title, this.akaTitle, this.alias, this.posterUrl);

  FullMangaInfo.fromMap(Map<String, dynamic> map) {
    this.title = map["title"];
  }
}

class ChapterInfo {
  final int number;
  final double date;
  final String title;
  final String id;

  ChapterInfo(this.number, this.date, this.title, this.id);

  factory ChapterInfo.fromArray(List<dynamic> array) {
    return ChapterInfo(array[0], array[1], array[2], array[3]);
  }
}
