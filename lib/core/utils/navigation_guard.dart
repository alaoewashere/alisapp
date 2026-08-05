import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Debounces navigation triggered by taps.
///
/// GoRouter doesn't dedupe pushes: a fast double-tap on a card/tile fires
/// two `context.push` calls to the *same* location before the first Page
/// registers with the Navigator, and both end up with the same derived
/// key — Flutter's `_debugCheckDuplicatedPageKeys` assertion then crashes
/// the app. `pushGuarded`/`goGuarded` make repeat taps to the same location
/// within [_debounce] a no-op, which is exactly the idempotency a tap
/// handler needs (a second push to a *different* location is untouched).
const _debounce = Duration(milliseconds: 600);

String? _lastLocation;
DateTime? _lastPushAt;

bool _shouldSkip(String location) {
  final now = DateTime.now();
  final skip = _lastLocation == location &&
      _lastPushAt != null &&
      now.difference(_lastPushAt!) < _debounce;
  _lastLocation = location;
  _lastPushAt = now;
  return skip;
}

extension NavigationGuard on BuildContext {
  /// Guarded `context.push` — ignores a repeat push to the same [location]
  /// within the debounce window instead of stacking a duplicate page.
  Future<T?>? pushGuarded<T extends Object?>(String location, {Object? extra}) {
    if (!mounted || _shouldSkip(location)) return null;
    return push<T>(location, extra: extra);
  }

  /// Guarded `context.go` — same debounce as [pushGuarded].
  void goGuarded(String location, {Object? extra}) {
    if (!mounted || _shouldSkip(location)) return;
    go(location, extra: extra);
  }
}
