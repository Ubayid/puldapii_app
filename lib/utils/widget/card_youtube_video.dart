import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubePlayerCard extends StatefulWidget {
  final String url;
  final String? title;
  final bool autoPlay;
  final bool showControls;
  final double borderRadius;
  final EdgeInsetsGeometry margin;

  const YoutubePlayerCard({
    super.key,
    required this.url,
    this.title,
    this.autoPlay = false,
    this.showControls = true,
    this.borderRadius = 12,
    this.margin = const EdgeInsets.only(bottom: 12),
  });

  @override
  State<YoutubePlayerCard> createState() => _YoutubePlayerCardState();
}

class _YoutubePlayerCardState extends State<YoutubePlayerCard> {
  YoutubePlayerController? _controller;
  String? _videoId;

  @override
  void initState() {
    super.initState();
    _setupPlayer();
  }

  @override
  void didUpdateWidget(covariant YoutubePlayerCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.url != widget.url ||
        oldWidget.autoPlay != widget.autoPlay ||
        oldWidget.showControls != widget.showControls) {
      _disposeController();
      _setupPlayer();
    }
  }

  void _setupPlayer() {
    final id = YoutubePlayerController.convertUrlToId(widget.url.trim());

    if (id == null || id.isEmpty) {
      _videoId = null;
      _controller = null;
      return;
    }

    _videoId = id;

    _controller = YoutubePlayerController.fromVideoId(
      videoId: id,
      autoPlay: widget.autoPlay,
      params: YoutubePlayerParams(
        showControls: widget.showControls,
        showFullscreenButton: widget.showControls,
        enableCaption: true,
        strictRelatedVideos: true,
      ),
    );
  }

  void _disposeController() {
    final controller = _controller;

    _controller = null;

    if (controller != null) {
      controller.close();
    }
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(widget.borderRadius);
    final controller = _controller;

    if (controller == null || _videoId == null) {
      return Padding(
        padding: widget.margin,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Text(
            'URL video tidak valid: ${widget.url}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    return Padding(
      padding: widget.margin,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: borderRadius,
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            YoutubePlayer(
              controller: controller,
              aspectRatio: 16 / 9,
              autoFullScreen: true,
              enableFullScreenOnVerticalDrag: true,
            ),

            if ((widget.title ?? '').trim().isNotEmpty)
              Container(
                width: double.infinity,
                color: Theme.of(context).colorScheme.surface,
                padding: const EdgeInsets.all(12),
                child: Text(
                  widget.title!.trim(),
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
