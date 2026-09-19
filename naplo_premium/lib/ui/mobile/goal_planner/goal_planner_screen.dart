import 'package:filcnaplo_kreta_api/models/grade.dart';
import 'package:filcnaplo_kreta_api/models/subject.dart';
import 'package:filcnaplo_kreta_api/providers/grade_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'goal_input.dart';
import 'goal_planner.dart';
import 'route_option.dart';

enum GoalPlannerResult {
  available,
  unreachable,
  unsolvable,
  reached,
}

class GoalPlannerScreen extends StatefulWidget {
  const GoalPlannerScreen({
    super.key,
    required this.subject,
  });

  final GradeSubject subject;

  @override
  State<GoalPlannerScreen> createState() => _GoalPlannerScreenState();
}

class _GoalPlannerScreenState extends State<GoalPlannerScreen> {
  double goalValue = 4.0;
  Plan? recommended;
  Plan? fastest;
  Plan? selectedRoute;
  List<Plan> otherPlans = [];

  List<Grade> get grades {
    return context
        .read<GradeProvider>()
        .grades
        .where((grade) => grade.subject == widget.subject)
        .where((grade) => grade.type == GradeType.midYear)
        .toList();
  }

  double get currentAverage {
    return GoalPlannerHelper.averageEvals(grades);
  }

  GoalPlannerResult calculate() {
    final average = currentAverage;

    recommended = null;
    fastest = null;
    otherPlans = [];

    if (average >= goalValue) {
      selectedRoute = null;
      return GoalPlannerResult.reached;
    }

    final plans = GoalPlanner(goalValue, grades).solve();

    if (plans.isEmpty) {
      selectedRoute = null;
      return GoalPlannerResult.unsolvable;
    }

    plans.sort(
      (a, b) => (a.avg - (2 * goalValue + 5) / 3)
          .abs()
          .compareTo((b.avg - (2 * goalValue + 5) / 3).abs()),
    );

    final singleSolution = plans.every((plan) => plan.sigma == 0);

    if (singleSolution) {
      recommended = plans.first;
    } else {
      final possible = plans.where((plan) => plan.sigma > 0).toList();
      if (possible.isNotEmpty) {
        recommended = possible.first;
      } else {
        recommended = plans.first;
      }
    }

    plans.removeWhere((plan) => plan == recommended);

    plans.sort(
      (a, b) => a.plan.length.compareTo(b.plan.length),
    );

    if (plans.isNotEmpty) {
      fastest = plans.first;
      plans.removeAt(0);
    }

    if (recommended != null &&
        fastest != null &&
        recommended!.plan.length - fastest!.plan.length >= 3) {
      recommended = fastest;
    }

    if (recommended == null) {
      selectedRoute = null;
      return GoalPlannerResult.unsolvable;
    }

    if (recommended!.plan.length > 10) {
      selectedRoute = null;
      return GoalPlannerResult.unreachable;
    }

    otherPlans = List<Plan>.from(plans);

    return GoalPlannerResult.available;
  }

  String resultText(GoalPlannerResult result) {
    switch (result) {
      case GoalPlannerResult.available:
        return '';
      case GoalPlannerResult.reached:
        return 'A kitűzött átlag már megvan.';
      case GoalPlannerResult.unreachable:
        return 'Ehhez a célhoz jelenleg túl sok új jegyre lenne szükség.';
      case GoalPlannerResult.unsolvable:
        return 'Nem találtam megvalósítható útvonalat ehhez a célhoz.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = calculate();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subject.renamedTo ?? widget.subject.name),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 220.0),
          children: [
            const Text(
              'Kitűzött cél',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              goalValue.toStringAsFixed(1),
              style: TextStyle(
                fontSize: 42.0,
                fontWeight: FontWeight.w900,
                color: gradeColor(goalValue.round()),
              ),
            ),
            const SizedBox(height: 24.0),
            if (result != GoalPlannerResult.available)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    resultText(result),
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            if (result == GoalPlannerResult.available) ...[
              const Text(
                'Lehetséges útvonalak',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12.0),
              if (recommended != null)
                RouteOption(
                  plan: recommended!,
                  mark: RouteMark.recommended,
                  selected: selectedRoute == recommended,
                  onSelected: () {
                    setState(() {
                      selectedRoute = recommended;
                    });
                  },
                ),
              if (fastest != null && fastest != recommended)
                RouteOption(
                  plan: fastest!,
                  mark: RouteMark.fastest,
                  selected: selectedRoute == fastest,
                  onSelected: () {
                    setState(() {
                      selectedRoute = fastest;
                    });
                  },
                ),
              ...otherPlans.map(
                (plan) => RouteOption(
                  plan: plan,
                  selected: selectedRoute == plan,
                  onSelected: () {
                    setState(() {
                      selectedRoute = plan;
                    });
                  },
                ),
              ),
            ],
          ],
        ),
      ),
      bottomSheet: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 12.0),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GoalInput(
                currentAverage: currentAverage,
                value: goalValue,
                onChanged: (value) {
                  setState(() {
                    goalValue = value;
                    selectedRoute = null;
                  });
                },
              ),
              const SizedBox(height: 16.0),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: selectedRoute == null
                      ? null
                      : () {
                          Navigator.of(context).pop();
                        },
                  child: const Text('Követés'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

