class User {
  final int id;
  final String username;
  final String email;
  final String? profilePicture;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.profilePicture,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      profilePicture: json['profile_picture'],
    );
  }

  User copyWith({
    String? username,
    String? email,
    String? profilePicture,
  }) {
    return User(
      id: id,
      username: username ?? this.username,
      email: email ?? this.email,
      profilePicture: profilePicture ?? this.profilePicture,
    );
  }
}
