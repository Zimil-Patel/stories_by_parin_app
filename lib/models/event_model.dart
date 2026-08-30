class Event {
  final int id;
  final String name;
  final String createdAt;

  const Event({required this.id, required this.name, required this.createdAt});

  factory Event.fromJson(Map<String, dynamic> json) =>
      Event(
        id: json['id'],
        name: json['name'],
        createdAt: json['created_at'],
      );
}
