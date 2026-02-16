import 'dart:async';

import '../config/endpoints.dart';
import '../models/video_item.dart';
import '../utils/app_error.dart';
import '../utils/video_url_sanitizer.dart';
import 'api_client.dart';
import 'identity_manager.dart';

class FeedService {
  FeedService(this._apiClient, this._identityManager);

  final ApiClient _apiClient;
  final IdentityManager _identityManager;

  Future<List<VideoItem>> fetchNextBatch(
      {required int startIndex, int pageSize = 5}) async {
    await _identityManager.refreshSessionIfExpired();

    final futures = <Future<Map<String, dynamic>>>[];
    for (int i = 0; i < pageSize; i++) {
      final index = startIndex + i;
      futures.add(
        _apiClient.post(
          Endpoints.algoNext,
          data: <String, dynamic>{
            'actor_id': _identityManager.actorId,
            'session_id': _identityManager.sessionId,
            'index': index,
            'dir': 'NEXT',
            'step': index + 1,
            'device_id': _identityManager.did,
          },
        ),
      );
    }

    final responses = await Future.wait(futures);
    final result = <VideoItem>[];

    for (int i = 0; i < responses.length; i++) {
      final response = responses[i];
      final success = response['success'] == true;
      if (!success) {
        continue;
      }

      final item = VideoItem.fromAlgoResponse(
        response: response,
        fallbackIndex: startIndex + i,
        actorId: _identityManager.actorId,
        sessionId: _identityManager.sessionId,
      );

      if (VideoUrlSanitizer.isAdUrl(item.resolvedPlayUrl) ||
          item.resolvedPlayUrl.isEmpty) {
        continue;
      }

      result.add(item);
    }

    if (result.isEmpty) {
      throw AppError('暂无可播放视频，请稍后重试', code: 503);
    }

    return result;
  }

  Future<void> sendAck({
    required VideoItem item,
    required String ackType,
    required int playPositionMs,
    required int durationMs,
  }) {
    return _apiClient.post(
      Endpoints.algoAck,
      data: <String, dynamic>{
        'actor_id': item.actorId,
        'session_id': item.sessionId,
        'index': item.index,
        'step_index': item.stepIndex,
        'video_id': item.videoId,
        'ack_type': ackType,
        'play_position_ms': playPositionMs,
        'duration_ms': durationMs,
        'client_ts': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      },
    );
  }

  Future<void> sendAction({
    required VideoItem item,
    required String event,
    required int watchMs,
    required int durationMs,
    int like = 0,
    int skip = 0,
    int complete = 0,
  }) {
    return _apiClient.post(
      Endpoints.algoAction,
      data: <String, dynamic>{
        'actor_id': item.actorId,
        'session_id': item.sessionId,
        'index': item.index,
        'step_index': item.stepIndex,
        'video_id': item.videoId,
        'event': event,
        'watch_ms': watchMs,
        'duration_ms': durationMs,
        'like': like,
        'skip': skip,
        'complete': complete,
        'ts': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      },
    );
  }
}
