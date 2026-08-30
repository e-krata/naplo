import 'package:filcnaplo/models/settings.dart';
import 'package:flutter/widgets.dart';

class PremiumProvider extends ChangeNotifier {
  final SettingsProvider _settings;
  List<String> get scopes => PremiumScopes.values.map((e) => e.name).toList();
  bool hasScope(String scope) => scopes.contains(scope) || scopes.contains(PremiumScopes.all);
  String get accessToken => _settings.premiumAccessToken;
  String get login => _settings.premiumLogin;
  bool get hasPremium => true;
  bool hasScope(PremiumScopes scope) => true;


  late final PremiumAuth _auth;
  PremiumAuth get auth => _auth;

  PremiumProvider({required SettingsProvider settings}) : _settings = settings {
    _auth = PremiumAuth(settings: _settings);
    _settings.addListener(() {
      notifyListeners();
    });
  }

  Future<void> activate({bool removePremium = false}) async {
    await _auth.refreshAuth(removePremium: removePremium);
    notifyListeners();
  }
}
