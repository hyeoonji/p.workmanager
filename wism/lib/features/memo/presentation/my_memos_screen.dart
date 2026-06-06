import 'package:flutter/material.dart';

import '../domain/memo_repository.dart';
import 'widgets/memo_tab_scaffold.dart';

class MyMemosScreen extends StatelessWidget {
  const MyMemosScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const MemoTabScaffold(title: '내 메모', scope: MemoScope.my);
}
