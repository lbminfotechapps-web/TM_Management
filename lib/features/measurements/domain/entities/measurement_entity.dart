
import 'package:equatable/equatable.dart';

class MeasurementEntity extends Equatable {
  final String id;
  final String customerId;
  final String customerName;
  final String garmentType;

  final double chest;
  final double waist;
  final double hip;
  final double shoulder;
  final double sleeve;
  final double length;

  final String notes;
  final DateTime createdAt;

  const MeasurementEntity({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.garmentType,
    required this.chest,
    required this.waist,
    required this.hip,
    required this.shoulder,
    required this.sleeve,
    required this.length,
    required this.notes,
    required this.createdAt,
  });

  MeasurementEntity copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? garmentType,
    double? chest,
    double? waist,
    double? hip,
    double? shoulder,
    double? sleeve,
    double? length,
    String? notes,
    DateTime? createdAt,
  }) {
    return MeasurementEntity(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      garmentType: garmentType ?? this.garmentType,
      chest: chest ?? this.chest,
      waist: waist ?? this.waist,
      hip: hip ?? this.hip,
      shoulder: shoulder ?? this.shoulder,
      sleeve: sleeve ?? this.sleeve,
      length: length ?? this.length,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        customerId,
        customerName,
        garmentType,
        chest,
        waist,
        hip,
        shoulder,
        sleeve,
        length,
        notes,
        createdAt,
      ];
}
