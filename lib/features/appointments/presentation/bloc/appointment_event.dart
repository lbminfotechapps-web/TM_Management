
part of 'appointment_bloc.dart';


sealed class AppointmentEvent extends Equatable {
  const AppointmentEvent();

  @override
  List<Object?> get props => [];
}

class LoadAppointmentsEvent extends AppointmentEvent {
  const LoadAppointmentsEvent();
}

class SaveAppointmentEvent extends AppointmentEvent {
  final AppointmentEntity appointment;

  const SaveAppointmentEvent(this.appointment);

  @override
  List<Object?> get props => [appointment];
}

class DeleteAppointmentEvent extends AppointmentEvent {
  final String id;

  const DeleteAppointmentEvent(this.id);

  @override
  List<Object?> get props => [id];
}
