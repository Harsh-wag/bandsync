class Band {
  final String id;
  final String name;
  final String inviteCode;
  final String createdBy;
  final DateTime createdAt;

  Band({
    required this.id,
    required this.name,
    required this.inviteCode,
    required this.createdBy,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'invite_code': inviteCode,
      'created_by': createdBy,
    };
  }

  factory Band.fromMap(Map<String, dynamic> map) {
    return Band(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      inviteCode: map['invite_code'] ?? '',
      createdBy: map['created_by'] ?? '',
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
    );
  }
}
