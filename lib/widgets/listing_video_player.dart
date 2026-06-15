import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';

import '../core/constants/app_colors.dart';

/// Inline listing walkthrough player with thumbnail preview and Chewie controls.
class ListingVideoPlayer extends StatefulWidget {
  const ListingVideoPlayer({
    super.key,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.duration,
    this.isTabActive = true,
  });

  final String videoUrl;
  final String thumbnailUrl;
  final String duration;
  final bool isTabActive;

  @override
  State<ListingVideoPlayer> createState() => _ListingVideoPlayerState();
}

class _ListingVideoPlayerState extends State<ListingVideoPlayer> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isPlaying = false;
  bool _isLoading = false;
  bool _hasError = false;

  @override
  void didUpdateWidget(covariant ListingVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isTabActive && oldWidget.isTabActive) {
      _chewieController?.pause();
    }
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  Future<void> _startPlayback() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final videoController = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );
      await videoController.initialize();

      final chewieController = ChewieController(
        videoPlayerController: videoController,
        autoPlay: true,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        showControlsOnInitialize: false,
        materialProgressColors: ChewieProgressColors(
          playedColor: AppColors.primary,
          handleColor: AppColors.primary,
          bufferedColor: AppColors.primary.withValues(alpha: 0.25),
          backgroundColor: AppColors.borderLight,
        ),
      );

      if (!mounted) {
        await videoController.dispose();
        chewieController.dispose();
        return;
      }

      setState(() {
        _videoPlayerController = videoController;
        _chewieController = chewieController;
        _isPlaying = true;
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: _isPlaying && _chewieController != null
            ? Chewie(controller: _chewieController!)
            : _buildPreview(),
      ),
    );
  }

  Widget _buildPreview() {
    if (_hasError) {
      return ColoredBox(
        color: AppColors.borderLight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'تعذّر تحميل الفيديو',
              style: GoogleFonts.cairo(
                color: AppColors.textMuted,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () {
                setState(() => _hasError = false);
                _startPlayback();
              },
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          widget.thumbnailUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => ColoredBox(
            color: AppColors.borderLight,
            child: Icon(
              Icons.videocam_outlined,
              size: 48,
              color: AppColors.textMuted.withValues(alpha: 0.5),
            ),
          ),
        ),
        if (_isLoading)
          ColoredBox(
            color: Colors.black38,
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          )
        else
          Center(
            child: GestureDetector(
              onTap: _startPlayback,
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.85),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
          ),
        Positioned(
          right: 10,
          bottom: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.duration,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
