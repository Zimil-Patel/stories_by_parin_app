class Photo {
  final int id;
  final String filename;
  final String status;
  final String createdAt;
  final int height;
  final int width;
  final bool isFavourite;

  Photo({
    required this.id,
    required this.filename,
    required this.status,
    required this.createdAt,
    required this.height,
    required this.width,
    required this.isFavourite,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id'],
      filename: json['filename'],
      status: json['status'],
      createdAt: json['created_at'],
      height: json['height'],
      width: json['width'],
      isFavourite:
      json['is_favourite'] == true ||
          json['is_favourite'] == 1,
    );
  }

  Photo copyWith({
    bool? isFavourite,
  }) {
    return Photo(
      id: id,
      filename: filename,
      status: status,
      createdAt: createdAt,
      height: height,
      width: width,
      isFavourite: isFavourite ?? this.isFavourite,
    );
  }
}