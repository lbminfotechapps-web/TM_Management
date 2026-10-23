import 'package:equatable/equatable.dart';

class DashboardEntity extends Equatable {
  final int totalCustomers;
  final int totalOrders;
  final int pendingOrders;
  final double revenue;
  final List<AppointmentEntity> appointments;

  const DashboardEntity({
    required this.totalCustomers,
    required this.totalOrders,
    required this.pendingOrders,
    required this.revenue,
    required this.appointments,
  });

  @override
  List<Object?> get props => [
    totalCustomers,
    totalOrders,
    pendingOrders,
    revenue,
    appointments,
  ];
}

class AppointmentEntity extends Equatable {
  final String name;
  final String time;
  final String description;

  const AppointmentEntity({
    required this.name,
    required this.time,
    required this.description,
  });

  @override
  List<Object?> get props => [name, time, description];
}