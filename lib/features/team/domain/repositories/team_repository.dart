
import '../entities/team_member_entity.dart';

abstract class TeamRepository {
  Future<List<TeamMemberEntity>> getMembers();
  Future<void> saveMember(TeamMemberEntity member);
  Future<void> deleteMember(String id);
}
