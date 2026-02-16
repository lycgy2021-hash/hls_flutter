import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../models/video_item.dart';
import '../services/feed_service.dart';

class FeedVideoPlayer extends StatefulWidget {
  const FeedVideoPlayer({
    super.key,
    required this.item,
    required this.controller,
    required this.feedService,
    required this.isActive,
  });

  final VideoItem item;
  final VideoPlayerController? controller;
  final FeedService feedService;
  final bool isActive;

  @override
  State<FeedVideoPlayer> createState() => _FeedVideoPlayerState();
}

class _FeedVideoPlayerState extends State<FeedVideoPlayer> {
  bool _reportedStart = false;
  Timer? _ackTimer;

  @override
  void initState() {
    super.initState();
    _maybeReportStart();
    _restartProgressAckLoop();
  }

  @override
  void didUpdateWidget(covariant FeedVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.videoId != widget.item.videoId) {
      _reportedStart = false;
    }
    _maybeReportStart();
    _restartProgressAckLoop();
  }

  @override
  void dispose() {
    _ackTimer?.cancel();
    super.dispose();
  }

  void _restartProgressAckLoop() {
    _ackTimer?.cancel();
    _ackTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      final c = widget.controller;
      if (c == null ||
          !widget.isActive ||
          !c.value.isInitialized ||
          !c.value.isPlaying) {
        return;
      }
      final position = c.value.position.inMilliseconds;
      final duration = c.value.duration.inMilliseconds;
      unawaited(
        widget.feedService.sendAck(
          item: widget.item,
          ackType: 'progress',
          playPositionMs: position,
          durationMs: duration,
        ),
      );
    });
  }

  void _maybeReportStart() {
    final c = widget.controller;
    if (_reportedStart || c == null || !widget.isActive) return;
    if (!c.value.isInitialized) return;

    _reportedStart = true;
    unawaited(
      widget.feedService.sendAction(
        item: widget.item,
        event: 'watch_start',
        watchMs: 0,
        durationMs: c.value.duration.inMilliseconds,
      ),
    );
    unawaited(
      widget.feedService.sendAck(
        item: widget.item,
        ackType: 'started',
        playPositionMs: 0,
        durationMs: c.value.duration.inMilliseconds,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    if (c == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!c.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    _maybeReportStart();

    return GestureDetector(
      onTap: () async {
        if (c.value.isPlaying) {
          await c.pause();
        } else {
          await c.play();
        }
        setState(() {});
      },
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: c.value.size.width,
              height: c.value.size.height,
              child: VideoPlayer(c),
            ),
          ),
          if (!c.value.isPlaying)
            const Center(
              child:
                  Icon(Icons.play_arrow_rounded, color: Colors.white, size: 64),
            ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 40,
            child: VideoProgressIndicator(
              c,
              allowScrubbing: true,
              colors: const VideoProgressColors(
                playedColor: Colors.white,
                backgroundColor: Colors.white38,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
