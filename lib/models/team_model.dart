class Team {
  final int id;
  final String teamName;
  final String carNumber;
  final String status; // available, busy

  Team({
    required this.id,
    required this.teamName,
    required this.carNumber,
    required this.status,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'] as int,
      teamName: json['team_name'] as String,
      carNumber: json['car_number'] as String,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'team_name': teamName,
      'car_number': carNumber,
      'status': status,
    };
  }
}

