import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/app_routes.dart';
import '../controllers/auth_controller.dart';
import '../controllers/feed_controller.dart';
import '../services/feed_service.dart';
import '../widgets/error_state.dart';
import '../widgets/feed_video_player.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> with WidgetsBindingObserver {
  final FeedController _feedController = Get.find<FeedController>();
  final FeedService _feedService = Get.find<FeedService>();
  final AuthController _authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      unawaited(_feedController.onAppPaused());
    }
    if (state == AppLifecycleState.resumed) {
      unawaited(_feedController.onAppResumed());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('推荐视频'),
        actions: <Widget>[
          IconButton(
            onPressed: () async {
              await _authController.logout();
              Get.offAllNamed(AppRoutes.login);
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Obx(() {
        if (_feedController.loading.value && _feedController.videos.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_feedController.errorMessage.value.isNotEmpty &&
            _feedController.videos.isEmpty) {
          return ErrorState(
            message: _feedController.errorMessage.value,
            onRetry: () {
              unawaited(_feedController.loadInitial());
            },
          );
        }

        if (_feedController.videos.isEmpty) {
          return ErrorState(
            message: '暂无视频',
            onRetry: () {
              unawaited(_feedController.loadInitial());
            },
          );
        }

        return PageView.builder(
          scrollDirection: Axis.vertical,
          itemCount: _feedController.videos.length,
          onPageChanged: (index) =>
              unawaited(_feedController.onPageChanged(index)),
          itemBuilder: (context, index) {
            final item = _feedController.videos[index];
            final controller = _feedController.controllerOf(index);
            final isActive = _feedController.currentIndex.value == index;
            return Stack(
              fit: StackFit.expand,
              children: <Widget>[
                FeedVideoPlayer(
                  item: item,
                  controller: controller,
                  feedService: _feedService,
                  isActive: isActive,
                ),
                Positioned(
                  right: 12,
                  bottom: 120,
                  child: Column(
                    children: <Widget>[
                      IconButton(
                        onPressed: _feedController.toggleLikeCurrent,
                        color: Colors.white,
                        icon: const Icon(Icons.favorite_border),
                        tooltip: 'TODO(M3) 点赞',
                      ),
                      IconButton(
                        onPressed: _feedController.toggleCollectCurrent,
                        color: Colors.white,
                        icon: const Icon(Icons.bookmark_border),
                        tooltip: 'TODO(M3) 收藏',
                      ),
                      IconButton(
                        onPressed: _feedController.openCommentsCurrent,
                        color: Colors.white,
                        icon: const Icon(Icons.comment_bank_outlined),
                        tooltip: 'TODO(M3) 评论',
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 80,
                  child: Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            );
          },
        );
      }),
    );
  }
}
