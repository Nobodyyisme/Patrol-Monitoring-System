class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final String phone;
  final String badgeNumber;
  final String department;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.phone,
    required this.badgeNumber,
    required this.department,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      phone: json['phone'] ?? '',
      badgeNumber: json['badgeNumber'] ?? '',
      department: json['department'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'role': role,
    'phone': phone,
    'badgeNumber': badgeNumber,
    'department': department,
  };
}
