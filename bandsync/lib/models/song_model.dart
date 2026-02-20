class Song {
  final String id;
  final String title;
  final String artist;
  final String? album;
  final String lyrics;
  final String? chords;
  final String key;
  final int tempo;
  final String? filePath;
  final DateTime createdAt;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    this.album,
    required this.lyrics,
    this.chords,
    this.key = 'C',
    this.tempo = 120,
    this.filePath,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Song copyWith({
    String? id,
    String? title,
    String? artist,
    String? album,
    String? lyrics,
    String? chords,
    String? key,
    int? tempo,
    String? filePath,
  }) {
    return Song(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      lyrics: lyrics ?? this.lyrics,
      chords: chords ?? this.chords,
      key: key ?? this.key,
      tempo: tempo ?? this.tempo,
      filePath: filePath ?? this.filePath,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'artist': artist,
      'album': album,
      'lyrics': lyrics,
      'chords': chords,
      'key': key,
      'tempo': tempo,
      'filePath': filePath,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Song.fromMap(Map<String, dynamic> map) {
    return Song(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      artist: map['artist'] ?? '',
      album: map['album'],
      lyrics: map['lyrics'] ?? '',
      chords: map['chords'],
      key: map['key'] ?? 'C',
      tempo: map['tempo'] ?? 120,
      filePath: map['filePath'],
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt']) 
          : DateTime.now(),
    );
  }
}
