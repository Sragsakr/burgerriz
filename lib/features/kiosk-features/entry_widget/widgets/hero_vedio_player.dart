import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:video_player/video_player.dart';

/// Hero video player widget for the Maknoon Kiosk entry screen.
/// Displays a full-screen video with autoplay, loop, and muted audio.
/// Includes automatic retry (3 attempts) and graceful fallback on failure.
class HeroVideoPlayer extends StatefulWidget {
  final String videoUrl;

  const HeroVideoPlayer({super.key, required this.videoUrl});

  @override
  State<HeroVideoPlayer> createState() => _HeroVideoPlayerState();
}

class _HeroVideoPlayerState extends State<HeroVideoPlayer> {
  static const int _maxRetries = 3;

  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    try {
      _initializeVideo();
      setState(() {
        _isInitialized = true;
        _hasError = false;
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('HeroVideoPlayer: Error initializing video: $e');
      }
      errorMessage = e.toString();
      setState(() {
        _isInitialized = true;
        _hasError = true;
      });
    }
  }

  Future<void> _initializeVideo() async {
    for (var attempt = 0; attempt < _maxRetries; attempt++) {
      if (!mounted) return;

      try {
        // Dispose previous controller if retrying
        await _controller?.dispose();

        _controller = VideoPlayerController.asset(widget.videoUrl,
            viewType: VideoViewType.platformView,
            videoPlayerOptions: VideoPlayerOptions(
              mixWithOthers: true,
              allowBackgroundPlayback: true,
            ));

        await _controller!.initialize();

        // Configure video playback
        _controller!.setLooping(true);

        // Get volume from settings (default 0.0 for muted)
        // final volume = await AppPreferences().getHeroVideoVolume();
        _controller!.setVolume(0);

        // Start playing
        await _controller!.play();

        // Add error listener for runtime playback failures
        _controller!.addListener(_onVideoError);

        if (mounted) {
          setState(() {
            _isInitialized = true;
            _hasError = false;
          });
        }
        return; // Success — exit retry loop
      } catch (e) {
        setState(() {
          errorMessage = e.toString();
        });
        if (kDebugMode) {
          debugPrint('HeroVideoPlayer: Attempt ${attempt + 1}/$_maxRetries failed: $e');
        }

        if (attempt < _maxRetries - 1) {
          // Exponential backoff: 1s, 2s, 4s
          await Future.delayed(Duration(seconds: 1 << attempt));
        }
      }
    }

    // All retries exhausted — show fallback
    if (mounted) {
      setState(() {
        _hasError = true;
      });
    }
  }

  /// Listener for runtime playback errors (e.g. decoder crash mid-playback).
  void _onVideoError() {
    if (_controller?.value.hasError == true && mounted && !_hasError) {
      if (kDebugMode) {
        debugPrint('HeroVideoPlayer: Runtime error: ${_controller?.value.errorDescription}');
      }
      setState(() {
        _hasError = true;
        errorMessage = _controller?.value.errorDescription ?? 'Unknown error';
      });
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_onVideoError);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    if (!_isInitialized || (_hasError && errorMessage != null)) {
      return _buildFallbackWidget(errorMessage);
    }

    return _buildVideoWidget();
  }

  Widget _buildVideoWidget() {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: FittedBox(
        fit: BoxFit.fill,
        child: Container(
          color: Colors.white,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: AspectRatio(aspectRatio: _controller!.value.aspectRatio, child: VideoPlayer(_controller!)),
        ),
      ),
    );
  }

  /// Fallback widget shown while loading or when video fails.
  /// Shows a black background — keeps the kiosk looking clean.
  Widget _buildFallbackWidget(String? errorMessage) {
    if (errorMessage != null) {
      return Center(
        child: Text(errorMessage),
      );
    }
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: _isInitialized
          ? const SizedBox.shrink() // Error state: just black
          : const Center(
              // Loading state: spinner
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
    );
  }
}
