// файл: models/user_model.dart

class UserModel {
  final String fullName;
  final String email;
  final String password;
  final String age;
  final String gender;
  final String country;
  final String avatarUrl;

  UserModel({
    required this.fullName,
    required this.email,
    required this.password,
    required this.age,
    required this.gender,
    required this.country,
    required this.avatarUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'password': password,
      'age': age,
      'gender': gender,
      'country': country,
      'avatarUrl': avatarUrl,
    };
  }

  // Метод для создания объекта UserModel из JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      fullName: json['fullName'],
      email: json['email'],
      password: json['password'],
      age: json['age'],
      gender: json['gender'],
      country: json['country'],
      avatarUrl: json['avatarUrl'],
    );
  }
}
