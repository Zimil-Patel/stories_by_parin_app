class Project {
  // The actual project ID used for existing navigation.
  final int id;

  final String name;
  final String createdAt;

  // Gallery information is populated by GET /my-galleries.
  final int? galleryId;
  final GalleryRole? role;
  final bool? isGalleryEnabled;

  const Project({
    required this.id,
    required this.name,
    required this.createdAt,
    this.galleryId,
    this.role,
    this.isGalleryEnabled,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    // Distinguish /my-galleries responses from /projects responses.
    final isGalleryResponse = json.containsKey('project_id');

    return Project(
      id: isGalleryResponse
          ? json['project_id'] as int
          : json['id'] as int,

      name: isGalleryResponse
          ? json['project_name'] as String
          : json['name'] as String,

      createdAt: json['created_at'] as String,

      galleryId: isGalleryResponse
          ? json['id'] as int
          : null,

      role: isGalleryResponse
          ? GalleryRole.fromJson(json['role'])
          : null,

      isGalleryEnabled: isGalleryResponse
          ? json['is_enabled'] == true ||
          json['is_enabled'] == 1
          : null,
    );
  }

  // Convenient, type-safe role checks.
  bool get isOwner => role == GalleryRole.owner;

  bool get isViewer => role == GalleryRole.viewer;
}

enum GalleryRole{
  owner,
  viewer;

  static GalleryRole? fromJson(Object? value) {
    switch(value) {
      case 'owner':
        return GalleryRole.owner;

      case 'viewer':
        return GalleryRole.viewer;

      default:
        return null;
    }
  }

  String? toJson() => name;
}
