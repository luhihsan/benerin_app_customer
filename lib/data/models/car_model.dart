// lib/data/models/car_model.dart

class CarModel {
  final String id;
  final String customerUid;
  final String brand;      // Dropdown: Honda, Toyota, dll.
  final String type;       // Isian teks: Civic, Innova Zenix, dll.
  final String plate;      // Isian teks: Nomor Polisi
  final String year;       // Isian teks: Tahun Rilis
  final String color;      // Isian teks: Warna Unit
  final String engineType; // Dropdown: Bensin, Diesel, Hybrid, EV
  final int km;            // Isian Angka: Jarak tempuh saat ini

  const CarModel({
    required this.id,
    required this.customerUid,
    required this.brand,
    required this.type,
    required this.plate,
    required this.year,
    required this.color,
    required this.engineType,
    required this.km,
  });

  factory CarModel.fromMap(String docId, Map<String, dynamic> map) {
    return CarModel(
      id: docId,
      customerUid: map['customerUid'] ?? '',
      brand: map['brand'] ?? '',
      type: map['type'] ?? '',
      plate: map['plate'] ?? '',
      year: map['year'] ?? '',
      color: map['color'] ?? '',
      engineType: map['engineType'] ?? 'Bensin',
      km: map['km'] is int ? map['km'] : int.tryParse(map['km']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customerUid': customerUid,
      'brand': brand,
      'type': type,
      'plate': plate,
      'year': year,
      'color': color,
      'engineType': engineType,
      'km': km,
    };
  }
}