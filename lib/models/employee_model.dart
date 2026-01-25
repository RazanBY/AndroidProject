class Employee {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? teamId;
  final String? teamName;
  final int totalJobsCompleted;
  final double? rating;
  final String? profileImage;

  Employee({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.teamId,
    this.teamName,
    this.totalJobsCompleted = 0,
    this.rating,
    this.profileImage,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      teamId: json['teamId'],
      teamName: json['teamName'],
      totalJobsCompleted: json['totalJobsCompleted'] ?? 0,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      profileImage: json['profileImage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'teamId': teamId,
      'teamName': teamName,
      'totalJobsCompleted': totalJobsCompleted,
      'rating': rating,
      'profileImage': profileImage,
    };
  }
}



