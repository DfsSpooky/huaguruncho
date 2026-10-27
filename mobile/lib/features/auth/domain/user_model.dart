class UserModel {
  final int id;
  final String email;
  final String fullName;
  final String? phone;
  final String role;

  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.phone,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      phone: json['phone'] as String?,
      role: json['role'] as String? ?? 'turista',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'full_name': fullName,
    'phone': phone,
    'role': role,
  };

  bool get isRangerOrAdmin =>
      role == 'guardaparque' || role == 'municipalidad' || role == 'administrador';
}
