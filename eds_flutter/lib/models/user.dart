class User {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final List<int> role;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
  });

  // Convenience getters for role checking
  bool get isChild => role.contains(1);
  bool get isParent => role.contains(2);
  bool get isInstructor => role.contains(3);

  // Get primary role (first in the list)
  int get primaryRole => role.isNotEmpty ? role.first : 0;

  String get fullName => '$firstName $lastName';

  factory User.fromJson(Map<String, dynamic> json) {
    // Parse roles from comma-separated string "1,2,3" to List<int>
    List<int> rolesList = [];

    // Check 'role' first (new preference), then fallback to 'roles'
    var rolesData = json['role'] ?? json['roles'];

    if (rolesData != null && rolesData.toString().isNotEmpty) {
      rolesList = rolesData
          .toString()
          .split(',')
          .map((role) => int.tryParse(role.trim()) ?? 0)
          .where((role) => role > 0)
          .toList();
    }

    return User(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      role: rolesList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'role': role,
    };
  }
}
