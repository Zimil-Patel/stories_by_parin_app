import 'photo_model.dart';

class SelfieSearchResult {
  final bool success;
  final int? clusterId;
  final int photosCount;
  final List<Photo> photos;
  final String? reason;
  final String? message;

  const SelfieSearchResult({
    required this.success,
    this.clusterId,
    required this.photosCount,
    required this.photos,
    this.reason,
    this.message,
  });

  factory SelfieSearchResult.fromJson(
      Map<String, dynamic> json,
      ) {
    final photosJson = json['photos'] as List<dynamic>? ?? [];

    return SelfieSearchResult(
      success: json['success'] as bool? ?? false,

      clusterId: json['cluster_id'] as int?,

      photosCount: json['photos_count'] as int? ?? 0,

      photos: photosJson
          .map(
            (photo) => Photo.fromJson(
          photo as Map<String, dynamic>,
        ),
      )
          .toList(),

      reason: json['reason'] as String?,

      message: json['message'] as String?,

    );
  }
}