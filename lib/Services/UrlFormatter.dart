import 'package:hello_world/Services/Providers/UserSessionProvider.dart';
import 'package:hello_world/Services/Providers/CQSettingsProvider.dart';

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
  static const _baseCountryUrls = {"NL": "www.horizon.tv"};

  String get _countryCode {
    if (UserSessionProvider.currentUserSession != null) {
      return UserSessionProvider.currentUserSession.countryCode;
    } else {
      return "NL";
    }
  }

  String get _languageCode {
    return "eng"; // TODO: get from userSession
  }

  String get _platform {
    return "ios"; // TODO: get from device
  }

  String get host {
    return _baseCountryUrls[_countryCode];
  }

  static final CQUrlFormatter cq = CQUrlFormatter();
  static final OespSessionUrlFormatter oespSession = OespSessionUrlFormatter();
  static final OespFeedUrlFormatter oespFeed = OespFeedUrlFormatter();
}

class CQUrlFormatter extends UrlFormatter {
  String get _basePath {
    return "/content/unified/$_countryCode/$_languageCode/$_platform";
  }

  FormattedUrl get settings {
    return FormattedUrl(host: host, path: "$_basePath/settings.json");
  }

  FormattedUrl get layout {
    return FormattedUrl(host: host, path: "$_basePath/layout.json");
  }
}

class OespUrlFormatter extends UrlFormatter {
  @override
  String get host {
    return CQSettingsProvider.oespBaseUrl();
  }

  String get _basePath {
    return "/oesp/v2/$_countryCode/$_languageCode/$_platform";
  }
}

class OespSessionUrlFormatter extends OespUrlFormatter {
  FormattedUrl get login {
    return FormattedUrl(host: host, path: "$_basePath/session");
  }
}

class OespFeedUrlFormatter extends OespUrlFormatter {
  FormattedUrl feed(String feedId) {
    return FormattedUrl(host: host, path: "$_basePath/mediagroups/feeds/$feedId");
  }
}
