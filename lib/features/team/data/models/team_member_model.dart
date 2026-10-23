
import '../../domain/entities/team_member_entity.dart';

class TeamMemberModel extends TeamMemberEntity {
  const TeamMemberModel({
    required super.id,
    required super.name,
    required super.phone,
    required super.email,
    required super.address,
    required super.role,
    required super.status,
    required super.monthlySalary,
    required super.joinedOn,
    required super.notes,
  });

  factory TeamMemberModel.fromEntity(TeamMemberEntity e) {
    return TeamMemberModel(
      id: e.id,
      name: e.name,
      phone: e.phone,
      email: e.email,
      address: e.address,
      role: e.role,
      status: e.status,
      monthlySalary: e.monthlySalary,
      joinedOn: e.joinedOn,
      notes: e.notes,
    );
  }

  factory TeamMemberModel.fromJson(Map<String, dynamic> json) {
    return TeamMemberModel(
      id: json['id'].toString(),
      name: (json['name'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      role: TeamRole.values.firstWhere(
        (r) => r.name == json['role'],
        orElse: () => TeamRole.tailor,
      ),
      status: TeamMemberStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => TeamMemberStatus.active,
      ),
      monthlySalary:
          (json['monthly_salary'] as num?)?.toDouble() ?? 0,
      joinedOn: DateTime.parse(json['joined_on'].toString()),
      notes: (json['notes'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'email': email,
    'address': address,
    'role': role.name,
    'status': status.name,
    'monthly_salary': monthlySalary,
    'joined_on': joinedOn.toIso8601String(),
    'notes': notes,
  };
}
