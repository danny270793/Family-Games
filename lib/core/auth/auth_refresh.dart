import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Notifies [GoRouter] when the Supabase session changes.
class AuthRefresh extends ChangeNotifier {
  AuthRefresh() {
    _subscription = Supabase.instance.client.auth.onAuthStateChange.listen((
      _,
    ) {
      notifyListeners();
    });
  }

  late final StreamSubscription<AuthState> _subscription;

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
