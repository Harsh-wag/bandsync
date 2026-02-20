class Setlist {
  final String id;
  final String name;
  final List<String> songIds;
  final DateTime createdAt;

  Setlist({
    required this.id,
    required this.name,
    List<String>? songIds,
    DateTime? createdAt,
  }) : songIds = songIds ?? [],
       createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'songIds': songIds,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Setlist.fromMap(Map<String, dynamic> map) {
    return Setlist(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      songIds: List<String>.from(map['songIds'] ?? []),
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }
}
