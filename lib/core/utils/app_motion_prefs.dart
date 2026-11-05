/// Mirrors the Reduce motion setting for code that runs without a
/// BuildContext, such as controllers and route builders.
abstract final class AppMotionPrefs {
  static bool reduced = false;
}
