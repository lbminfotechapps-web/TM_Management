
import '../entities/report_entity.dart';
import '../repositories/report_repository.dart';

class GetReportUseCase {
  final ReportRepository repository;

  GetReportUseCase(this.repository);

  Future<ReportEntity> call({
    required DateTime fromDate,
    required DateTime toDate,
  }) {
    final from = DateTime(
      fromDate.year,
      fromDate.month,
      fromDate.day,
    );

    final to = DateTime(
      toDate.year,
      toDate.month,
      toDate.day,
    );

    if (to.isBefore(from)) {
      throw Exception('To date cannot be before From date');
    }

    return repository.getReport(
      fromDate: from,
      toDate: to,
    );
  }
}
