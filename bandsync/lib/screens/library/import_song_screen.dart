import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../state/library_provider.dart';
import '../../models/song_model.dart';

class ImportSongScreen extends StatefulWidget {
  const ImportSongScreen({super.key});

  @override
  State<ImportSongScreen> createState() => _ImportSongScreenState();
}

class _ImportSongScreenState extends State<ImportSongScreen> {
  final _titleController = TextEditingController();
  final _artistController = TextEditingController();
  String? _fileName;

  @override
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );
    if (result != null) {
      setState(() => _fileName = result.files.single.name);
    }
  }

  void _saveSong() {
    if (_titleController.text.isNotEmpty && _artistController.text.isNotEmpty) {
      Provider.of<LibraryProvider>(context, listen: false).addSong(
        Song(
          id: DateTime.now().toString(),
          title: _titleController.text,
          artist: _artistController.text,
          lyrics: '',
          filePath: _fileName,
          key: 'C',
          tempo: 120,
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Song added to library!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import Song'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveSong,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Song Title',
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
          ListTile(
            title: Text(_fileName ?? 'No file selected'),
            subtitle: const Text('Tap to select audio file'),
            trailing: const Icon(Icons.attach_file),
            onTap: _pickFile,
          ),
        ],
      ),
    );
  }
}
