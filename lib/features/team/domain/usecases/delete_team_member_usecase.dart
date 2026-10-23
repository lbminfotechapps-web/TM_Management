
import '../repositories/team_repository.dart';

class DeleteTeamMemberUseCase {
  final TeamRepository repository;
  DeleteTeamMemberUseCase(this.repository);

  Future<void> call(String id) => repository.deleteMember(id);
}
