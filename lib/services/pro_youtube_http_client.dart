import 'dart:io';

import 'package:http/io_client.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

/// YouTube HTTP client tuned for Flutter (mobile + release) and HTML/API fetches.
///
/// Uses [IOClient] with explicit timeouts, a current Chrome UA, referer/origin,
/// and consent-style cookies so requests match normal browser traffic.
class ProYoutubeHttpClient extends YoutubeHttpClient {
  ProYoutubeHttpClient() : super(_createInner());

  static IOClient _createInner() {
    final hc = HttpClient();
    hc.connectionTimeout = const Duration(seconds: 30);
    hc.idleTimeout = const Duration(seconds: 45);
    hc.autoUncompress = true;
    return IOClient(hc);
  }

  @override
  Map<String, String> get headers => {
        ...YoutubeHttpClient.defaultHeaders,
        'user-agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.6778.204 Safari/537.36',
        'accept':
            'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
        'accept-language': 'en-US,en;q=0.9,am;q=0.88,om;q=0.85,et;q=0.8',
        'cache-control': 'max-age=0',
        'referer': 'https://www.youtube.com/',
        'origin': 'https://www.youtube.com',
        'sec-fetch-dest': 'document',
        'sec-fetch-mode': 'navigate',
        'sec-fetch-site': 'same-origin',
        'sec-fetch-user': '?1',
        'upgrade-insecure-requests': '1',
        'cookie': 'CONSENT=YES+cb; PREF=hl=en&f6=40000000&tz=UTC',
      };
}
