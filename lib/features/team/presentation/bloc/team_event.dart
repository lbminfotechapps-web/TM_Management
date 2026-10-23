
part of 'team_bloc.dart';

sealed class TeamEvent extends Equatable {
  const TeamEvent();

  @override
  List<Object?> get props => [];
}

class LoadTeamEvent extends TeamEvent {
  const LoadTeamEvent();
}

class SaveTeamMemberEvent extends TeamEvent {
  final TeamMemberEntity member;
  const SaveTeamMemberEvent(this.member);

  @override
  List<Object?> get props => [member];
}

class DeleteTeamMemberEvent extends TeamEvent {
  final String id;
  const DeleteTeamMemberEvent(this.id);

  @override
  List<Object?> get props => [id];
}
