// lib/data/models/car_model.dart

class CarModel {
  final String id;
  final String customerUid;
  final String brand;
  final String plate;
  final String year;
  final String color;

  const CarModel({
    required this.id,
    required this.customerUid,
    required this.brand,
    required this.plate,
    required this.year,
    required this.color,
  });

  factory CarModel.fromMap(String docId, Map<String, dynamic> map) {
    return CarModel(
      id: docId,
      customerUid: map['customerUid'] ?? '',
      brand: map['brand'] ?? '',
      plate: map['plate'] ?? '',
      year: map['year'] ?? '',
      color: map['color'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customerUid': customerUid,
      'brand': brand,
      'plate': plate,
      'year': year,
      'color': color,
    };
  }
}