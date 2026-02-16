import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_app/utils/video_url_sanitizer.dart';

void main() {
  group('VideoUrlSanitizer', () {
    test('filters ad domains for string', () {
      expect(
          VideoUrlSanitizer.cleanPlayUrl('https://mediav.com/ads/a.mp4'), '');
    });

    test('keeps first non-ad URL from array', () {
      final cleaned = VideoUrlSanitizer.cleanPlayUrl(<String>[
        'https://ads.example.com/a.mp4',
        'https://cdn.example.com/video.mp4',
      ]);
      expect(cleaned, 'https://cdn.example.com/video.mp4');
    });
  });
}
