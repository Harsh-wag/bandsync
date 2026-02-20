import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/library_provider.dart';
import '../../models/song_model.dart';

class LyricsScreen extends StatelessWidget {
  const LyricsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Lyrics'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const Center(child: Text('No lyrics uploaded')),
    );
  }
}

class UploadLyricsScreen extends StatefulWidget {
  const UploadLyricsScreen({super.key});

  @override
  State<UploadLyricsScreen> createState() => _UploadLyricsScreenState();
}

class _UploadLyricsScreenState extends State<UploadLyricsScreen> {
  final _titleController = TextEditingController();
  final _lyricsController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _lyricsController.dispose();
    super.dispose();
  }

  void _saveLyrics() {
    if (_titleController.text.isNotEmpty && _lyricsController.text.isNotEmpty) {
      Provider.of<LibraryProvider>(context, listen: false).addSong(
        Song(
          id: DateTime.now().toString(),
          title: _titleController.text,
          artist: 'Unknown',
          lyrics: _lyricsController.text,
          key: 'C',
          tempo: 120,
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Song saved!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Lyrics'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveLyrics,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Song Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _lyricsController,
                decoration: const InputDecoration(
                  labelText: 'Lyrics',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
