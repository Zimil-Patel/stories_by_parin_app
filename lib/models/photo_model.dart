class Photo {
  final int id;
  final String filename;
  final String status;
  final String createdAt;

  Photo({
    required this.id,
    required this.filename,
    required this.status,
    required this.createdAt,
  });

  factory Photo.fromJson(Map<String, dynamic> json) => Photo(
    id: json['id'],
    filename: json['filename'],
    status: json['status'],
    createdAt: json['created_at'],
  );
}
