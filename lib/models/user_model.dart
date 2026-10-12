/// Model representing a demo user in the boilerplate.
class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String phone;
  final String department;
  final String? avatarUrl;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.phone,
    required this.department,
    this.avatarUrl,
  });

  /// Creates a copy with optionally updated fields
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? phone,
    String? department,
    String? avatarUrl,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      department: department ?? this.department,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  /// Converts model to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'phone': phone,
      'department': department,
      'avatarUrl': avatarUrl,
    };
  }

  /// Creates model from Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      role: map['role'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      department: map['department'] as String? ?? '',
      avatarUrl: map['avatarUrl'] as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.role == role &&
        other.phone == phone &&
        other.department == department &&
        other.avatarUrl == avatarUrl;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        email.hashCode ^
        role.hashCode ^
        phone.hashCode ^
        department.hashCode ^
        avatarUrl.hashCode;
  }
}
