
import 'package:equatable/equatable.dart';

class ReportEntity extends Equatable {
  final DateTime fromDate;
  final DateTime toDate;

  final int totalCustomers;
  final int newCustomers;
  final int totalOrders;
  final int pendingOrders;
  final int deliveredOrders;
  final int cancelledOrders;

  final double totalOrderValue;
  final double advanceCollected;
  final double balanceDue;

  final int totalAppointments;
  final int completedAppointments;
  final int upcomingAppointments;
  final int cancelledAppointments;

  final Map<String, int> orderStatusCounts;
  final Map<String, int> garmentCounts;

  const ReportEntity({
    required this.fromDate,
    required this.toDate,
    required this.totalCustomers,
    required this.newCustomers,
    required this.totalOrders,
    required this.pendingOrders,
    required this.deliveredOrders,
    required this.cancelledOrders,
    required this.totalOrderValue,
    required this.advanceCollected,
    required this.balanceDue,
    required this.totalAppointments,
    required this.completedAppointments,
    required this.upcomingAppointments,
    required this.cancelledAppointments,
    required this.orderStatusCounts,
    required this.garmentCounts,
  });

  @override
  List<Object?> get props => [
        fromDate,
        toDate,
        totalCustomers,
        newCustomers,
        totalOrders,
        pendingOrders,
        deliveredOrders,
        cancelledOrders,
        totalOrderValue,
        advanceCollected,
        balanceDue,
        totalAppointments,
        completedAppointments,
        upcomingAppointments,
        cancelledAppointments,
        orderStatusCounts,
        garmentCounts,
      ];
}
