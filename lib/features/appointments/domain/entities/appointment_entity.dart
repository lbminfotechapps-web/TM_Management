
import 'package:equatable/equatable.dart';

enum AppointmentStatus {
  scheduled,
  confirmed,
  completed,
  cancelled,
}

extension AppointmentStatusX on AppointmentStatus {
  String get label {
    switch (this) {
      case AppointmentStatus.scheduled:
        return 'Scheduled';
      case AppointmentStatus.confirmed:
        return 'Confirmed';
      case AppointmentStatus.completed:
        return 'Completed';
      case AppointmentStatus.cancelled:
        return 'Cancelled';
    }
  }
}

class AppointmentEntity extends Equatable {
  final String id;
  final String customerId;
  final String customerName;
  final String purpose;
  final DateTime dateTime;
  final AppointmentStatus status;
  final String notes;
  final DateTime createdAt;

  const AppointmentEntity({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.purpose,
    required this.dateTime,
    required this.status,
    required this.notes,
    required this.createdAt,
  });

  AppointmentEntity copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? purpose,
    DateTime? dateTime,
    AppointmentStatus? status,
    String? notes,
    DateTime? createdAt,
  }) {
    return AppointmentEntity(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      purpose: purpose ?? this.purpose,
      dateTime: dateTime ?? this.dateTime,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        customerId,
        customerName,
        purpose,
        dateTime,
        status,
        notes,
        createdAt,
      ];
}
