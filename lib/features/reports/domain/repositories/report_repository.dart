
import '../entities/report_entity.dart';

abstract class ReportRepository {
  Future<ReportEntity> getReport({
    required DateTime fromDate,
    required DateTime toDate,
  });
}
