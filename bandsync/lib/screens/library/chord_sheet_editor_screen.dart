import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/song_model.dart';
import '../../state/library_provider.dart';

class ChordSheetEditorScreen extends StatefulWidget {
  final Song? song;

  const ChordSheetEditorScreen({super.key, this.song});

  @override
  State<ChordSheetEditorScreen> createState() => _ChordSheetEditorScreenState();
}

class _ChordSheetEditorScreenState extends State<ChordSheetEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _artistController;
  late TextEditingController _keyController;
  late TextEditingController _lyricsController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.song?.title ?? '');
    _artistController = TextEditingController(text: widget.song?.artist ?? '');
    _keyController = TextEditingController(text: widget.song?.key ?? '');
    _lyricsController = TextEditingController(text: widget.song?.lyrics ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
    _keyController.dispose();
    _lyricsController.dispose();
    super.dispose();
  }

  void _save() {
    if (_titleController.text.isEmpty) return;

    final song = Song(
      id: widget.song?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      artist: _artistController.text,
      key: _keyController.text,
      lyrics: _lyricsController.text,
    );

    final provider = Provider.of<LibraryProvider>(context, listen: false);
    if (widget.song == null) {
      provider.addSong(song);
    } else {
      provider.updateSong(song);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.song == null ? 'Create Chord Sheet' : 'Edit Chord Sheet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _save,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Title',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _artistController,
            decoration: const InputDecoration(
              labelText: 'Artist',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _keyController,
            decoration: const InputDecoration(
              labelText: 'Key',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _lyricsController,
            decoration: const InputDecoration(
              labelText: 'Lyrics & Chords',
              hintText: 'Type chords in brackets like [C] [G] [Am]\nThen add lyrics below',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            maxLines: null,
            minLines: 15,
            style: const TextStyle(fontFamily: 'monospace'),
          ),
        ],
      ),
    );
  }
}
