class User {
  final String guid;
  final String email;
  final String firstName;
  final String lastName;
  final List<int> role;

  User({
    required this.guid,
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
    // Parse roles
    List<int> rolesList = [];
    var rolesData = json['role'] ?? json['roles'];

    if (rolesData != null) {
      if (rolesData is int) {
        rolesList = [rolesData];
      } else if (rolesData is List) {
        rolesList = rolesData
            .map((r) => int.tryParse(r.toString()) ?? 0)
            .where((r) => r > 0)
            .toList()
            .cast<int>();
      } else if (rolesData.toString().isNotEmpty) {
        rolesList = rolesData
            .toString()
            .split(',')
            .map((role) => int.tryParse(role.trim()) ?? 0)
            .where((role) => role > 0)
            .toList();
      }
    }

    return User(
      guid: json['guid'] ?? json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      role: rolesList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'guid': guid,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'role': role,
    };
  }
}
