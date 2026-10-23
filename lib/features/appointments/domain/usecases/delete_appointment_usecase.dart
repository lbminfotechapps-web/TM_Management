
import '../repositories/appointment_repository.dart';

class DeleteAppointmentUseCase {
  final AppointmentRepository repository;

  DeleteAppointmentUseCase(this.repository);

  Future<void> call(String id) {
    return repository.deleteAppointment(id);
  }
}
