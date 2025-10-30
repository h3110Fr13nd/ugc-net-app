import 'package:flutter/material.dart';

class CardList extends StatelessWidget {
  final int count;
  final IndexedWidgetBuilder itemBuilder;

  const CardList({super.key, required this.count, required this.itemBuilder});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) => Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: itemBuilder(context, index),
        ),
      ),
    );
  }
}
