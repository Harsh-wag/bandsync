class KeyDetector {
  static const Map<String, List<String>> _majorKeys = {
    'C': ['C', 'Dm', 'Em', 'F', 'G', 'Am', 'Bdim'],
    'G': ['G', 'Am', 'Bm', 'C', 'D', 'Em', 'F#dim'],
    'D': ['D', 'Em', 'F#m', 'G', 'A', 'Bm', 'C#dim'],
    'A': ['A', 'Bm', 'C#m', 'D', 'E', 'F#m', 'G#dim'],
    'E': ['E', 'F#m', 'G#m', 'A', 'B', 'C#m', 'D#dim'],
    'F': ['F', 'Gm', 'Am', 'Bb', 'C', 'Dm', 'Edim'],
  };

  static String detectKey(String lyrics) {
    // Extract chords from lyrics
    final chordPattern = RegExp(r'\b([A-G][#b]?(?:m|maj|min|dim|aug|sus|add|[0-9])*)\b');
    final matches = chordPattern.allMatches(lyrics);
    
    if (matches.isEmpty) return 'Unknown';
    
    // Count chord occurrences
    final Map<String, int> chordCounts = {};
    for (var match in matches) {
      final chord = match.group(1)!;
      final root = _getChordRoot(chord);
      chordCounts[root] = (chordCounts[root] ?? 0) + 1;
    }
    
    // Find most likely key
    String bestKey = 'C';
    int bestScore = 0;
    
    _majorKeys.forEach((key, chords) {
      int score = 0;
      chordCounts.forEach((chord, count) {
        if (chords.any((c) => c.startsWith(chord))) {
          score += count;
        }
      });
      
      if (score > bestScore) {
        bestScore = score;
        bestKey = key;
      }
    });
    
    return bestKey;
  }
  
  static String _getChordRoot(String chord) {
    final match = RegExp(r'^([A-G][#b]?)').firstMatch(chord);
    return match?.group(1) ?? chord;
  }
  
  static String detectScale(String key) {
    // Simple major/minor detection based on common patterns
    return '$key Major'; // Can be enhanced to detect minor
  }
}
