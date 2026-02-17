/// User profile response from the API
class UserProfile {
  final String id;
  final String email;
  final String name;
  final String? firstName;
  final String? phone;
  final String? employeeId;
  final String? jobTitle;
  final int jobLevel;
  final String? jobLevelName;
  final String? departmentId;
  final String? departmentName;
  final String? managerId;
  final String? managerName;
  final String status;
  final List<UserRole> roles;
  final List<String> permissions;
  final DateTime? createdAt;

  UserProfile({
    required this.id,
    required this.email,
    required this.name,
    this.firstName,
    this.phone,
    this.employeeId,
    this.jobTitle,
    this.jobLevel = 0,
    this.jobLevelName,
    this.departmentId,
    this.departmentName,
    this.managerId,
    this.managerName,
    this.status = 'active',
    this.roles = const [],
    this.permissions = const [],
    this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? _extractFirstName(json['name']?.toString() ?? ''),
      phone: json['phone']?.toString(),
      employeeId: json['employeeId']?.toString(),
      jobTitle: json['jobTitle']?.toString(),
      jobLevel: json['jobLevel'] is int ? json['jobLevel'] : int.tryParse(json['jobLevel']?.toString() ?? '0') ?? 0,
      jobLevelName: json['jobLevelName']?.toString(),
      departmentId: json['departmentId']?.toString(),
      departmentName: json['departmentName']?.toString(),
      managerId: json['managerId']?.toString(),
      managerName: json['managerName']?.toString(),
      status: json['status']?.toString() ?? 'active',
      roles: (json['roles'] as List<dynamic>?)
              ?.map((r) => UserRole.fromJson(r as Map<String, dynamic>))
              .toList() ??
          [],
      permissions: (json['permissions'] as List<dynamic>?)
              ?.map((p) => p.toString())
              .toList() ??
          [],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  static String _extractFirstName(String fullName) {
    final parts = fullName.split(' ');
    return parts.isNotEmpty ? parts.first : '';
  }

  /// Get user initials for avatar display
  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return 'U';
  }

  /// Check if user can approve expenses
  /// Manager (jobLevel >= 3) can approve
  bool get canApprove {
    return permissions.contains('approval:approve') ||
        permissions.contains('approval:*') ||
        jobLevel >= 3;
  }

  /// Check if user can view budgets
  /// Manager (jobLevel >= 3) can view budgets
  bool get canViewBudgets {
    return permissions.contains('budget:read') ||
        permissions.contains('budget:*') ||
        jobLevel >= 3;
  }

  /// Check if user is a Manager
  bool get isManager => jobLevel >= 3;

  /// Check if user is an Employee/Staff
  bool get isEmployee => jobLevel < 3;

  /// Check if user is an Admin
  /// Admin has role 'admin' or high job level (5+) or specific admin permissions
  bool get isAdmin {
    // Check roles for admin
    if (roles.any((r) => r.name.toLowerCase() == 'admin')) {
      return true;
    }
    // Check permissions for admin privileges
    if (permissions.contains('admin:*') ||
        permissions.contains('user:*') ||
        permissions.contains('audit:*')) {
      return true;
    }
    // High job level (VP/Director level) can see all audit logs
    if (jobLevel >= 5) {
      return true;
    }
    return false;
  }

  /// Determine navigation type based on permissions
  String get navType => canApprove ? 'approver' : 'spender';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'firstName': firstName,
      'phone': phone,
      'employeeId': employeeId,
      'jobTitle': jobTitle,
      'jobLevel': jobLevel,
      'jobLevelName': jobLevelName,
      'departmentId': departmentId,
      'departmentName': departmentName,
      'managerId': managerId,
      'managerName': managerName,
      'status': status,
      'roles': roles.map((r) => r.toJson()).toList(),
      'permissions': permissions,
    };
  }
}

/// User role
class UserRole {
  final String id;
  final String name;
  final String? description;

  UserRole({
    required this.id,
    required this.name,
    this.description,
  });

  factory UserRole.fromJson(Map<String, dynamic> json) {
    return UserRole(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }
}

/// User capabilities based on roles and permissions
class UserCapabilities {
  final bool canApprove;
  final bool canViewBudgets;
  final bool canManageUsers;
  final bool canManageCategories;
  final bool canManageWorkflows;
  final String navType;

  UserCapabilities({
    this.canApprove = false,
    this.canViewBudgets = false,
    this.canManageUsers = false,
    this.canManageCategories = false,
    this.canManageWorkflows = false,
    this.navType = 'spender',
  });

  factory UserCapabilities.fromPermissions(List<String> permissions, int jobLevel) {
    final hasApprovalPerm = permissions.contains('approval:approve') ||
        permissions.contains('approval:*');
    final hasBudgetPerm = permissions.contains('budget:read') ||
        permissions.contains('budget:*');
    final hasUserPerm = permissions.contains('user:write') ||
        permissions.contains('user:*');
    final hasCategoryPerm = permissions.contains('category:write') ||
        permissions.contains('category:*');
    final hasWorkflowPerm = permissions.contains('workflow:write') ||
        permissions.contains('workflow:*');

    // Manager (jobLevel >= 3) can approve and view budgets
    final canApprove = hasApprovalPerm || jobLevel >= 3;
    final canViewBudgets = hasBudgetPerm || jobLevel >= 3;

    return UserCapabilities(
      canApprove: canApprove,
      canViewBudgets: canViewBudgets,
      canManageUsers: hasUserPerm || jobLevel >= 5,
      canManageCategories: hasCategoryPerm || jobLevel >= 4,
      canManageWorkflows: hasWorkflowPerm || jobLevel >= 4,
      navType: canApprove ? 'approver' : 'spender',
    );
  }
}
