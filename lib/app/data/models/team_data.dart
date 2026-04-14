class TeamData {
  final String id;
  final String name;
  final String? imageUrl;
  final String? shortName;

  TeamData({
    required this.id,
    required this.name,
    this.imageUrl,
    this.shortName,
  });

  factory TeamData.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw Exception('TeamData is null');
    }
    return TeamData(
      id: (json['_id'] as String?) ?? (json['id'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      imageUrl: json['imageUrl'] as String?,
      shortName: json['shortName'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'id': id,
    'name': name,
    'imageUrl': imageUrl,
    'shortName': shortName,
  };
}
