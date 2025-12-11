class User {
  final String token;
  final String userApiUrl;
  final String email;
  final String? timezone;

  User({
    required this.token,
    required this.userApiUrl,
    required this.email,
    this.timezone,
  });

  factory User.fromLoginResponse(Map<String, dynamic> json, String email) {
    final data = json['data'] as Map<String, dynamic>;
    return User(
      token: data['token'] as String,
      userApiUrl: data['user_api_url'] as String,
      email: email,
      timezone: data['timezone'] as String?,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      token: json['token'] as String,
      userApiUrl: json['user_api_url'] as String,
      email: json['email'] as String,
      timezone: json['timezone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'user_api_url': userApiUrl,
      'email': email,
      'timezone': timezone,
    };
  }

  User copyWith({
    String? token,
    String? userApiUrl,
    String? email,
    String? timezone,
  }) {
    return User(
      token: token ?? this.token,
      userApiUrl: userApiUrl ?? this.userApiUrl,
      email: email ?? this.email,
      timezone: timezone ?? this.timezone,
    );
  }
}
