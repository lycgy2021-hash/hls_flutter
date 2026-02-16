class VideoUrlSanitizer {
  static const List<String> adDomains = <String>[
    'mediav.com',
    'live-s3m',
    'doubleclick.net',
    'ads.',
    'ad.',
    'adv.',
    'beacon',
    'tracking',
  ];

  static bool isAdUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    final lower = url.toLowerCase();
    return adDomains.any((domain) => lower.contains(domain));
  }

  static String cleanPlayUrl(dynamic raw) {
    if (raw is String) {
      return isAdUrl(raw) ? '' : raw;
    }
    if (raw is List) {
      for (final item in raw) {
        if (item is String && item.isNotEmpty && !isAdUrl(item)) {
          return item;
        }
      }
      return '';
    }
    return '';
  }
}
