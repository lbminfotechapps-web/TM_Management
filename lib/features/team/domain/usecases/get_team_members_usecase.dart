
import '../entities/team_member_entity.dart';
import '../repositories/team_repository.dart';

class GetTeamMembersUseCase {
  final TeamRepository repository;
  GetTeamMembersUseCase(this.repository);

  Future<List<TeamMemberEntity>> call() => repository.getMembers();
}
