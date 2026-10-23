import '../models/dashboard_model.dart';

abstract class DashboardLocalDataSource {
  Future<DashboardModel> getDashboard();
}

class DashboardLocalDataSourceImpl
    implements DashboardLocalDataSource {
  @override
  Future<DashboardModel> getDashboard() async {
    const json = {
      'total_customers': 156,
      'total_orders': 248,
      'pending_orders': 12,
      'revenue': 48250,
      'appointments': [
        {
          'name': 'Anita Sharma',
          'time': '10:00 AM',
          'description': 'Trial - Blouse',
        },
        {
          'name': 'Vikram Mehta',
          'time': '12:30 PM',
          'description': 'Delivery - Suit',
        },
        {
          'name': 'Sneha Patel',
          'time': '04:00 PM',
          'description': 'Trial - Lehenga',
        },
      ],
    };

    return DashboardModel.fromJson(json);
  }
}