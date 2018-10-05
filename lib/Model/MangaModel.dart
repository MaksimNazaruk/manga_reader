class Manga {
  final String id;
  final String title;
  final String alias;
  final String posterUrl;
  List<Chapter> chapters;

  // Manga(this.id, this.title, this.alias, List<dynamic> chapters) {
  //   this.chapters = chapters.map((chapterArray) => Chapter(chapterArray)).toList();
  // }

  Manga(this.id, this.title, this.alias, this.posterUrl);

  factory Manga.fromShortMap(Map<String, dynamic> map) {
    return Manga(map["i"], map["t"], map["a"], map["im"]);
  }

  factory Manga.fromFullMap(Map<String, dynamic> map) {
    return Manga(map["i"], map["t"], map["a"], map["im"]);
  }
}

class Chapter {
  final int number;
  final double date;
  final String title;
  final String id;

  Chapter(this.number, this.date, this.title, this.id);

  factory Chapter.fromArray(List<dynamic> array) {
    return Chapter(array[0], array[1], array[2], array[3]);
  }

}