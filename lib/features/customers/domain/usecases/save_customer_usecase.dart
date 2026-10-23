import '../entities/customer_entity.dart';
import '../repositories/customer_repository.dart';

class SaveCustomerUseCase {
  final CustomerRepository repository;

  SaveCustomerUseCase(this.repository);

  Future<CustomerEntity> call(CustomerEntity customer) {
    if (customer.name.trim().isEmpty) {
      throw Exception('Customer name is required');
    }

    if (!RegExp(r'^[0-9]{10}$').hasMatch(customer.phone)) {
      throw Exception('Enter a valid 10-digit mobile number');
    }

    return repository.saveCustomer(customer);
  }
}