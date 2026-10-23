
import 'package:equatable/equatable.dart';

enum OrderStatus {
  received,
  cutting,
  stitching,
  trial,
  ready,
  delivered,
  cancelled,
}

extension OrderStatusExtension on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.received:
        return 'Received';
      case OrderStatus.cutting:
        return 'Cutting';
      case OrderStatus.stitching:
        return 'Stitching';
      case OrderStatus.trial:
        return 'Trial';
      case OrderStatus.ready:
        return 'Ready';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}

class OrderEntity extends Equatable {
  final String id;
  final String customerId;
  final String customerName;
  final String garment;
  final int quantity;
  final double amount;
  final double advance;
  final DateTime orderDate;
  final DateTime deliveryDate;
  final OrderStatus status;
  final String notes;

  const OrderEntity({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.garment,
    required this.quantity,
    required this.amount,
    required this.advance,
    required this.orderDate,
    required this.deliveryDate,
    required this.status,
    required this.notes,
  });

  double get balance => amount - advance;

  OrderEntity copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? garment,
    int? quantity,
    double? amount,
    double? advance,
    DateTime? orderDate,
    DateTime? deliveryDate,
    OrderStatus? status,
    String? notes,
  }) {
    return OrderEntity(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      garment: garment ?? this.garment,
      quantity: quantity ?? this.quantity,
      amount: amount ?? this.amount,
      advance: advance ?? this.advance,
      orderDate: orderDate ?? this.orderDate,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
        id,
        customerId,
        customerName,
        garment,
        quantity,
        amount,
        advance,
        orderDate,
        deliveryDate,
        status,
        notes,
      ];
}
