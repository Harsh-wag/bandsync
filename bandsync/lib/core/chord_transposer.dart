class ChordTransposer {
  static const List<String> _notes = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'];
  static const Map<String, String> _flatsToSharps = {
    'Db': 'C#', 'Eb': 'D#', 'Gb': 'F#', 'Ab': 'G#', 'Bb': 'A#'
  };

  static String transpose(String chord, int semitones) {
    if (chord.isEmpty) return chord;

    final rootMatch = RegExp(r'^([A-G][#b]?)').firstMatch(chord);
    if (rootMatch == null) return chord;

    String root = rootMatch.group(1)!;
    final suffix = chord.substring(root.length);
    
    // Convert flats to sharps
    if (_flatsToSharps.containsKey(root)) {
      root = _flatsToSharps[root]!;
    }
    
    int index = _notes.indexOf(root);
    if (index == -1) return chord;

    index = (index + semitones) % 12;
    if (index < 0) index += 12;
    
    return _notes[index] + suffix;
  }

  static String transposeKey(String key, int semitones) {
    return transpose(key, semitones);
  }
}
