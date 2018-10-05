class FormattedUrl {
  final String host;
  final String path;
  Map<String, String> parameters;
  FormattedUrl({this.host, this.path, this.parameters});

  FormattedUrl withParameters(Map<String, String> newParameters) {
    return FormattedUrl(host: host, path: path, parameters: newParameters);
  }

  @override
  String toString() {
    return Uri.https(host, path, parameters).toString();
  }
}

class UrlFormatter {
  int get _languageCode {
    return 0; // TODO: make a possibility to chose language
  }

  String _host = "www.mangaeden.com";
  String _imgHost = "cdn.mangaeden.com";

  String _basePath = "/api";

  FormattedUrl list() {
    return FormattedUrl(host: _host, path: "$_basePath/list/$_languageCode/");
  }

  FormattedUrl listPage(int page, [int pageSize]) {
    var params = {"p": "$page"};
    if (pageSize != null) {
      params["l"] = "$pageSize";
    }
    return list().withParameters(params);
  }

  FormattedUrl manga(String id) {
    return FormattedUrl(host: _host, path: "$_basePath/manga/$id");
  }

  FormattedUrl chapter(String id) {
    return FormattedUrl(host: _host, path: "$_basePath/chapter/$id");
  }

  FormattedUrl image(String id) {
    return FormattedUrl(host: _imgHost, path: "mangasimg/$id");
  }
}
