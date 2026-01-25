class ServiceModel {
  final int id;
  final String name;
  final int price;
  final int duration;

  ServiceModel({
    required this.id,
    required this.name,
    required this.price,
    required this.duration,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'],
      name: json['name'],
      price: json['price'] is int
          ? json['price']
          : int.parse(json['price'].toString()),
      duration: json['duration'] is int
          ? json['duration']
          : int.parse(json['duration'].toString()),
    );
  }
}
