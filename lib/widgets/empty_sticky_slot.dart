import 'package:flutter/material.dart';

import '../theme/nampak_theme.dart';

class EmptyStickySlot extends StatelessWidget {
  final VoidCallback onTap;

  const EmptyStickySlot({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 112,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFD9D7D0), width: 1.5),
        ),
        child: const Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_rounded, color: nampakMutedText),
              SizedBox(width: 6),
              Flexible(
                child: Text(
                  'Place a Sticky Note Here',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: nampakMutedText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
