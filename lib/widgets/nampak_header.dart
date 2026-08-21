import 'package:flutter/material.dart';

import '../theme/nampak_theme.dart';

class NampakHeader extends StatelessWidget {
  final bool soundEnabled;
  final VoidCallback onSoundPressed;

  const NampakHeader({
    super.key,
    required this.soundEnabled,
    required this.onSoundPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nampak',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _todayText(),
                  style: const TextStyle(fontSize: 13, color: nampakMutedText),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onSoundPressed,
            tooltip: soundEnabled ? 'Sound on' : 'Sound off',
            icon: Icon(
              soundEnabled
                  ? Icons.volume_up_outlined
                  : Icons.volume_off_outlined,
              color: nampakText,
            ),
          ),
        ],
      ),
    );
  }
}

String _todayText() {
  final now = DateTime.now();
  const days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  return '${days[now.weekday - 1]} - ${months[now.month - 1]} ${now.day}';
}
