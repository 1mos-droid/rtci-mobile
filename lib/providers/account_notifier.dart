import 'dart:async';
import 'package:flutter/foundation.dart';

/// Cancels account listeners and ignores work that finishes after a provider
/// has been replaced on an account or role change.
class AccountNotifier extends ChangeNotifier {
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  bool _disposed = false;
  bool get isDisposed => _disposed;

  void trackSubscription(StreamSubscription<dynamic> subscription) {
    if (_disposed) {
      unawaited(subscription.cancel());
    } else {
      _subscriptions.add(subscription);
    }
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    for (final subscription in _subscriptions) {
      unawaited(subscription.cancel());
    }
    _subscriptions.clear();
    super.dispose();
  }
}
