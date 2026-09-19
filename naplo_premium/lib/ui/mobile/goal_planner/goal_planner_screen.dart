import 'package:filcnaplo_kreta_api/models/grade.dart';
import 'package:filcnaplo_kreta_api/models/subject.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:filcnaplo_kreta_api/providers/grade_provider.dart';
import 'package:naplo_premium/ui/mobile/goal_planner/goal_input.dart';
import 'package:naplo_premium/ui/mobile/goal_planner/goal_planner.dart';
import 'package:naplo_premium/ui/mobile/goal_planner/route_option.dart';

class GoalPlannerScreen extends StatefulWidget {
  const GoalPlannerScreen({super.key, required this.subject});
  final GradeSubject subject;
  @override
  State<GoalPlannerScreen> createState() => _GoalPlannerScreenState();
}

class _GoalPlannerScreenState extends State<GoalPlannerScreen> {
  double goal = 4.0;
  Plan? selected;

  List<Grade> get grades => Provider.of<GradeProvider>(context, listen: false)
      .grades.where((g) => g.subject == widget.subject).toList();

  @override
  Widget build(BuildContext context) {
    final current = GoalPlannerHelper.averageEvals(grades);
    final value = goal.clamp(current, 5.0);
    final plans = current >= value ? <Plan>[] : GoalPlanner(value, grades).solve();
    final sorted = List<Plan>.from(plans)..sort((a, b) => a.plan.length.compareTo(b.plan.length));

    return Scaffold(
      appBar: AppBar(title: const Text('Céltervező')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Jelenlegi átlag: '+current.toStringAsFixed(2)),
          const SizedBox(height: 20),
          GoalInput(
            currentAverage: current,
            value: value,
            onChanged: (v) => setState(() { goal = v; selected = null; }),
          ),
          const SizedBox(height: 20),
          if (current >= value)
            const Text('A kitűzött cél már teljesült.')
          else if (sorted.isEmpty)
            const Text('Ehhez a célhoz jelenleg nem találtam megoldást.')
          else
            ...sorted.take(5).map((p) => RouteOption(
              plan: p,
              selected: selected == p,
              onSelected: () => setState(() => selected = p),
            )),
        ],
      ),
    );
  }
}
