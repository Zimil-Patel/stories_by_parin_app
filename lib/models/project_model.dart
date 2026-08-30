class Project {
  final int id;
  final String name;
  final String createdAt;

  const Project({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  factory Project.fromJson(Map<String, dynamic> json) =>
      Project(
          id: json['id'],
          name: json['name'],
          createdAt: json['created_at'],
      );
}
