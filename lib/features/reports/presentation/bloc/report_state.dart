
part of 'report_bloc.dart';


enum ReportStatus {
  initial,
  loading,
  success,
  failure,
}

class ReportState extends Equatable {
  final ReportStatus status;
  final ReportEntity? report;
  final String message;
  final int revision;

  const ReportState({
    this.status = ReportStatus.initial,
    this.report,
    this.message = '',
    this.revision = 0,
  });

  ReportState copyWith({
    ReportStatus? status,
    ReportEntity? report,
    String? message,
    int? revision,
  }) {
    return ReportState(
      status: status ?? this.status,
      report: report ?? this.report,
      message: message ?? this.message,
      revision: revision ?? this.revision,
    );
  }

  @override
  List<Object?> get props => [
        status,
        report,
        message,
        revision,
      ];
}
