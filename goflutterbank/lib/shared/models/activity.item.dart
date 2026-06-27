enum ActivityType { sent, received, payment }

class ActivityItem {
  final ActivityType type;
  final String title;
  final String subtitle;
  final double amount;

  const ActivityItem({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.amount,
  });
}
