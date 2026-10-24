
import 'package:flutter/material.dart';
import 'package:tailorpro_clean/features/workdistribution/data/models/team_work_model.dart';

import 'add_update_work_page.dart';

class TeamWorkDetailPage extends StatefulWidget {
  final TeamWorkModel member;

  const TeamWorkDetailPage({
    super.key,
    required this.member,
  });

  @override
  State<TeamWorkDetailPage> createState() => _TeamWorkDetailPageState();
}

class _TeamWorkDetailPageState extends State<TeamWorkDetailPage> {
  static const primary = Color(0xFF159C69);
  static const gold = Color(0xFFBA8A2B);
  static const dark = Color(0xFF192535);
  static const bg = Color(0xFFF7F9FC);

  late List<WorkTask> tasks;

  @override
  void initState() {
    super.initState();
    tasks = List<WorkTask>.from(widget.member.tasks);
  }

  int get total => tasks.length;

  int get completed =>
      tasks.where((e) => e.status == WorkStatus.completed).length;

  int get pending => total - completed;

  double get progress => total == 0 ? 0 : completed / total;

  Future<void> _openWorkPage({WorkTask? task}) async {
    final result = await Navigator.push<WorkTask>(
      context,
      MaterialPageRoute(
        builder: (_) => AddUpdateWorkPage(
          member: widget.member,
          task: task,
        ),
      ),
    );

    if (!mounted || result == null) return;

    setState(() {
      if (task == null) {
        tasks.insert(0, result);
      } else {
        final index = tasks.indexOf(task);
        if (index != -1) {
          tasks[index] = result;
        }
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          task == null
              ? 'New work added successfully'
              : 'Work updated successfully',
        ),
        backgroundColor: primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Work Details',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: dark,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 19,
            color: dark,
          ),
          onPressed: () => Navigator.maybePop(context),
        ),
        actions: [
          IconButton(
            tooltip: 'Add work',
            icon: const Icon(
              Icons.add_task_rounded,
              size: 22,
              color: dark,
            ),
            onPressed: () => _openWorkPage(),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 20),
              children: [
                _buildProfile(),
                const SizedBox(height: 12),
                _buildSummary(),
                const SizedBox(height: 19),
                _buildHeader(),
                const SizedBox(height: 11),

                if (tasks.isEmpty)
                  _emptyState()
                else
                  ...tasks.map(
                    (task) => Padding(
                      padding: const EdgeInsets.only(bottom: 9),
                      child: _buildTaskCard(task),
                    ),
                  ),
              ],
            ),
          ),
          _bottomButton(),
        ],
      ),
    );
  }

  Widget _buildProfile() {
    final names = widget.member.name
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();

    final initials = names
        .take(2)
        .map((e) => e[0].toUpperCase())
        .join();

    final attendance = widget.member.attendance;

    final statusText = switch (attendance) {
      AttendanceStatus.present => 'Present',
      AttendanceStatus.absent => 'Absent',
      AttendanceStatus.holiday => 'Holiday',
    };

    final statusColor = switch (attendance) {
      AttendanceStatus.present => primary,
      AttendanceStatus.absent => const Color(0xFFE44B55),
      AttendanceStatus.holiday => const Color(0xFFE09A2B),
    };

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: _decoration(),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFFE2F6EC),
                child: Text(
                  initials.isEmpty ? '?' : initials,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: primary,
                  ),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.member.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: dark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.member.role,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 10.5,
                    color: statusColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Divider(height: 1, color: Colors.grey.shade200),
          const SizedBox(height: 11),
          Row(
            children: [
              const Icon(
                Icons.assignment_outlined,
                size: 15,
                color: Color(0xFF64748B),
              ),
              const SizedBox(width: 6),
              const Text(
                'Work Overview',
                style: TextStyle(
                  fontSize: 11.5,
                  color: Color(0xFF64748B),
                ),
              ),
              const Spacer(),
              Text(
                '${(progress * 100).round()}% Completed',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              color: primary,
              backgroundColor: const Color(0xFFEDF0F2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    return Row(
      children: [
        Expanded(
          child: _summaryTile(
            'Total Work',
            '$total',
            const Color(0xFFEAF3FF),
            const Color(0xFF2563B8),
            Icons.assignment_outlined,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _summaryTile(
            'Completed',
            '$completed',
            const Color(0xFFE4F8ED),
            primary,
            Icons.check_circle_outline,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _summaryTile(
            'Pending',
            '$pending',
            const Color(0xFFFFECEE),
            const Color(0xFFE14953),
            Icons.pending_actions_rounded,
          ),
        ),
      ],
    );
  }

  Widget _summaryTile(
    String label,
    String value,
    Color background,
    Color foreground,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 7,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        children: [
          Icon(icon, size: 19, color: foreground),
          const SizedBox(height: 5),
          Text(
            label,
            maxLines: 1,
            style: TextStyle(
              fontSize: 10,
              color: foreground,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          height: 19,
          width: 4,
          decoration: BoxDecoration(
            color: primary,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          'Assigned Work',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: dark,
          ),
        ),
        const Spacer(),
        Text(
          '$total Tasks',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: primary,
          ),
        ),
      ],
    );
  }

  Widget _buildTaskCard(WorkTask task) {
    final color = switch (task.status) {
      WorkStatus.completed => primary,
      WorkStatus.inProgress => const Color(0xFF3878DC),
      WorkStatus.pending => const Color(0xFFE26B73),
    };

    final status = switch (task.status) {
      WorkStatus.completed => 'Completed',
      WorkStatus.inProgress => 'In Progress',
      WorkStatus.pending => 'Pending',
    };

    final item = task.itemName.isNotEmpty
        ? task.itemName
        : task.title;

    final order = task.orderId.isNotEmpty
        ? task.orderId
        : task.id;

    final hasQuantity = task.assignedQuantity > 0;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        borderRadius: BorderRadius.circular(13),
        onTap: () => _openWorkPage(task: task),
        child: Container(
          decoration: _decoration(),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(13),
                      bottomLeft: Radius.circular(13),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                order,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  color: dark,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: Text(
                                status,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: color,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.chevron_right_rounded,
                              size: 19,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                        const SizedBox(height: 7),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                hasQuantity
                                    ? '$item (${task.assignedQuantity} pcs)'
                                    : item,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: dark,
                                ),
                              ),
                            ),
                            if (hasQuantity)
                              Text(
                                '${task.completedQuantity}/${task.assignedQuantity}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: color,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                          ],
                        ),
                        if (task.customerName.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Customer: ${task.customerName}',
                            style: const TextStyle(
                              fontSize: 10.5,
                              color: Color(0xFF64748B),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.schedule_rounded,
                              size: 13,
                              color: Color(0xFF94A3B8),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                task.time,
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  color: Color(0xFF64748B),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Icon(
                              Icons.edit_outlined,
                              size: 15,
                              color: Color(0xFF94A3B8),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _bottomButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 48,
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _openWorkPage(),
            icon: const Icon(Icons.add_circle_outline, size: 20),
            label: const Text(
              'Add New Work',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: gold,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 50),
      decoration: _decoration(),
      child: const Column(
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 45,
            color: Colors.grey,
          ),
          SizedBox(height: 12),
          Text(
            'No work assigned',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _decoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(13),
      border: Border.all(
        color: const Color(0xFFECEFF3),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.025),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }
}
