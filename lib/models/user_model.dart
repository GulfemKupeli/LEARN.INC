class UserModel {
  final String uid;
  final String fullName;
  final String email;
  final String profileImage;
  final String role;
  final int points;
  final int lives;
  final int streakDays;
  final Map<String, dynamic> roleSpecificData;

  const UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.profileImage,
    required this.role,
    this.points = 0,
    this.lives = 8,
    this.streakDays = 0,
    this.roleSpecificData = const {},
  });

  // CopyWith Method
  UserModel copyWith({
    String? uid,
    String? fullName,
    String? email,
    String? profileImage,
    String? role,
    int? points,
    int? lives,
    int? streakDays,
    Map<String, dynamic>? roleSpecificData,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      role: role ?? this.role,
      points: points ?? this.points,
      lives: lives ?? this.lives,
      streakDays: streakDays ?? this.streakDays,
      roleSpecificData: roleSpecificData ?? this.roleSpecificData,
    );
  }

  // toJson Method for Firebase
  Map<String, dynamic> toJson() {
    return {
      "Uid": uid,
      "FullName": fullName,
      "Email": email,
      "ProfileImage": profileImage,
      "Role": role,
      "Points": points,
      "Lives": lives,
      "StreakDays": streakDays,
      "RoleSpecificData": roleSpecificData,
    };
  }

  // fromJson Method for Firebase
  static UserModel fromJson(Map<String, dynamic> json, String uid, Map<String, dynamic> roleSpecificData) {
    return UserModel(
      uid: uid,
      fullName: json['FullName'] ?? '',
      email: json['Email'] ?? '',
      profileImage: json['ProfileImage'] ?? '',
      role: json['Role'] ?? 'member',
      points: json['Points'] ?? 0,
      lives: json['Lives'] ?? 8,
      streakDays: json['StreakDays'] ?? 0,
      roleSpecificData: roleSpecificData,
    );
  }
}
