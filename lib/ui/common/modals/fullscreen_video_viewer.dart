import 'package:flutter/foundation.dart';
import 'package:wonders/common_libs.dart';
import 'package:wonders/logic/common/platform_info.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

const _toggleKeys = [LogicalKeyboardKey.enter, LogicalKeyboardKey.space];

class FullscreenVideoViewer extends StatefulWidget {
  const FullscreenVideoViewer({super.key, required this.id});
  final String id;

  @override
  State<FullscreenVideoViewer> createState() => _FullscreenVideoViewerState();
}

class _FullscreenVideoViewerState extends State<FullscreenVideoViewer> {
  late final YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.id,
      params: const YoutubePlayerParams(enableKeyboard: true),
    );
    appLogic.supportedOrientationsOverride = [Axis.horizontal, Axis.vertical];
    HardwareKeyboard.instance.addHandler(_handleKeyEvent);
  }

  @override
  void dispose() {
    // when view closes, remove the override
    appLogic.supportedOrientationsOverride = null;
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _Player(controller: _controller),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all($styles.insets.md),
              child: const BackBtn(),
            ),
          ),
        ],
      ),
    );
  }

  bool _handleKeyEvent(KeyEvent event) {
    switch (event) {
      case KeyDownEvent(logicalKey: final key) when _toggleKeys.contains(key):
        _togglePlayback();
        return true;
      case _:
        return false;
    }
  }

  Future<void> _togglePlayback() async {
    final state = await _controller.playerState;

    if (state == PlayerState.playing) return _controller.pauseVideo();
    return _controller.playVideo();
  }
}

class _Player extends StatelessWidget {
  const _Player({required this.controller});

  final YoutubePlayerController controller;

  @override
  Widget build(BuildContext context) {
    final aspectRatio = context.isLandscape ? MediaQuery.of(context).size.aspectRatio : 1.0;

    return Center(
      child: PlatformInfo.isMobile || kIsWeb
          ? YoutubePlayer(controller: controller, aspectRatio: aspectRatio)
          : Placeholder(),
    );
  }
}
