import 'package:flutter/material.dart';

import '../domain/memo_repository.dart';
import 'widgets/memo_tab_scaffold.dart';

class AllMemosScreen extends StatelessWidget {
  const AllMemosScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const MemoTabScaffold(title: '전체 메모', scope: MemoScope.all);
}
