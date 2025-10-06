class Emote {
  final String id;
  final String name;
  final String spritePath;

  Emote({
    required this.id,
    required this.name,
    required this.spritePath,
  });

  factory Emote.fromJson(Map<String, dynamic> json) {
    return Emote(
      id: json['id'],
      name: json['name'],
      spritePath: json['sprite_path'],
    );
  }
}