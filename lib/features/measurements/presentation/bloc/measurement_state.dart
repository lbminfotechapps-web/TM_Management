
part of 'measurement_bloc.dart';

enum MeasurementStatus {
  initial,
  loading,
  success,
  saving,
  saved,
  deleting,
  deleted,
  failure,
}

class MeasurementState extends Equatable {
  final MeasurementStatus status;
  final List<MeasurementEntity> measurements;
  final String message;
  final int revision;

  const MeasurementState({
    this.status = MeasurementStatus.initial,
    this.measurements = const [],
    this.message = '',
    this.revision = 0,
  });

  MeasurementState copyWith({
    MeasurementStatus? status,
    List<MeasurementEntity>? measurements,
    String? message,
    int? revision,
  }) {
    return MeasurementState(
      status: status ?? this.status,
      measurements: measurements ?? this.measurements,
      message: message ?? this.message,
      revision: revision ?? this.revision,
    );
  }

  @override
  List<Object?> get props => [
        status,
        measurements,
        message,
        revision,
      ];
}
