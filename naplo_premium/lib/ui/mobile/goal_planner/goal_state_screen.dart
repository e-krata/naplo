import 'package:filcnaplo_kreta_api/models/subject.dart';
import 'package:flutter/material.dart';

class GoalStateScreen extends StatelessWidget {
  const GoalStateScreen({super.key, required this.subject});
  final GradeSubject subject;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(subject.renamedTo ?? subject.name)),
      body: const Center(
        child: Text('A cél követése még nincs elmentve ehhez a tárgyhoz.'),
      ),
    );
  }
}
