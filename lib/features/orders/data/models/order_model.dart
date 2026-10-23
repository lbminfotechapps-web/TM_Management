
import '../../domain/entities/order_entity.dart';

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    required super.customerId,
    required super.customerName,
    required super.garment,
    required super.quantity,
    required super.amount,
    required super.advance,
    required super.orderDate,
    required super.deliveryDate,
    required super.status,
    required super.notes,
  });

  factory OrderModel.fromEntity(OrderEntity item) {
    return OrderModel(
      id: item.id,
      customerId: item.customerId,
      customerName: item.customerName,
      garment: item.garment,
      quantity: item.quantity,
      amount: item.amount,
      advance: item.advance,
      orderDate: item.orderDate,
      deliveryDate: item.deliveryDate,
      status: item.status,
      notes: item.notes,
    );
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final statusName = (json['status'] ?? 'received').toString();

    return OrderModel(
      id: json['id'].toString(),
      customerId: json['customer_id'].toString(),
      customerName: (json['customer_name'] ?? '').toString(),
      garment: (json['garment'] ?? '').toString(),
      quantity: (json['quantity'] as num).toInt(),
      amount: (json['amount'] as num).toDouble(),
      advance: (json['advance'] as num).toDouble(),
      orderDate: DateTime.parse(json['order_date'].toString()),
      deliveryDate: DateTime.parse(
        json['delivery_date'].toString(),
      ),
      status: OrderStatus.values.firstWhere(
        (item) => item.name == statusName,
        orElse: () => OrderStatus.received,
      ),
      notes: (json['notes'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'customer_id': customerId,
        'customer_name': customerName,
        'garment': garment,
        'quantity': quantity,
        'amount': amount,
        'advance': advance,
        'order_date': orderDate.toIso8601String(),
        'delivery_date': deliveryDate.toIso8601String(),
        'status': status.name,
        'notes': notes,
      };
}
