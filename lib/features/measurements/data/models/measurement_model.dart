
import '../../domain/entities/measurement_entity.dart';

class MeasurementModel extends MeasurementEntity {
  const MeasurementModel({
    required super.id,
    required super.customerId,
    required super.customerName,
    required super.garmentType,
    required super.chest,
    required super.waist,
    required super.hip,
    required super.shoulder,
    required super.sleeve,
    required super.length,
    required super.notes,
    required super.createdAt,
  });

  factory MeasurementModel.fromEntity(MeasurementEntity entity) {
    return MeasurementModel(
      id: entity.id,
      customerId: entity.customerId,
      customerName: entity.customerName,
      garmentType: entity.garmentType,
      chest: entity.chest,
      waist: entity.waist,
      hip: entity.hip,
      shoulder: entity.shoulder,
      sleeve: entity.sleeve,
      length: entity.length,
      notes: entity.notes,
      createdAt: entity.createdAt,
    );
  }

  factory MeasurementModel.fromJson(Map<String, dynamic> json) {
    double parseNumber(String key) {
      final value = json[key];
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '') ?? 0.0;
    }

    return MeasurementModel(
      id: json['id'].toString(),
      customerId: json['customer_id'].toString(),
      customerName: (json['customer_name'] ?? '').toString(),
      garmentType: (json['garment_type'] ?? '').toString(),
      chest: parseNumber('chest'),
      waist: parseNumber('waist'),
      hip: parseNumber('hip'),
      shoulder: parseNumber('shoulder'),
      sleeve: parseNumber('sleeve'),
      length: parseNumber('length'),
      notes: (json['notes'] ?? '').toString(),
      createdAt: DateTime.parse(
        json['created_at'].toString(),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'customer_id': customerId,
        'customer_name': customerName,
        'garment_type': garmentType,
        'chest': chest,
        'waist': waist,
        'hip': hip,
        'shoulder': shoulder,
        'sleeve': sleeve,
        'length': length,
        'notes': notes,
        'created_at': createdAt.toIso8601String(),
      };
}
