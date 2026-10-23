
part of 'measurement_bloc.dart';


sealed class MeasurementEvent extends Equatable {
  const MeasurementEvent();

  @override
  List<Object?> get props => [];
}

class LoadMeasurementsEvent extends MeasurementEvent {
  const LoadMeasurementsEvent();
}

class SaveMeasurementEvent extends MeasurementEvent {
  final MeasurementEntity measurement;

  const SaveMeasurementEvent(this.measurement);

  @override
  List<Object?> get props => [measurement];
}

class DeleteMeasurementEvent extends MeasurementEvent {
  final String measurementId;

  const DeleteMeasurementEvent(this.measurementId);

  @override
  List<Object?> get props => [measurementId];
}
