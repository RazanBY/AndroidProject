class Job {
  final String id;
  final String customerName;
  final String carModel;
  final String carPlate;
  final String serviceType;
  final String location;
  final String address;
  final String status;
  final String date;
  final String time;
  final double price;
  final String? employeeId;
  final String? teamId;
  final String? notes;

  Job({
    required this.id,
    required this.customerName,
    required this.carModel,
    required this.carPlate,
    required this.serviceType,
    required this.location,
    required this.address,
    required this.status,
    required this.date,
    required this.time,
    required this.price,
    this.employeeId,
    this.teamId,
    this.notes,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'] ?? '',
      customerName: json['customerName'] ?? '',
      carModel: json['carModel'] ?? '',
      carPlate: json['carPlate'] ?? '',
      serviceType: json['serviceType'] ?? '',
      location: json['location'] ?? '',
      address: json['address'] ?? '',
      status: json['status'] ?? 'Pending',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      employeeId: json['employeeId'],
      teamId: json['teamId'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerName': customerName,
      'carModel': carModel,
      'carPlate': carPlate,
      'serviceType': serviceType,
      'location': location,
      'address': address,
      'status': status,
      'date': date,
      'time': time,
      'price': price,
      'employeeId': employeeId,
      'teamId': teamId,
      'notes': notes,
    };
  }

  Job copyWith({
    String? id,
    String? customerName,
    String? carModel,
    String? carPlate,
    String? serviceType,
    String? location,
    String? address,
    String? status,
    String? date,
    String? time,
    double? price,
    String? employeeId,
    String? teamId,
    String? notes,
  }) {
    return Job(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      carModel: carModel ?? this.carModel,
      carPlate: carPlate ?? this.carPlate,
      serviceType: serviceType ?? this.serviceType,
      location: location ?? this.location,
      address: address ?? this.address,
      status: status ?? this.status,
      date: date ?? this.date,
      time: time ?? this.time,
      price: price ?? this.price,
      employeeId: employeeId ?? this.employeeId,
      teamId: teamId ?? this.teamId,
      notes: notes ?? this.notes,
    );
  }
}


