import 'package:stories_by_parin/models/project_model.dart';

class GalleryMember {
  final int id;
  final int galleryId;
  final String email;
  final int? userId;
  final GalleryRole? role;
  final int? invitedByUserId;
  final bool isRegistered;
  final String? firstName;
  final String? lastName;
  final String? fullName;
  final String? photoUrl;
  final String createdAt;
  final String updatedAt;

  const GalleryMember({
    required this.id,
    required this.galleryId,
    required this.email,
    required this.userId,
    required this.role,
    required this.invitedByUserId,
    required this.isRegistered,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.photoUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GalleryMember.fromJson(Map<String, dynamic> json) {
    return GalleryMember(
      id: json['id'] as int,
      galleryId: json['gallery_id'] as int,
      email: json['email'] as String,
      userId: json['user_id'] as int?,
      role: GalleryRole.fromJson(json['role']),
      invitedByUserId: json['invited_by_user_id'] as int?,
      isRegistered: json['is_registered'] == true,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      fullName: json['full_name'] as String?,
      photoUrl: json['photo_url'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  bool get isOwner => role == GalleryRole.owner;

  bool get isViewer => role == GalleryRole.viewer;

  /// Email is shown when the invitee hasn't registered
  /// or their profile doesn't have a name yet.
  String get displayName {
    final name = fullName?.trim();
    return name != null && name.isNotEmpty ? name : email;
  }
}