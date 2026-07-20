class DashboardSummary {
  final int totalChanges;
  final int totalUsers;
  final int activeUsers;
  final int inactiveUsers;

  DashboardSummary({
    required this.totalChanges,
    required this.totalUsers,
    required this.activeUsers,
    required this.inactiveUsers,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      totalChanges: json['totalChanges'],
      totalUsers: json['totalUsers'],
      activeUsers: json['activeUsers'],
      inactiveUsers: json['inactiveUsers'],
    );
  }
}

class DealerHistory {
  final String name;
  final String date;
  final String dealer1;
  final String dealer2;
  final String dealer3;

  DealerHistory({
    required this.name,
    required this.date,
    required this.dealer1,
    required this.dealer2,
    required this.dealer3,
  });

  factory DealerHistory.fromJson(Map<String, dynamic> json) {
    return DealerHistory(
      name: json['name'],
      date: formatDate(json["date"]),
      dealer1: json['dealer1'],
      dealer2: json['dealer2'],
      dealer3: json['dealer3'],
    );
  }
  static String formatDate(String value) {
    DateTime date = DateTime.parse(value);

    return "${date.day.toString().padLeft(2, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.year}";
  }
}
