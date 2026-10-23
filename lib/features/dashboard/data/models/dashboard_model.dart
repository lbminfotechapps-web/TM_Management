import '../../domain/entities/dashboard_entity.dart';

class DashboardModel extends DashboardEntity {
  const DashboardModel({
    required super.totalCustomers,
    required super.totalOrders,
    required super.pendingOrders,
    required super.revenue,
    required super.appointments,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      totalCustomers: (json['total_customers'] as num).toInt(),
      totalOrders: (json['total_orders'] as num).toInt(),
      pendingOrders: (json['pending_orders'] as num).toInt(),
      revenue: (json['revenue'] as num).toDouble(),
      appointments: (json['appointments'] as List).map((item) {
        return AppointmentEntity(
          name: item['name'] as String,
          time: item['time'] as String,
          description: item['description'] as String,
        );
      }).toList(),
    );
  }
}