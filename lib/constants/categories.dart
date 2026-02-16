/// Expense Categories
const List<String> expenseCategories = [
  'Transport',
  'Meals',
  'Travel',
  'Office Supplies',
  'Entertainment',
  'Software',
  'Training',
  'Utilities',
  'Other',
];

/// Category Icons
const Map<String, String> categoryIcons = {
  'Transport': '🚗',
  'Meals': '🍽️',
  'Travel': '✈️',
  'Office Supplies': '📦',
  'Entertainment': '🎬',
  'Software': '💻',
  'Training': '📚',
  'Utilities': '⚡',
  'Other': '📋',
};

/// Get category icon
String getCategoryIcon(String category) {
  return categoryIcons[category] ?? '📋';
}

/// Policy limits per category (in Rupiah)
const Map<String, int> categoryLimits = {
  'Transport': 300000,
  'Meals': 150000,
  'Travel': 2000000,
  'Office Supplies': 500000,
  'Entertainment': 200000,
  'Software': 1000000,
  'Training': 1500000,
  'Utilities': 500000,
  'Other': 250000,
};

/// Manager approval threshold (in Rupiah)
const int approvalThreshold = 500000;

/// Budget category configuration
class BudgetCategory {
  final String name;
  final int limit;
  final int color;
  final String icon;

  const BudgetCategory({
    required this.name,
    required this.limit,
    required this.color,
    required this.icon,
  });
}

const List<BudgetCategory> budgetCategories = [
  BudgetCategory(
    name: 'Meals',
    limit: 20000000,
    color: 0xFFE35273,
    icon: '🍽️',
  ),
  BudgetCategory(
    name: 'Entertainment',
    limit: 15000000,
    color: 0xFF84CC16,
    icon: '🎬',
  ),
  BudgetCategory(
    name: 'Travel',
    limit: 10000000,
    color: 0xFF84CC16,
    icon: '✈️',
  ),
  BudgetCategory(
    name: 'Office Supplies',
    limit: 5000000,
    color: 0xFF4199D5,
    icon: '📎',
  ),
];

/// Department budget configuration
const Map<String, dynamic> departmentBudgetConfig = {
  'limit': 50000000,
  'department': 'Marketing Department',
};

/// Expense icons
const List<String> expenseIcons = [
  '🚗',
  '☕',
  '✈️',
  '🛍️',
  '🎉',
  '💰',
  '🏨',
  '🍽️',
  '⛽',
  '🚕',
];
