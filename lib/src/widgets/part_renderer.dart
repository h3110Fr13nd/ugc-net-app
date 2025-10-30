import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import 'dart:io' show Platform;
import '../models/composite_question.dart';
import '../services/api_client.dart';
import '../services/media_service.dart';

/// Widget to render a single question or option part
class PartRenderer extends StatelessWidget {
  final PartType partType;
  final String? content;
  final Map<String, dynamic>? contentJson;
  final Media? media;
  final TextStyle? textStyle;

  const PartRenderer({
    super.key,
    required this.partType,
    this.content,
    this.contentJson,
    this.media,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    switch (partType) {
      case PartType.text:
        return _buildTextPart(context);
      case PartType.image:
        return _buildImagePart(context);
      case PartType.diagram:
        return _buildDiagramPart(context);
      case PartType.latex:
        return _buildLatexPart(context);
      case PartType.code:
        return _buildCodePart(context);
      case PartType.audio:
        return _buildAudioPart(context);
      case PartType.video:
        return _buildVideoPart(context);
      case PartType.table:
        return _buildTablePart(context);
    }
  }

  Widget _buildTextPart(BuildContext context) {
    if (content == null || content!.isEmpty) {
      return const SizedBox.shrink();
    }
    return SelectableText(
      content!,
      style: textStyle ?? Theme.of(context).textTheme.bodyLarge,
    );
  }

  Widget _buildImagePart(BuildContext context) {
    if (media == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          children: [
            Icon(Icons.image, color: Colors.grey),
            SizedBox(width: 8),
            Text('Image not available', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }
    
    String imageUrl = media!.url;
    if (!imageUrl.startsWith('http')) {
      final apiClient = ApiClient();
      // Remove /api/v1 from baseUrl to get the root URL
      final baseUrl = apiClient.baseUrl.replaceAll('/api/v1', '');
      imageUrl = '$baseUrl$imageUrl';
    }
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        imageUrl,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.red),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.error, color: Colors.red),
                SizedBox(width: 8),
                Text('Failed to load image', style: TextStyle(color: Colors.red)),
              ],
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
      ),
    );
  }

  Widget _buildDiagramPart(BuildContext context) {
    // Similar to image, but could have special handling for SVG, etc.
    return _buildImagePart(context);
  }

  Widget _buildLatexPart(BuildContext context) {
    // For now, show as code-like text. In production, use flutter_math_fork or similar
    if (content == null || content!.isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: SelectableText(
        content!,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 14,
          color: Colors.purple,
        ),
      ),
    );
  }

  Widget _buildCodePart(BuildContext context) {
    if (content == null || content!.isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
      ),
      child: SelectableText(
        content!,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 14,
          color: Colors.greenAccent,
        ),
      ),
    );
  }

  Widget _buildAudioPart(BuildContext context) {
    if (media == null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue[200]!),
        ),
        child: Row(
          children: [
            Icon(Icons.audiotrack, color: Colors.blue[700]),
            const SizedBox(width: 8),
            const Text('No audio file'),
          ],
        ),
      );
    }

    return _AudioPlayerWidget(media: media!);
  }

  Widget _buildVideoPart(BuildContext context) {
    if (media == null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.purple[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.purple[200]!),
        ),
        child: Row(
          children: [
            Icon(Icons.video_library, color: Colors.purple[700]),
            const SizedBox(width: 8),
            const Text('No video file'),
          ],
        ),
      );
    }

    return _VideoPlayerWidget(media: media!);
  }

  Widget _buildTablePart(BuildContext context) {
    // Parse contentJson for table data
    if (contentJson == null) {
      return const Text('Table data not available');
    }
    
    // Expected format: { "headers": [...], "rows": [[...], [...]] }
    final headers = (contentJson!['headers'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
    final rows = (contentJson!['rows'] as List<dynamic>?)?.map((row) {
      return (row as List<dynamic>).map((cell) => cell.toString()).toList();
    }).toList() ?? [];

    if (headers.isEmpty && rows.isEmpty) {
      return const Text('Empty table');
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: headers.map((h) => DataColumn(label: Text(h))).toList(),
        rows: rows.map((row) {
          return DataRow(
            cells: row.map((cell) => DataCell(Text(cell))).toList(),
          );
        }).toList(),
      ),
    );
  }
}

/// Widget to render all parts of a question or option in sequence
class PartsListRenderer extends StatelessWidget {
  final List<QuestionPart>? questionParts;
  final List<OptionPart>? optionParts;
  final double spacing;
  final TextStyle? textStyle;

  const PartsListRenderer({
    super.key,
    this.questionParts,
    this.optionParts,
    this.spacing = 12.0,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final parts = questionParts ?? [];
    final optParts = optionParts ?? [];

    if (parts.isEmpty && optParts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (parts.isNotEmpty)
          ...parts.map((part) => Padding(
                padding: EdgeInsets.only(bottom: spacing),
                child: PartRenderer(
                  partType: part.partType,
                  content: part.content,
                  contentJson: part.contentJson,
                  media: part.media,
                  textStyle: textStyle,
                ),
              )),
        if (optParts.isNotEmpty)
          ...optParts.map((part) => Padding(
                padding: EdgeInsets.only(bottom: spacing),
                child: PartRenderer(
                  partType: part.partType,
                  content: part.content,
                  media: part.media,
                  textStyle: textStyle,
                ),
              )),
      ],
    );
  }
}

/// Audio player widget
class _AudioPlayerWidget extends StatefulWidget {
  final Media media;

  const _AudioPlayerWidget({required this.media});

  @override
  State<_AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<_AudioPlayerWidget> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  bool _isInitialized = false;
  bool _hasError = false;
  String? _errorMessage;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initAudio();
  }

  Future<void> _initAudio() async {
    try {
      final mediaService = MediaService(ApiClient());
      final url = mediaService.getMediaUrl(widget.media.url);
      
      // Debug: Print the URL being loaded
      print('🎵 AudioPlayer - Loading audio from URL: $url');
      print('🎵 AudioPlayer - Original media URL: ${widget.media.url}');
      print('🎵 AudioPlayer - Media metadata: ${widget.media.metadata}');
      print('🎵 AudioPlayer - Platform: ${Platform.operatingSystem}');

      _audioPlayer.onPlayerStateChanged.listen((state) {
        if (mounted) {
          setState(() {
            _isPlaying = state == PlayerState.playing;
          });
        }
      });

      _audioPlayer.onDurationChanged.listen((duration) {
        if (mounted) {
          setState(() {
            _duration = duration;
          });
        }
      });

      _audioPlayer.onPositionChanged.listen((position) {
        if (mounted) {
          setState(() {
            _position = position;
          });
        }
      });

      // Set source with timeout - use UrlSource for network URLs
      print('🎵 AudioPlayer - Setting source...');
      final source = UrlSource(url);
      await _audioPlayer.setSource(source).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          print('❌ AudioPlayer - Timeout while loading: $url');
          throw TimeoutException('Audio loading timed out after 30 seconds');
        },
      );
      
      print('✅ AudioPlayer - Successfully set source: $url');

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      print('❌ AudioPlayer - Error loading audio: $e');
      print('❌ AudioPlayer - Stack trace: ${StackTrace.current}');
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.resume();
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.error, color: Colors.red[700]),
                const SizedBox(width: 8),
                const Text('Error loading audio'),
              ],
            ),
            if (_errorMessage != null) const SizedBox(height: 4),
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: TextStyle(fontSize: 12, color: Colors.red[600]),
              ),
          ],
        ),
      );
    }

    if (!_isInitialized) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue[200]!),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
              ),
            ),
            const SizedBox(width: 12),
            const Text('Loading audio...'),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.audiotrack, color: Colors.blue[700]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.media.metadata['original_filename'] ?? 'Audio file',
                  style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton(
                icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                onPressed: _togglePlayPause,
                color: Colors.blue[700],
              ),
              Text(
                _formatDuration(_position),
                style: TextStyle(fontSize: 12, color: Colors.blue[700]),
              ),
              Expanded(
                child: Slider(
                  value: _position.inSeconds.toDouble(),
                  max: _duration.inSeconds.toDouble().clamp(1, double.infinity),
                  onChanged: (value) async {
                    await _audioPlayer.seek(Duration(seconds: value.toInt()));
                  },
                ),
              ),
              Text(
                _formatDuration(_duration),
                style: TextStyle(fontSize: 12, color: Colors.blue[700]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Video player widget
class _VideoPlayerWidget extends StatefulWidget {
  final Media media;

  const _VideoPlayerWidget({required this.media});

  @override
  State<_VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<_VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    try {
      final mediaService = MediaService(ApiClient());
      final url = mediaService.getMediaUrl(widget.media.url);

      _controller = VideoPlayerController.networkUrl(Uri.parse(url));
      
      // Initialize with timeout
      await _controller.initialize().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Video loading timed out');
        },
      );

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }

      _controller.addListener(() {
        if (mounted) {
          setState(() {});
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red[200]!),
        ),
        child: Row(
          children: [
            Icon(Icons.error, color: Colors.red[700]),
            const SizedBox(width: 8),
            const Text('Error loading video'),
          ],
        ),
      );
    }

    if (!_isInitialized) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.purple[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.purple[200]!),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: Stack(
              alignment: Alignment.center,
              children: [
                VideoPlayer(_controller),
                if (!_controller.value.isPlaying)
                  IconButton(
                    icon: const Icon(Icons.play_circle_outline, size: 64, color: Colors.white),
                    onPressed: _togglePlayPause,
                  ),
              ],
            ),
          ),
          Container(
            color: Colors.black87,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                  ),
                  onPressed: _togglePlayPause,
                ),
                Text(
                  _formatDuration(_controller.value.position),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                Expanded(
                  child: Slider(
                    value: _controller.value.position.inSeconds.toDouble(),
                    max: _controller.value.duration.inSeconds.toDouble().clamp(1, double.infinity),
                    onChanged: (value) {
                      _controller.seekTo(Duration(seconds: value.toInt()));
                    },
                    activeColor: Colors.white,
                    inactiveColor: Colors.white38,
                  ),
                ),
                Text(
                  _formatDuration(_controller.value.duration),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
