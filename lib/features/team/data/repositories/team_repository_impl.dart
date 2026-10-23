
import '../../domain/entities/team_member_entity.dart';
import '../../domain/repositories/team_repository.dart';
import '../datasources/team_local_datasource.dart';
import '../models/team_member_model.dart';

class TeamRepositoryImpl implements TeamRepository {
  final TeamLocalDataSource source;

  TeamRepositoryImpl(this.source);

  @override
  Future<List<TeamMemberEntity>> getMembers() async =>
      List<TeamMemberEntity>.from(await source.getMembers());

  @override
  Future<void> saveMember(TeamMemberEntity member) =>
      source.saveMember(TeamMemberModel.fromEntity(member));

  @override
  Future<void> deleteMember(String id) => source.deleteMember(id);
}
