import 'package:flutter/material.dart';
import '../../models/song_model.dart';
import '../../core/chord_transposer.dart';
import '../../core/metronome.dart';

class SongViewerScreen extends StatefulWidget {
  final Song song;
  final List<Song>? setlistSongs;
  final int? currentIndex;

  const SongViewerScreen({
    super.key,
    required this.song,
    this.setlistSongs,
    this.currentIndex,
  });

  @override
  State<SongViewerScreen> createState() => _SongViewerScreenState();
}

class _SongViewerScreenState extends State<SongViewerScreen> {
  int _transpose = 0;
  double _fontSize = 16.0;
  int _currentIndex = 0;
  Song? _currentSong;
  late Metronome _metronome;
  bool _metronomeBeat = false;
  late int _currentTempo;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex ?? 0;
    _currentSong = widget.song;
    _currentTempo = widget.song.tempo;
    _metronome = Metronome(onBeat: (beat) {
      setState(() => _metronomeBeat = beat);
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) setState(() => _metronomeBeat = false);
      });
    });
  }

  @override
  void dispose() {
    _metronome.dispose();
    super.dispose();
  }

  void _navigateSong(int direction) {
    if (widget.setlistSongs == null) return;
    final newIndex = _currentIndex + direction;
    if (newIndex >= 0 && newIndex < widget.setlistSongs!.length) {
      setState(() {
        _currentIndex = newIndex;
        _currentSong = widget.setlistSongs![newIndex];
        _currentTempo = widget.setlistSongs![newIndex].tempo;
        _transpose = 0;
        if (_metronome.isPlaying) {
          _metronome.stop();
          _metronome.start(_currentTempo);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final song = _currentSong ?? widget.song;
    final transposedKey = ChordTransposer.transposeKey(song.key, _transpose);
    final bool hasPrevious = widget.setlistSongs != null && _currentIndex > 0;
    final bool hasNext = widget.setlistSongs != null && _currentIndex < widget.setlistSongs!.length - 1;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(song.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: Icon(_metronome.isPlaying ? Icons.stop : Icons.play_arrow),
            onPressed: () {
              setState(() {
                if (_metronome.isPlaying) {
                  _metronome.stop();
                } else {
                  _metronome.start(_currentTempo);
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.text_decrease),
            onPressed: () => setState(() => _fontSize = (_fontSize - 2).clamp(12, 24)),
          ),
          IconButton(
            icon: const Icon(Icons.text_increase),
            onPressed: () => setState(() => _fontSize = (_fontSize + 2).clamp(12, 24)),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: _metronomeBeat ? Colors.green[100] : Colors.grey[200],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(song.artist, style: const TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Text('Key: $transposedKey', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(Icons.remove, size: 16),
                      onPressed: () {
                        setState(() {
                          _currentTempo = (_currentTempo - 1).clamp(40, 240);
                          if (_metronome.isPlaying) {
                            _metronome.stop();
                            _metronome.start(_currentTempo);
                          }
                        });
                      },
                    ),
                    Text('$_currentTempo BPM'),
                    IconButton(
                      icon: const Icon(Icons.add, size: 16),
                      onPressed: () {
                        setState(() {
                          _currentTempo = (_currentTempo + 1).clamp(40, 240);
                          if (_metronome.isPlaying) {
                            _metronome.stop();
                            _metronome.start(_currentTempo);
                          }
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Text(
                _transposeLyrics(song.lyrics),
                style: TextStyle(fontSize: _fontSize, fontFamily: 'monospace'),
              ),
            ),
          ),
          if (widget.setlistSongs != null)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              color: Colors.grey[200],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.skip_previous),
                    onPressed: hasPrevious ? () => _navigateSong(-1) : null,
                  ),
                  Text('${_currentIndex + 1} / ${widget.setlistSongs!.length}'),
                  IconButton(
                    icon: const Icon(Icons.skip_next),
                    onPressed: hasNext ? () => _navigateSong(1) : null,
                  ),
                ],
              ),
            ),
          _buildTransposeBar(),
        ],
      ),
    );
  }

  String _transposeLyrics(String lyrics) {
    if (_transpose == 0) return lyrics;
    
    return lyrics.replaceAllMapped(
      RegExp(r'\b([A-G][#b]?(?:m|maj|min|dim|aug|sus|add|[0-9])*)\b'),
      (match) => ChordTransposer.transpose(match.group(1)!, _transpose),
    );
  }

  Widget _buildTransposeBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.grey[100],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: () => setState(() => _transpose--),
          ),
          Text('Transpose: $_transpose', style: const TextStyle(fontWeight: FontWeight.bold)),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => setState(() => _transpose++),
          ),
        ],
      ),
    );
  }
}
