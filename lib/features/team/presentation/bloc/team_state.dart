
part of 'team_bloc.dart';

enum TeamStatus {
  initial,
  loading,
  success,
  saving,
  saved,
  deleting,
  deleted,
  failure,
}

class TeamState extends Equatable {
  final TeamStatus status;
  final List<TeamMemberEntity> members;
  final String message;
  final int revision;

  const TeamState({
    this.status = TeamStatus.initial,
    this.members = const [],
    this.message = '',
    this.revision = 0,
  });

  TeamState copyWith({
    TeamStatus? status,
    List<TeamMemberEntity>? members,
    String? message,
    int? revision,
  }) {
    return TeamState(
      status: status ?? this.status,
      members: members ?? this.members,
      message: message ?? this.message,
      revision: revision ?? this.revision,
    );
  }

  @override
  List<Object?> get props => [status, members, message, revision];
}
