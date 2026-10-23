import '../models/customer_model.dart';

abstract class CustomerLocalDataSource {
  Future<List<CustomerModel>> getCustomers();

  Future<CustomerModel> saveCustomer(CustomerModel customer);

  Future<void> deleteCustomer(String id);
}

class CustomerLocalDataSourceImpl
    implements CustomerLocalDataSource {
  final List<CustomerModel> _customers = [
    CustomerModel.fromJson({
      'id': 'C001',
      'name': 'Anita Sharma',
      'phone': '9876543210',
      'email': 'anita@example.com',
      'address': 'Mumbai, Maharashtra',
      'created_at': '2026-09-10T10:00:00',
    }),
    CustomerModel.fromJson({
      'id': 'C002',
      'name': 'Vikram Mehta',
      'phone': '9876543211',
      'email': 'vikram@example.com',
      'address': 'Pune, Maharashtra',
      'created_at': '2026-09-12T11:00:00',
    }),
    CustomerModel.fromJson({
      'id': 'C003',
      'name': 'Sneha Patel',
      'phone': '9876543212',
      'email': 'sneha@example.com',
      'address': 'Nashik, Maharashtra',
      'created_at': '2026-09-15T09:30:00',
    }),
    CustomerModel.fromJson({
      'id': 'C004',
      'name': 'Rahul Joshi',
      'phone': '9876543213',
      'email': 'rahul@example.com',
      'address': 'Thane, Maharashtra',
      'created_at': '2026-09-20T12:00:00',
    }),
  ];

  @override
  Future<List<CustomerModel>> getCustomers() async {
    return List<CustomerModel>.unmodifiable(_customers);
  }

  @override
  Future<CustomerModel> saveCustomer(
    CustomerModel customer,
  ) async {
    final index = _customers.indexWhere(
      (item) => item.id == customer.id,
    );

    if (index >= 0) {
      _customers[index] = customer;
    } else {
      _customers.insert(0, customer);
    }

    return customer;
  }

  @override
  Future<void> deleteCustomer(String id) async {
    _customers.removeWhere((item) => item.id == id);
  }
}