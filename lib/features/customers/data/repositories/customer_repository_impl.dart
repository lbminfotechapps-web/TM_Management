import '../../domain/entities/customer_entity.dart';
import '../../domain/repositories/customer_repository.dart';
import '../datasources/customer_local_datasource.dart';
import '../models/customer_model.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final CustomerLocalDataSource localDataSource;

  CustomerRepositoryImpl(this.localDataSource);

  @override
  Future<List<CustomerEntity>> getCustomers() async {
    final models = await localDataSource.getCustomers();
    return List<CustomerEntity>.from(models);
  }

  @override
  Future<CustomerEntity> saveCustomer(
    CustomerEntity customer,
  ) async {
    return localDataSource.saveCustomer(
      CustomerModel.fromEntity(customer),
    );
  }

  @override
  Future<void> deleteCustomer(String id) {
    return localDataSource.deleteCustomer(id);
  }
}