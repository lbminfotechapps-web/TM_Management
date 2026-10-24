
enum AttendanceStatus {
  present,
  absent,
  holiday,
}

enum WorkStatus {
  completed,
  pending,
  inProgress,
}


class WorkTask {
  final String id;
  final String title;
  final String description;
  final WorkStatus status;
  final String time;

  final String orderId;
  final String customerName;
  final String itemName;
  final int assignedQuantity;
  final int completedQuantity;
  final String startTime;
  final String expectedCompletion;
  final String actualCompletion;
  final String notes;

  const WorkTask({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.time,
    this.orderId = '',
    this.customerName = '',
    this.itemName = '',
    this.assignedQuantity = 0,
    this.completedQuantity = 0,
    this.startTime = '',
    this.expectedCompletion = '',
    this.actualCompletion = '',
    this.notes = '',
  });
}

class TeamWorkModel {
  final int id;
  final String name;
  final String role;
  final AttendanceStatus attendance;
  final List<WorkTask> tasks;

  const TeamWorkModel({
    required this.id,
    required this.name,
    required this.role,
    required this.attendance,
    required this.tasks,
  });

  int get total => tasks.length;

  int get completed =>
      tasks.where((e) => e.status == WorkStatus.completed).length;

  int get pending =>
      tasks.where((e) => e.status != WorkStatus.completed).length;

  int get inProgress =>
      tasks.where((e) => e.status == WorkStatus.inProgress).length;

  double get progress =>
      total == 0 ? 0 : completed / total;

  int get percentage => (progress * 100).round();

  TeamWorkModel copyWith({
    int? id,
    String? name,
    String? role,
    AttendanceStatus? attendance,
    List<WorkTask>? tasks,
  }) {
    return TeamWorkModel(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      attendance: attendance ?? this.attendance,
      tasks: tasks ?? this.tasks,
    );
  }
}

class TeamWorkDemoData {
  static List<WorkTask> makeTasks(int total, int completed) {
    const names = [
      'Men\'s Shirt',
      'Ladies Kurti',
      'Blouse',
      'Pant',
      'School Uniform',
      'Designer Dress',
      'Coat',
      'Trouser',
      'Salwar Suit',
      'Wedding Blouse',
    ];

    const customers = [
      'Sunita Patil',
      'Rahul Sharma',
      'Priya Deshmukh',
      'Amit Kumar',
      'Neha Shah',
    ];

    return List.generate(total, (index) {
      final isCompleted = index < completed;

      final status = isCompleted
          ? WorkStatus.completed
          : index == completed
              ? WorkStatus.inProgress
              : WorkStatus.pending;

      final quantity = (index % 5) + 1;

      final completedQty = isCompleted
          ? quantity
          : status == WorkStatus.inProgress
              ? 1
              : 0;

      final start = '09:00 AM';
      final expected = '03:00 PM';

      return WorkTask(
        id: 'ORD-${(index + 1).toString().padLeft(3, '0')}',
        title: names[index % names.length],
        description: 'Work assigned to team member',
        status: status,
        time: '$start - $expected',

        orderId: 'ORD-${(index + 1).toString().padLeft(3, '0')}',
        customerName: customers[index % customers.length],
        itemName: names[index % names.length],
        assignedQuantity: quantity,
        completedQuantity: completedQty,
        startTime: start,
        expectedCompletion: expected,
        actualCompletion: isCompleted ? '02:30 PM' : '',
        notes: isCompleted
            ? 'Work completed successfully'
            : 'Complete the assigned work',
      );
    });
  }

  static final members = <TeamWorkModel>[
    TeamWorkModel(
      id: 1,
      name: 'Ramesh Kumar',
      role: 'Master Tailor',
      attendance: AttendanceStatus.present,
      tasks: makeTasks(20, 17),
    ),
    TeamWorkModel(
      id: 2,
      name: 'Sita Devi',
      role: 'Tailor',
      attendance: AttendanceStatus.present,
      tasks: makeTasks(5, 4),
    ),
    TeamWorkModel(
      id: 3,
      name: 'Imran Khan',
      role: 'Cutter',
      attendance: AttendanceStatus.absent,
      tasks: makeTasks(3, 0),
    ),
    TeamWorkModel(
      id: 4,
      name: 'Pooja Sharma',
      role: 'Helper',
      attendance: AttendanceStatus.present,
      tasks: makeTasks(4, 3),
    ),
    TeamWorkModel(
      id: 5,
      name: 'Arjun Patel',
      role: 'Manager',
      attendance: AttendanceStatus.present,
      tasks: makeTasks(2, 0),
    ),
    TeamWorkModel(
      id: 6,
      name: 'Neha Singh',
      role: 'Tailor',
      attendance: AttendanceStatus.holiday,
      tasks: makeTasks(4, 0),
    ),
  ];
}
