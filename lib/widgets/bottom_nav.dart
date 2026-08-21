import 'package:flutter/material.dart';

import '../theme/nampak_theme.dart';

class BottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const BottomNav({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.white,
      elevation: 10,
      padding: EdgeInsets.zero,
      height: 72,
      child: Row(
        children: [
          _BottomNavButton(
            icon: Icons.dashboard_outlined,
            label: 'Now',
            isActive: selectedIndex == 0,
            onTap: () => onChanged(0),
          ),
          _BottomNavButton(
            icon: Icons.inbox_outlined,
            label: 'Dump',
            isActive: selectedIndex == 1,
            onTap: () => onChanged(1),
          ),
          const SizedBox(width: 70),
          _BottomNavButton(
            icon: Icons.check_circle_outline_rounded,
            label: 'Done',
            isActive: selectedIndex == 2,
            onTap: () => onChanged(2),
          ),
          _BottomNavButton(
            icon: Icons.settings_outlined,
            label: 'Settings',
            isActive: selectedIndex == 3,
            onTap: () => onChanged(3),
          ),
        ],
      ),
    );
  }
}

class _BottomNavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _BottomNavButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? nampakPrimary : nampakMutedText;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 23),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
