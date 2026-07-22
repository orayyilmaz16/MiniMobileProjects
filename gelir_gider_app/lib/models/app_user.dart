class AppUser {
  final String? id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? profilePhoto;

  AppUser({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.profilePhoto,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    id: json['id'] as String?,
    firstName: json['first_name'] as String?,
    lastName: json['last_name'] as String?,
    email: json['email'] as String?,
    profilePhoto: json['profile_photo'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'first_name': firstName,
    'last_name': lastName,
    'email': email,
    'profile_photo': profilePhoto,
  };
}
