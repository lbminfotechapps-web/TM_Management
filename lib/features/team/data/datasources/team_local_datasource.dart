
import '../models/team_member_model.dart';

abstract class TeamLocalDataSource {
  Future<List<TeamMemberModel>> getMembers();
  Future<void> saveMember(TeamMemberModel member);
  Future<void> deleteMember(String id);
}

class TeamLocalDataSourceImpl implements TeamLocalDataSource {
  final List<TeamMemberModel> _members = [
    TeamMemberModel.fromJson({
      'id': 'TM001',
      'name': 'Ramesh Kumar',
      'phone': '9876543210',
      'email': 'ramesh@example.com',
      'address': 'Delhi',
      'role': 'masterTailor',
      'status': 'active',
      'monthly_salary': 25000,
      'joined_on': '2025-01-04',
      'notes': 'Specialist in suits and formal wear',
    }),
    TeamMemberModel.fromJson({
      'id': 'TM002',
      'name': 'Sita Devi',
      'phone': '9876543211',
      'email': '',
      'address': 'Delhi',
      'role': 'tailor',
      'status': 'active',
      'monthly_salary': 19000,
      'joined_on': '2025-03-11',
      'notes': 'Blouse and lehenga stitching',
    }),
    TeamMemberModel.fromJson({
      'id': 'TM003',
      'name': 'Imran Khan',
      'phone': '9876543212',
      'email': '',
      'address': '',
      'role': 'cutter',
      'status': 'active',
      'monthly_salary': 22000,
      'joined_on': '2025-05-16',
      'notes': '',
    }),
    TeamMemberModel.fromJson({
      'id': 'TM004',
      'name': 'Pooja Sharma',
      'phone': '9876543213',
      'email': '',
      'address': '',
      'role': 'helper',
      'status': 'active',
      'monthly_salary': 12000,
      'joined_on': '2025-08-09',
      'notes': '',
    }),
    TeamMemberModel.fromJson({
      'id': 'TM005',
      'name': 'Arjun Patel',
      'phone': '9876543214',
      'email': '',
      'address': '',
      'role': 'manager',
      'status': 'inactive',
      'monthly_salary': 28000,
      'joined_on': '2025-04-20',
      'notes': '',
    }),
    TeamMemberModel.fromJson({
      'id': 'TM006',
      'name': 'Neha Singh',
      'phone': '9876543215',
      'email': '',
      'address': '',
      'role': 'tailor',
      'status': 'active',
      'monthly_salary': 18500,
      'joined_on': '2026-01-12',
      'notes': '',
    }),
  ];

  @override
  Future<List<TeamMemberModel>> getMembers() async {
    return List.unmodifiable(_members);
  }

  @override
  Future<void> saveMember(TeamMemberModel member) async {
    final index = _members.indexWhere((m) => m.id == member.id);
    if (index < 0) {
      _members.insert(0, member);
    } else {
      _members[index] = member;
    }
  }

  @override
  Future<void> deleteMember(String id) async {
    _members.removeWhere((m) => m.id == id);
  }
}
