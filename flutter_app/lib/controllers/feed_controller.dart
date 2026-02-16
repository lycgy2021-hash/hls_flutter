import 'dart:async';

import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../models/video_item.dart';
import '../services/feed_service.dart';
import '../services/video_controller_pool.dart';
import '../utils/app_error.dart';

class FeedController extends GetxController {
  FeedController(this._feedService, this._pool);

  final FeedService _feedService;
  final VideoControllerPool _pool;

  final RxList<VideoItem> videos = <VideoItem>[].obs;
  final RxBool loading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxInt currentIndex = 0.obs;

  int _nextFetchIndex = 0;
  bool _fetching = false;

  VideoPlayerController? controllerOf(int index) => _pool.controllerOf(index);

  @override
  void onInit() {
    super.onInit();
    unawaited(loadInitial());
  }

  Future<void> loadInitial() async {
    videos.clear();
    _nextFetchIndex = 0;
    currentIndex.value = 0;
    await _loadMore();
    await _prepareCurrentWindow();
  }

  Future<void> _loadMore() async {
    if (_fetching) return;
    _fetching = true;
    loading.value = true;
    errorMessage.value = '';

    try {
      final batch = await _feedService.fetchNextBatch(
          startIndex: _nextFetchIndex, pageSize: 5);
      videos.addAll(batch);
      _nextFetchIndex += batch.length;
    } on AppError catch (e) {
      errorMessage.value = e.message;
    } finally {
      loading.value = false;
      _fetching = false;
    }
  }

  Future<void> onPageChanged(int index) async {
    if (index < 0 || index >= videos.length) return;
    currentIndex.value = index;
    await _prepareCurrentWindow();

    if (videos.length - index <= 2) {
      await _loadMore();
    }
  }

  Future<void> _prepareCurrentWindow() async {
    if (videos.isEmpty || currentIndex.value >= videos.length) return;
    final current = videos[currentIndex.value];
    final next = currentIndex.value + 1 < videos.length
        ? videos[currentIndex.value + 1]
        : null;

    await _pool.maintainWindow(
      currentIndex: currentIndex.value,
      currentUrl: current.resolvedPlayUrl,
      nextUrl: next?.resolvedPlayUrl,
    );

    await _pool.playOnly(currentIndex.value);

    unawaited(
      _feedService.sendAck(
        item: current,
        ackType: 'shown',
        playPositionMs: 0,
        durationMs: 0,
      ),
    );
  }

  Future<void> onAppPaused() async {
    await _pool.pauseAll();
  }

  Future<void> onAppResumed() async {
    await _pool.playOnly(currentIndex.value);
  }

  Future<void> toggleLikeCurrent() async {
    // TODO(M3): call /video/like and optimistic update of current item state.
  }

  Future<void> toggleCollectCurrent() async {
    // TODO(M3): call /video/collect and optimistic update of current item state.
  }

  Future<void> openCommentsCurrent() async {
    // TODO(M3): call /video/comments and show bottom sheet list.
  }

  @override
  void onClose() {
    unawaited(_pool.disposeAll());
    super.onClose();
  }
}
