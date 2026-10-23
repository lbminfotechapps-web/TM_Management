
part of 'appointment_bloc.dart';


enum AppointmentBlocStatus {
  initial,
  loading,
  success,
  saving,
  saved,
  deleting,
  deleted,
  failure,
}

class AppointmentState extends Equatable {
  final AppointmentBlocStatus status;
  final List<AppointmentEntity> appointments;
  final String message;
  final int revision;

  const AppointmentState({
    this.status = AppointmentBlocStatus.initial,
    this.appointments = const [],
    this.message = '',
    this.revision = 0,
  });

  AppointmentState copyWith({
    AppointmentBlocStatus? status,
    List<AppointmentEntity>? appointments,
    String? message,
    int? revision,
  }) {
    return AppointmentState(
      status: status ?? this.status,
      appointments: appointments ?? this.appointments,
      message: message ?? this.message,
      revision: revision ?? this.revision,
    );
  }

  @override
  List<Object?> get props => [
        status,
        appointments,
        message,
        revision,
      ];
}
