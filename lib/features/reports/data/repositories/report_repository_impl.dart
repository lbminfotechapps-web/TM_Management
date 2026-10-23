
import '../../../customers/domain/repositories/customer_repository.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../../orders/domain/repositories/order_repository.dart';
import '../../../appointments/domain/entities/appointment_entity.dart';
import '../../../appointments/domain/repositories/appointment_repository.dart';

import '../../domain/entities/report_entity.dart';
import '../../domain/repositories/report_repository.dart';

class ReportRepositoryImpl implements ReportRepository {
  final CustomerRepository customerRepository;
  final OrderRepository orderRepository;
  final AppointmentRepository appointmentRepository;

  ReportRepositoryImpl({
    required this.customerRepository,
    required this.orderRepository,
    required this.appointmentRepository,
  });

  bool _inRange(
    DateTime value,
    DateTime from,
    DateTime to,
  ) {
    final start = DateTime(from.year, from.month, from.day);
    final endExclusive = DateTime(
      to.year,
      to.month,
      to.day + 1,
    );

    return !value.isBefore(start) &&
        value.isBefore(endExclusive);
  }

  @override
  Future<ReportEntity> getReport({
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    final results = await Future.wait([
      customerRepository.getCustomers(),
      orderRepository.getOrders(),
      appointmentRepository.getAppointments(),
    ]);

    // Typed repository calls are made again below so that
    // the lists retain their correct domain types.
    // The concurrent calls above are not necessary for the
    // calculation; they can be omitted if preferred.
    final customers = await customerRepository.getCustomers();
    final allOrders = await orderRepository.getOrders();
    final allAppointments =
        await appointmentRepository.getAppointments();

    final orders = allOrders.where(
      (order) => _inRange(
        order.orderDate,
        fromDate,
        toDate,
      ),
    ).toList();

    final appointments = allAppointments.where(
      (appointment) => _inRange(
        appointment.dateTime,
        fromDate,
        toDate,
      ),
    ).toList();

    final newCustomers = customers.where(
      (customer) => _inRange(
        customer.createdAt,
        fromDate,
        toDate,
      ),
    ).length;

    final validOrders = orders.where(
      (order) => order.status != OrderStatus.cancelled,
    ).toList();

    final pending = validOrders.where(
      (order) => order.status != OrderStatus.delivered,
    ).length;

    final delivered = orders.where(
      (order) => order.status == OrderStatus.delivered,
    ).length;

    final cancelled = orders.where(
      (order) => order.status == OrderStatus.cancelled,
    ).length;

    final totalValue = validOrders.fold<double>(
      0,
      (sum, order) => sum + order.amount,
    );

    final collected = validOrders.fold<double>(
      0,
      (sum, order) => sum + order.advance,
    );

    final balance = validOrders.fold<double>(
      0,
      (sum, order) => sum + order.balance,
    );

    final orderStatuses = <String, int>{
      for (final status in OrderStatus.values)
        status.label: orders.where(
          (o) => o.status == status,
        ).length,
    };

    final garmentCounts = <String, int>{};

    for (final order in validOrders) {
      garmentCounts.update(
        order.garment,
        (count) => count + order.quantity,
        ifAbsent: () => order.quantity,
      );
    }

    final completedAppointments = appointments.where(
      (a) => a.status == AppointmentStatus.completed,
    ).length;

    final cancelledAppointments = appointments.where(
      (a) => a.status == AppointmentStatus.cancelled,
    ).length;

    final upcomingAppointments = appointments.where(
      (a) =>
          a.status == AppointmentStatus.scheduled ||
          a.status == AppointmentStatus.confirmed,
    ).length;

    return ReportEntity(
      fromDate: fromDate,
      toDate: toDate,
      totalCustomers: customers.length,
      newCustomers: newCustomers,
      totalOrders: orders.length,
      pendingOrders: pending,
      deliveredOrders: delivered,
      cancelledOrders: cancelled,
      totalOrderValue: totalValue,
      advanceCollected: collected,
      balanceDue: balance,
      totalAppointments: appointments.length,
      completedAppointments: completedAppointments,
      upcomingAppointments: upcomingAppointments,
      cancelledAppointments: cancelledAppointments,
      orderStatusCounts: orderStatuses,
      garmentCounts: garmentCounts,
    );
  }
}
