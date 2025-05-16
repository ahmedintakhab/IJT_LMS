import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ContentDisplayScreen extends StatefulWidget {
  final String title;
  final String contentType;
  final String source;

  const ContentDisplayScreen({
    Key? key,
    required this.title,
    required this.contentType,
    required this.source,
  }) : super(key: key);

  @override
  _ContentDisplayScreenState createState() => _ContentDisplayScreenState();
}

class _ContentDisplayScreenState extends State<ContentDisplayScreen> {
  VideoPlayerController? _videoController;
  YoutubePlayerController? _youtubeController;
  AudioPlayer? _audioPlayer;
  bool _isInitialized = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeContent();
  }

  Future<void> _initializeContent() async {
    try {
      switch (widget.contentType) {
        case 'video':
          _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.source))
            ..initialize().then((_) {
              setState(() {
                _isInitialized = true;
              });
              _videoController?.play();
            }).catchError((e) {
              setState(() {
                _errorMessage = 'Failed to load video: $e';
              });
            });
          break;
        case 'youtube':
          final videoId = YoutubePlayer.convertUrlToId(widget.source);
          if (videoId != null) {
            _youtubeController = YoutubePlayerController(
              initialVideoId: videoId,
              flags: const YoutubePlayerFlags(
                autoPlay: false,
                mute: false,
              ),
            );
            setState(() {
              _isInitialized = true;
            });
          } else {
            setState(() {
              _errorMessage = 'Invalid YouTube URL';
            });
          }
          break;
        case 'audio':
          _audioPlayer = AudioPlayer();
          await _audioPlayer!.setUrl(widget.source).then((_) {
            setState(() {
              _isInitialized = true;
            });
            _audioPlayer?.play();
          }).catchError((e) {
            setState(() {
              _errorMessage = 'Failed to load audio: $e';
            });
          });
          break;
        case 'image':
          setState(() {
            _isInitialized = true;
          });
          break;
        case 'pdf':
          setState(() {
            _isInitialized = true;
          });
          break;
        default:
          setState(() {
            _errorMessage = 'Unsupported content type: ${widget.contentType}';
          });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error initializing content: $e';
      });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _youtubeController?.dispose();
    _audioPlayer?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF00AFEE),
        title: Align(
          alignment: Alignment.centerRight,
          child: Text(
            widget.title,
            style: TextStyle(
              fontFamily: 'Nastaleeq',
              fontSize: 26.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white
            ),
            textDirection: TextDirection.rtl,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,color: Colors.white,),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: _errorMessage != null
          ? Center(
        child: Text(
          _errorMessage!,
          style: TextStyle(fontSize: 16.sp, color: Colors.red),
        ),
      )
          : !_isInitialized
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00AFEE),))
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    switch (widget.contentType) {
      case 'video':
        return Column(
          children: [
            AspectRatio(
              aspectRatio: _videoController!.value.aspectRatio,
              child: VideoPlayer(_videoController!),
            ),
            VideoProgressIndicator(_videoController!, allowScrubbing: true),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    _videoController!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                  ),
                  onPressed: () {
                    setState(() {
                      _videoController!.value.isPlaying
                          ? _videoController!.pause()
                          : _videoController!.play();
                    });
                  },
                ),
              ],
            ),
          ],
        );
      case 'youtube':
        return YoutubePlayer(
          controller: _youtubeController!,
          showVideoProgressIndicator: true,
          onReady: () {
            _youtubeController!.play();
          },
        );
      case 'image':
        return Center(
          child: CachedNetworkImage(
            imageUrl: widget.source,
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) => const Icon(Icons.error),
            fit: BoxFit.contain,
          ),
        );
      case 'audio':
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Playing: ${widget.title}',
              style: TextStyle(fontSize: 18.sp, fontFamily: 'Nastaleeq'),
            ),
            SizedBox(height: 20.h),
            StreamBuilder<Duration?>(
              stream: _audioPlayer!.positionStream,
              builder: (context, snapshot) {
                final position = snapshot.data ?? Duration.zero;
                final duration = _audioPlayer!.duration ?? Duration.zero;
                return Column(
                  children: [
                    Slider(
                      value: position.inSeconds.toDouble(),
                      max: duration.inSeconds.toDouble(),
                      onChanged: (value) {
                        _audioPlayer!.seek(Duration(seconds: value.toInt()));
                      },
                    ),
                    Text(
                      '${position.inMinutes}:${(position.inSeconds % 60).toString().padLeft(2, '0')} / '
                          '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}',
                    ),
                  ],
                );
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    _audioPlayer!.playing ? Icons.pause : Icons.play_arrow,
                  ),
                  onPressed: () {
                    setState(() {
                      _audioPlayer!.playing ? _audioPlayer!.pause() : _audioPlayer!.play();
                    });
                  },
                ),
              ],
            ),
          ],
        );
      case 'pdf':
        return SfPdfViewer.network(widget.source);
      default:
        return const Center(child: Text('Unsupported content type'));
    }
  }
}