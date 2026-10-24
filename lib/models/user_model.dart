class UserModel {
  final int id;
  final String firebaseUid;
  final String firstName;
  final String lastName;
  final bool isAdmin;
  final String email;
  final bool emailVerified;
  final String? mobileNumber;
  final String? photoUrl;
  final String createdAt;
  final String updatedAt;

  const UserModel({
    required this.id,
    required this.firebaseUid,
    required this.firstName,
    required this.lastName,
    required this.isAdmin,
    required this.email,
    required this.emailVerified,
    required this.mobileNumber,
    required this.photoUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      firebaseUid: json['firebase_uid'] as String,
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      isAdmin: json['is_admin'] as bool? ?? false,
      email: json['email'] as String,
      emailVerified: json['email_verified'] as bool? ?? false,
      mobileNumber: json['mobile_number'] as String?,
      photoUrl: json['photo_url'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  String get fullName {
    return '$firstName $lastName'.trim();
  }
}