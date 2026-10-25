/// One giveaway returned by https://www.gamerpower.com/api/giveaways
class Giveaway {
  const Giveaway({
    required this.id,
    required this.title,
    required this.worth,
    required this.thumbnail,
    required this.image,
    required this.description,
    required this.instructions,
    required this.openGiveawayUrl,
    required this.publishedDate,
    required this.type,
    required this.platforms,
    required this.endDate,
    required this.users,
    required this.status,
    required this.gamerpowerUrl,
  });

  final int id;
  final String title;
  final String worth; // e.g. "$19.99" or "N/A"
  final String thumbnail;
  final String image;
  final String description;
  final String instructions;
  final String openGiveawayUrl;
  final String publishedDate;
  final String type; // Game, DLC, Early Access, ...
  final String platforms; // comma separated
  final String endDate; // "N/A" when there is no end date
  final int users;
  final String status;
  final String gamerpowerUrl;

  bool get hasWorth => worth.isNotEmpty && worth.toUpperCase() != 'N/A';
  bool get hasEndDate => endDate.isNotEmpty && endDate.toUpperCase() != 'N/A';

  List<String> get platformList => platforms
      .split(',')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();

  factory Giveaway.fromJson(Map<String, dynamic> json) => Giveaway(
        id: _int(json['id']),
        title: _str(json['title']),
        worth: _str(json['worth'], fallback: 'N/A'),
        thumbnail: _str(json['thumbnail']),
        image: _str(json['image']),
        description: _str(json['description']),
        instructions: _str(json['instructions']),
        openGiveawayUrl: _str(json['open_giveaway_url']),
        publishedDate: _str(json['published_date']),
        type: _str(json['type']),
        platforms: _str(json['platforms']),
        endDate: _str(json['end_date'], fallback: 'N/A'),
        users: _int(json['users']),
        status: _str(json['status']),
        gamerpowerUrl: _str(json['gamerpower_url']),
      );
}

String _str(Object? v, {String fallback = ''}) {
  if (v == null) return fallback;
  final s = v.toString();
  return s.isEmpty ? fallback : s;
}

int _int(Object? v) {
  if (v is int) return v;
  return int.tryParse(v?.toString() ?? '') ?? 0;
}
