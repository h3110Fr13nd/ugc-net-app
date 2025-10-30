import 'package:flutter/material.dart';

class OptionTile extends StatelessWidget {
  final String text;
  final String? selected;
  final VoidCallback? onTap;

  const OptionTile({super.key, required this.text, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == text;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? Theme.of(context).colorScheme.primary.withAlpha(20) : null,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Expanded(child: Text(text)),
              if (isSelected) Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary)
            ],
          ),
        ),
      ),
    );
  }
}
