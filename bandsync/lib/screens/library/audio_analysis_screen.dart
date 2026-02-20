import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../services/audio_analysis_service.dart';

class AudioAnalysisScreen extends StatefulWidget {
  const AudioAnalysisScreen({super.key});

  @override
  State<AudioAnalysisScreen> createState() => _AudioAnalysisScreenState();
}

class _AudioAnalysisScreenState extends State<AudioAnalysisScreen> {
  bool _isAnalyzing = false;
  Map<String, dynamic>? _analysisResult;
  String? _errorMessage;

  Future<void> _pickAndAnalyzeAudio() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _isAnalyzing = true;
          _errorMessage = null;
          _analysisResult = null;
        });

        final analysisResult = await AudioAnalysisService.analyzeAudio(
          result.files.single.path!,
        );

        setState(() {
          _analysisResult = analysisResult;
          _isAnalyzing = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isAnalyzing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Audio Analysis'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(Icons.audiotrack, size: 64, color: Colors.deepPurple),
                    const SizedBox(height: 16),
                    const Text(
                      'Upload Audio for Analysis',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Get AI-powered chord recognition and key detection',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _isAnalyzing ? null : _pickAndAnalyzeAudio,
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Select Audio File'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_isAnalyzing)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Analyzing audio...'),
                    ],
                  ),
                ),
              ),
            if (_errorMessage != null)
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
            if (_analysisResult != null) ...[
              _buildBasicInfo(),
              const SizedBox(height: 16),
              _buildChordProgression(),
              const SizedBox(height: 16),
              _buildChordTimeline(),
              if (_analysisResult!['ai_insights'] != null) ...[
                const SizedBox(height: 16),
                _buildAIInsights(),
              ],
              if (_analysisResult!['similar_songs'] != null &&
                  (_analysisResult!['similar_songs'] as List).isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildSimilarSongs(),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Song Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            _buildInfoRow('Key', '${_analysisResult!['key']} ${_analysisResult!['scale']}'),
            _buildInfoRow('Tempo', '${_analysisResult!['tempo']} BPM'),
            _buildInfoRow('Duration', '${_analysisResult!['duration']}s'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildChordProgression() {
    final progression = _analysisResult!['chord_progression'] as List;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chord Progression',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: progression.map((chord) {
                return Chip(
                  label: Text(
                    chord.toString(),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: Colors.deepPurple.shade100,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChordTimeline() {
    final timeline = _analysisResult!['chords_timeline'] as List;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chord Timeline',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: timeline.length,
              itemBuilder: (context, index) {
                final chord = timeline[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(chord['chord'].toString()),
                  ),
                  title: Text(chord['chord'].toString()),
                  subtitle: Text('Duration: ${chord['duration']}s'),
                  trailing: Text('${chord['start']}s'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIInsights() {
    return Card(
      color: Colors.purple.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.psychology, color: Colors.purple.shade700),
                const SizedBox(width: 8),
                const Text(
                  'AI Insights',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(),
            Text(
              _analysisResult!['ai_insights'].toString(),
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimilarSongs() {
    final songs = _analysisResult!['similar_songs'] as List;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Similar Songs',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            ...songs.map((song) => ListTile(
              leading: const Icon(Icons.music_note),
              title: Text(song.toString()),
            )),
          ],
        ),
      ),
    );
  }
}
