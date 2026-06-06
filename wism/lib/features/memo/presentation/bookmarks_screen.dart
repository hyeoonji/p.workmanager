import 'package:flutter/material.dart';

import '../domain/memo_repository.dart';
import 'widgets/memo_tab_scaffold.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) => const MemoTabScaffold(
        title: '북마크',
        scope: MemoScope.bookmarks,
        showFab: false,
      );
}
