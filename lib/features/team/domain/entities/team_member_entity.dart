
import 'package:equatable/equatable.dart';

enum TeamRole {
  masterTailor,
  tailor,
  cutter,
  helper,
  manager,
}

extension TeamRoleX on TeamRole {
  String get label => switch (this) {
    TeamRole.masterTailor => 'Master Tailor',
    TeamRole.tailor => 'Tailor',
    TeamRole.cutter => 'Cutter',
    TeamRole.helper => 'Helper',
    TeamRole.manager => 'Manager',
  };
}

enum TeamMemberStatus { active, inactive }

extension TeamMemberStatusX on TeamMemberStatus {
  String get label => this == TeamMemberStatus.active
      ? 'Active'
      : 'Inactive';
}

class TeamMemberEntity extends Equatable {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String address;
  final TeamRole role;
  final TeamMemberStatus status;
  final double monthlySalary;
  final DateTime joinedOn;
  final String notes;

  const TeamMemberEntity({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
    required this.role,
    required this.status,
    required this.monthlySalary,
    required this.joinedOn,
    required this.notes,
  });

  TeamMemberEntity copyWith({
    String? name,
    String? phone,
    String? email,
    String? address,
    TeamRole? role,
    TeamMemberStatus? status,
    double? monthlySalary,
    DateTime? joinedOn,
    String? notes,
  }) {
    return TeamMemberEntity(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      role: role ?? this.role,
      status: status ?? this.status,
      monthlySalary: monthlySalary ?? this.monthlySalary,
      joinedOn: joinedOn ?? this.joinedOn,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    phone,
    email,
    address,
    role,
    status,
    monthlySalary,
    joinedOn,
    notes,
  ];
}
