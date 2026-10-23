import '../entities/customer_entity.dart';

abstract class CustomerRepository {
  Future<List<CustomerEntity>> getCustomers();

  Future<CustomerEntity> saveCustomer(CustomerEntity customer);

  Future<void> deleteCustomer(String id);
}