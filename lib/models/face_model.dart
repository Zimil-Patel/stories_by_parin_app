class Person {
  final int clusterId;
  final int faceId;
  final int photoId;
  final int photoCount;

  Person({required this.clusterId,required this.faceId,required this.photoId,required this.photoCount});

  factory Person.fromJson(Map<String, dynamic> json) => Person(clusterId: json['cluster_id'], faceId: json['face_id'], photoId: json['photo_id'], photoCount: json['photo_count']);
}