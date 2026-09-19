import 'package:flutter/widgets.dart';

class GoalProvider extends ChangeNotifier {
  GoalProvider({
    dynamic database,
    dynamic user,
  });

  bool hasDoneGoals = false;

  Future<void> fetchDone({dynamic gradeProvider}) async {
    hasDoneGoals = false;
    notifyListeners();
  }
}

