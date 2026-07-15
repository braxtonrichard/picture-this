/// A single 4pt-based spacing scale, used everywhere instead of magic
/// numbers so the whole app breathes consistently.
class AppSpacing {
  const AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
  static const double huge = 64;
}

/// Corner radii — generously rounded, matching the soft, warm visual
/// language (large radii on photo cards, pill shapes on chips/buttons).
class AppRadius {
  const AppRadius._();

  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 28;
  static const double pill = 999;
}
