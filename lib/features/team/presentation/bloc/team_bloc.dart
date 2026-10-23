
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/team_member_entity.dart';
import '../../domain/usecases/get_team_members_usecase.dart';
import '../../domain/usecases/save_team_member_usecase.dart';
import '../../domain/usecases/delete_team_member_usecase.dart';

part 'team_event.dart';
part 'team_state.dart';

class TeamBloc extends Bloc<TeamEvent, TeamState> {
  final GetTeamMembersUseCase getMembers;
  final SaveTeamMemberUseCase saveMember;
  final DeleteTeamMemberUseCase deleteMember;

  TeamBloc({
    required this.getMembers,
    required this.saveMember,
    required this.deleteMember,
  }) : super(const TeamState()) {
    on<LoadTeamEvent>((event, emit) async {
      emit(state.copyWith(status: TeamStatus.loading, message: ''));
      try {
        final members = await getMembers();
        emit(state.copyWith(
          status: TeamStatus.success,
          members: members,
          revision: state.revision + 1,
        ));
      } catch (e) {
        emit(state.copyWith(
          status: TeamStatus.failure,
          message: e.toString().replaceFirst('Exception: ', ''),
          revision: state.revision + 1,
        ));
      }
    });

    on<SaveTeamMemberEvent>((event, emit) async {
      emit(state.copyWith(status: TeamStatus.saving, message: ''));
      try {
        await saveMember(event.member);
        final members = await getMembers();
        emit(state.copyWith(
          status: TeamStatus.saved,
          members: members,
          message: 'Team member saved successfully',
          revision: state.revision + 1,
        ));
      } catch (e) {
        emit(state.copyWith(
          status: TeamStatus.failure,
          message: e.toString().replaceFirst('Exception: ', ''),
          revision: state.revision + 1,
        ));
      }
    });

    on<DeleteTeamMemberEvent>((event, emit) async {
      emit(state.copyWith(status: TeamStatus.deleting, message: ''));
      try {
        await deleteMember(event.id);
        final members = await getMembers();
        emit(state.copyWith(
          status: TeamStatus.deleted,
          members: members,
          message: 'Team member deleted',
          revision: state.revision + 1,
        ));
      } catch (e) {
        emit(state.copyWith(
          status: TeamStatus.failure,
          message: e.toString().replaceFirst('Exception: ', ''),
          revision: state.revision + 1,
        ));
      }
    });
  }
}
