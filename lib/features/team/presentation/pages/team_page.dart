
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tailorpro_clean/features/team/presentation/widgets/team_member_card.dart.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_routes.dart';
import '../../domain/entities/team_member_entity.dart';
import '../bloc/team_bloc.dart';

class TeamPage extends StatefulWidget {
  const TeamPage({super.key});

  @override
  State<TeamPage> createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  final _searchController = TextEditingController();

  String query = '';
  TeamRole? roleFilter;
  TeamMemberStatus? statusFilter;

  @override
  void initState() {
    super.initState();
    context.read<TeamBloc>().add(const LoadTeamEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete(TeamMemberEntity member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Team Member?'),
        content: Text(
          'Delete ${member.name}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.red),
            ),
          ),
        ],
      ),
    );

    if (!mounted || confirmed != true) return;
    context.read<TeamBloc>().add(DeleteTeamMemberEvent(member.id));
  }

  Widget _summary(List<TeamMemberEntity> members) {
    final active = members
        .where((m) => m.status == TeamMemberStatus.active)
        .length;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF392417),
            Color(0xFF79512E),
          ],
        ),
        borderRadius: BorderRadius.circular(19),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.groups_2_outlined,
                color: Color(0xFFF2CD96),
                size: 24,
              ),
              SizedBox(width: 9),
              Text(
                'Team Overview',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              _Counter('Total', members.length),
              const SizedBox(width: 9),
              _Counter('Active', active),
              const SizedBox(width: 9),
              _Counter('Inactive', members.length - active),
            ],
          ),
        ],
      ),
    );
  }

  Widget _filters() {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<TeamRole?>(
            key: ValueKey(roleFilter),
            initialValue: roleFilter,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Role',
              contentPadding: EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 12,
              ),
            ),
            items: [
              const DropdownMenuItem<TeamRole?>(
                value: null,
                child: Text('All roles'),
              ),
              ...TeamRole.values.map(
                (role) => DropdownMenuItem<TeamRole?>(
                  value: role,
                  child: Text(
                    role.label,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
            onChanged: (value) {
              setState(() => roleFilter = value);
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: DropdownButtonFormField<TeamMemberStatus?>(
            key: ValueKey(statusFilter),
            initialValue: statusFilter,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Status',
              contentPadding: EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 12,
              ),
            ),
            items: [
              const DropdownMenuItem<TeamMemberStatus?>(
                value: null,
                child: Text('All statuses'),
              ),
              ...TeamMemberStatus.values.map(
                (status) => DropdownMenuItem<TeamMemberStatus?>(
                  value: status,
                  child: Text(status.label),
                ),
              ),
            ],
            onChanged: (value) {
              setState(() => statusFilter = value);
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Team Member List',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () =>
                context.read<TeamBloc>().add(const LoadTeamEvent()),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Member'),
        onPressed: () => context.push(AppRoutes.addTeamMember),
      ),
      body: BlocConsumer<TeamBloc, TeamState>(
        listenWhen: (previous, current) =>
            previous.revision != current.revision &&
            (current.status == TeamStatus.deleted ||
                current.status == TeamStatus.failure),
        listener: (context, state) {
          if (state.message.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state.status == TeamStatus.loading &&
              state.members.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final text = query.toLowerCase().trim();

          final filtered = state.members.where((member) {
            final matchesSearch =
                member.name.toLowerCase().contains(text) ||
                member.phone.contains(text) ||
                member.role.label.toLowerCase().contains(text);

            return matchesSearch &&
                (roleFilter == null || member.role == roleFilter) &&
                (statusFilter == null ||
                    member.status == statusFilter);
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 9, 16, 11),
                child: Column(
                  children: [
                    _summary(state.members),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _searchController,
                      onChanged: (value) =>
                          setState(() => query = value),
                      decoration: InputDecoration(
                        hintText: 'Search name, mobile or role',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: query.isEmpty
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => query = '');
                                },
                              ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _filters(),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${filtered.length} members found',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.muted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: state.status == TeamStatus.failure &&
                        state.members.isEmpty
                    ? Center(
                        child: TextButton(
                          onPressed: () =>
                              context.read<TeamBloc>().add(
                                const LoadTeamEvent(),
                              ),
                          child: Text('Retry: ${state.message}'),
                        ),
                      )
                    : filtered.isEmpty
                        ? const Center(
                            child: Text('No team members found'),
                          )
                        : RefreshIndicator(
                            onRefresh: () async {
                              final bloc = context.read<TeamBloc>();
                              final oldRevision = bloc.state.revision;
                              bloc.add(const LoadTeamEvent());
                              await bloc.stream.firstWhere(
                                (s) => s.revision > oldRevision,
                              );
                            },
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(
                                16, 0, 16, 100,
                              ),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final member = filtered[index];

                                return TeamMemberCard(
                                  member: member,
                                  onTap: () => context.push(
                                    AppRoutes.teamMemberDetails,
                                    extra: member,
                                  ),
                                  onEdit: () => context.push(
                                    AppRoutes.editTeamMember,
                                    extra: member,
                                  ),
                                  onDelete: () =>
                                      _confirmDelete(member),
                                  onStatusChanged: (status) {
                                    context.read<TeamBloc>().add(
                                      SaveTeamMemberEvent(
                                        member.copyWith(status: status),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Counter extends StatelessWidget {
  final String label;
  final int count;

  const _Counter(this.label, this.count);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.11),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 21,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
