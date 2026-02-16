import '../utils/video_url_sanitizer.dart';

class VideoItem {
  VideoItem({
    required this.id,
    required this.videoId,
    required this.index,
    required this.stepIndex,
    required this.actorId,
    required this.sessionId,
    required this.playUrl,
    required this.title,
    required this.cover,
    required this.upid,
  });

  final String id;
  final String videoId;
  final int index;
  final int stepIndex;
  final String actorId;
  final String sessionId;
  final dynamic playUrl;
  final String title;
  final String cover;
  final String upid;

  String get resolvedPlayUrl => VideoUrlSanitizer.cleanPlayUrl(playUrl);

  bool get hasPlayableUrl => resolvedPlayUrl.isNotEmpty;

  factory VideoItem.fromAlgoResponse({
    required Map<String, dynamic> response,
    required int fallbackIndex,
    required String actorId,
    required String sessionId,
  }) {
    final data =
        (response['data'] ?? <String, dynamic>{}) as Map<String, dynamic>;
    final video =
        (data['video'] ?? <String, dynamic>{}) as Map<String, dynamic>;
    final resolvedIndex = (data['meta']?['index'] as int?) ??
        (data['index'] as int?) ??
        fallbackIndex;
    final dynamic idRaw = video['id'] ??
        video['video_id'] ??
        data['video_id'] ??
        'v_$resolvedIndex';
    final id = '$idRaw';
    return VideoItem(
      id: id,
      videoId: id,
      index: resolvedIndex,
      stepIndex: (data['meta']?['step'] as int?) ?? (resolvedIndex + 1),
      actorId: actorId,
      sessionId: sessionId,
      playUrl: video['play_url'],
      title: '${video['title'] ?? id}',
      cover: '${video['cover'] ?? ''}',
      upid: '${video['upid'] ?? ''}',
    );
  }
}
