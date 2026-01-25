class Car {
  final int id;
  final int userId;
  final String carModel;
  final String plateNumber;
  final String? color;

  Car({
    required this.id,
    required this.userId,
    required this.carModel,
    required this.plateNumber,
    this.color,
  });

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      carModel: json['car_model'] as String,
      plateNumber: json['plate_number'] as String,
      color: json['color'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'car_model': carModel,
      'plate_number': plateNumber,
      if (color != null) 'color': color,
    };
  }
}

