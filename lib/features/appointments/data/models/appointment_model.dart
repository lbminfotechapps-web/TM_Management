
import '../../domain/entities/appointment_entity.dart';

class AppointmentModel extends AppointmentEntity {
  const AppointmentModel({
    required super.id,
    required super.customerId,
    required super.customerName,
    required super.purpose,
    required super.dateTime,
    required super.status,
    required super.notes,
    required super.createdAt,
  });

  factory AppointmentModel.fromEntity(AppointmentEntity entity) {
    return AppointmentModel(
      id: entity.id,
      customerId: entity.customerId,
      customerName: entity.customerName,
      purpose: entity.purpose,
      dateTime: entity.dateTime,
      status: entity.status,
      notes: entity.notes,
      createdAt: entity.createdAt,
    );
  }

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    final statusName =
        (json['status'] ?? 'scheduled').toString();

    return AppointmentModel(
      id: json['id'].toString(),
      customerId: json['customer_id'].toString(),
      customerName: (json['customer_name'] ?? '').toString(),
      purpose: (json['purpose'] ?? '').toString(),
      dateTime: DateTime.parse(json['date_time'].toString()),
      status: AppointmentStatus.values.firstWhere(
        (value) => value.name == statusName,
        orElse: () => AppointmentStatus.scheduled,
      ),
      notes: (json['notes'] ?? '').toString(),
      createdAt: DateTime.parse(json['created_at'].toString()),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'customer_id': customerId,
        'customer_name': customerName,
        'purpose': purpose,
        'date_time': dateTime.toIso8601String(),
        'status': status.name,
        'notes': notes,
        'created_at': createdAt.toIso8601String(),
      };
}
