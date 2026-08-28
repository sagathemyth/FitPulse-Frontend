class Session {
  static int? userId;
  static String? userName;
  static String? userEmail;
  static String? username;
  static DateTime? memberSince;
  static int? age;
  static String? biologicalSex;
  static double? heightCm;
  static double? weightKg;

  static void setUser(
    int id,
    String name,
    String email, {
    String? username,
    DateTime? memberSince,
    int? age,
    String? biologicalSex,
    double? heightCm,
    double? weightKg,
  }) {
    userId = id;
    userName = name;
    userEmail = email;
    if (username != null) Session.username = username;
    if (memberSince != null) Session.memberSince = memberSince;
    Session.age = age;
    Session.biologicalSex = biologicalSex;
    Session.heightCm = heightCm;
    Session.weightKg = weightKg;
  }

  static void clear() {
    userId = null;
    userName = null;
    userEmail = null;
    username = null;
    memberSince = null;
    age = null;
    biologicalSex = null;
    heightCm = null;
    weightKg = null;
  }

  static bool get isLoggedIn => userId != null;

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  /// "Member since Aug 2026" style label, or null if unknown
  /// (e.g. accounts created before this field existed).
  static String? get memberSinceLabel {
    final d = memberSince;
    if (d == null) return null;
    return 'Member since ${_months[d.month - 1]} ${d.year}';
  }
}
