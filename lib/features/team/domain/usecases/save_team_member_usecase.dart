
import '../entities/team_member_entity.dart';
import '../repositories/team_repository.dart';

class SaveTeamMemberUseCase {
  final TeamRepository repository;
  SaveTeamMemberUseCase(this.repository);

  Future<void> call(TeamMemberEntity member) {
    if (member.name.trim().isEmpty) {
      throw Exception('Enter team member name');
    }
    if (!RegExp(r'^[0-9]{10}$').hasMatch(member.phone)) {
      throw Exception('Enter a valid 10-digit mobile number');
    }
    if (member.monthlySalary.isNaN ||
        member.monthlySalary.isInfinite ||
        member.monthlySalary < 0) {
      throw Exception('Enter a valid monthly salary');
    }
    return repository.saveMember(member);
  }
}
