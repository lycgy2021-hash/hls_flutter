import 'package:video_player/video_player.dart';

import '../utils/app_logger.dart';

class VideoControllerPool {
  final Map<int, VideoPlayerController> _controllers =
      <int, VideoPlayerController>{};

  VideoPlayerController? controllerOf(int index) => _controllers[index];

  Future<VideoPlayerController> ensure(
      {required int index, required String url}) async {
    final existing = _controllers[index];
    if (existing != null) {
      return existing;
    }

    final controller = VideoPlayerController.networkUrl(Uri.parse(url));
    await controller.initialize();
    controller.setLooping(true);
    _controllers[index] = controller;
    return controller;
  }

  Future<void> maintainWindow({
    required int currentIndex,
    required String currentUrl,
    String? nextUrl,
  }) async {
    await ensure(index: currentIndex, url: currentUrl);
    if (nextUrl != null && nextUrl.isNotEmpty) {
      await ensure(index: currentIndex + 1, url: nextUrl);
    }

    final allowed = <int>{currentIndex, currentIndex + 1};
    final toRelease =
        _controllers.keys.where((i) => !allowed.contains(i)).toList();
    for (final index in toRelease) {
      await release(index);
    }
  }

  Future<void> playOnly(int index) async {
    for (final entry in _controllers.entries) {
      if (entry.key == index) continue;
      if (entry.value.value.isPlaying) {
        await entry.value.pause();
      }
    }

    final active = _controllers[index];
    if (active != null &&
        active.value.isInitialized &&
        !active.value.isPlaying) {
      await active.play();
    }
  }

  Future<void> pauseAll() async {
    for (final controller in _controllers.values) {
      if (controller.value.isPlaying) {
        await controller.pause();
      }
    }
  }

  Future<void> release(int index) async {
    final controller = _controllers.remove(index);
    if (controller == null) return;
    try {
      await controller.pause();
      await controller.dispose();
    } catch (e, s) {
      AppLogger.error('release controller failed', error: e, stackTrace: s);
    }
  }

  Future<void> disposeAll() async {
    final keys = _controllers.keys.toList();
    for (final key in keys) {
      await release(key);
    }
  }
}
