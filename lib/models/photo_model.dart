class Photo {
  final int id;
  final String filename;
  final String status;
  final String createdAt;

  final int height;
  final int width;

  Photo({
    required this.id,
    required this.filename,
    required this.status,
    required this.createdAt,
    required this.height,
    required this.width,
  });

  factory Photo.fromJson(Map<String, dynamic> json) => Photo(
    id: json['id'],
    filename: json['filename'],
    status: json['status'],
    createdAt: json['created_at'],
    height: json['height'],
    width: json['width'],
  );
}
