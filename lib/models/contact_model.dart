class Contact {
  final int? id; // null عند الإضافة لأن السيرفر هو اللي بعطي الـ id
  final String name;
  final String email;
  final String phone;

  const Contact({this.id, required this.name, required this.email, required this.phone});

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'] as int?,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'name': name,
    'email': email,
    'phone': phone,
  };

  Contact copyWith({int? id, String? name, String? email, String? phone}) {
    return Contact(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
    );
  }
}
