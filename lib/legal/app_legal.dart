/// In-app legal copy (not a substitute for counsel; adjust before store release).
abstract final class AppLegal {
  static const String privacyTitle = 'Privacy';

  static const String privacyBody = '''
ProPlayer is designed to play media you choose.

• Local library: With your permission, the app reads audio and video files from your device using the system media APIs. This data stays on your device; we do not upload your files to our servers.

• YouTube: Online search and playback use YouTube’s services and embedded player. Your use is subject to YouTube’s terms and privacy policy.

• Recently played: A small list of titles you opened is stored locally on your device to power the “Recently played” section.

• We do not sell your personal data. Network requests (e.g. loading thumbnails or search) go to the services you use (YouTube, etc.).

You can clear recently played from Settings. Revoking media permission limits local scanning but does not delete files on your device.
''';

  static const String termsTitle = 'Terms of use';

  static const String termsBody = '''
ProPlayer is provided “as is” for personal media playback and discovery.

You are responsible for complying with copyright and the terms of any content you access (including YouTube). Do not use the app to infringe others’ rights.

The app may be updated or discontinued without notice. To the extent permitted by law, we are not liable for damages arising from use of the app.

If you do not agree to these terms, please uninstall the app.
''';
}
