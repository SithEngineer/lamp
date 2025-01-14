/// Centralized spacing and sizing constants
/// All padding, margins, and dimensions should use these constants
class AppSpacing {
  // Private constructor to prevent instantiation
  AppSpacing._();

  // Core spacing units (base unit = 4dp)
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;

  // Component specific sizes
  static const double colorChipSize = 40.0;
  static const double colorChipMargin = 4.0;
  static const double bottomBarHeight = 80.0;
  static const double helpTextSize = 24.0;

  // Animation durations
  static const Duration colorTransitionDuration = Duration(milliseconds: 300);
}
