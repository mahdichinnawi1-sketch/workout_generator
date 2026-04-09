import 'package:flutter/material.dart';

class CustomChipGrid extends StatelessWidget {
  final List<String> items;
  final String selected;
  final Function(String) onSelected;

  const CustomChipGrid({
    super.key,
    required this.items,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: items.map((item) {
        bool isSelected = selected == item;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: FilterChip(
            selected: isSelected,
            label: Text(item),
            onSelected: (selected) {
              if (selected) onSelected(item);
            },
            backgroundColor: Colors.grey[800],
            selectedColor: Theme.of(context).primaryColor.withOpacity(0.3),
            checkmarkColor: Theme.of(context).primaryColor,
            labelStyle: TextStyle(
              color: isSelected ? Theme.of(context).primaryColor : Colors.white70,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            shape: StadiumBorder(
              side: BorderSide(
                color: isSelected ? Theme.of(context).primaryColor : Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}