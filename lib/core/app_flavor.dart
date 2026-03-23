enum AppFlavor { user, admin }

class AppConfig {
  static AppFlavor flavor = AppFlavor.user;
  static bool get isAdmin => flavor == AppFlavor.admin;
}
