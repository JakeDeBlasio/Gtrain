enum UserRole {
  admin('Admin'),
  trainingManager('Training Manager'),
  user('User'),
  teammate('Teammate');

  const UserRole(this.displayName);

  final String displayName;

  /// Convert role string from Firestore to enum
  static UserRole fromString(String? value) {
    return switch (value) {
      'admin' => UserRole.admin,
      'trainingManager' => UserRole.trainingManager,
      'user' => UserRole.user,
      'teammate' => UserRole.teammate,
      _ => UserRole.user, // Default to 'user'
    };
  }

  /// Get the role as a string for Firestore storage
  String toStorageString() {
    return name;
  }
}

extension UserRoleExtension on UserRole {
  /// Check if this role can access a specific page
  bool canAccess(NavigationPage page) {
    return switch (this) {
      UserRole.admin => true, // Admin can access everything
      UserRole.trainingManager => page != NavigationPage.users,
      UserRole.user => [
        NavigationPage.compliance,
        NavigationPage.trainings,
        NavigationPage.users,
        NavigationPage.userDetail,
      ].contains(page),
      UserRole.teammate => [
        NavigationPage.dashboard,
        NavigationPage.userDetail,
      ].contains(page), // Teammate can only see their own training records
    };
  }
}

enum NavigationPage {
  dashboard('Overview'),
  compliance('Matrix'),
  users('Users'),
  trainings('Trainings'),
  templates('Templates'),
  userDetail('User Detail');

  const NavigationPage(this.label);

  final String label;
}
