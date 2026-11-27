class Admin {
  final int id;
  final String name;
  final String email;
  final String department;

  Admin({
    required this.id,
    required this.name,
    required this.email,
    required this.department,
  });

  factory Admin.fromJson(Map<String, dynamic> json) {
    // department bisa dari 'company.name' (JSONPlaceholder) atau 'department' langsung
    String dept = '';
    if (json['company'] != null && json['company'] is Map) {
      dept = json['company']['name']?.toString() ?? '';
    } else if (json['department'] != null) {
      dept = json['department'].toString();
    }

    return Admin(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      department: dept,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'department': department,
    };
  }
}
