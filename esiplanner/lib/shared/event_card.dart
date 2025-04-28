import 'package:esiplanner/shared/subject_colors.dart';
import 'package:flutter/material.dart';

class EventCard extends StatelessWidget {
  final Map<String, dynamic> eventData;
  final String Function(String) getGroupLabel;
  final Color subjectColor;
  final bool isDarkMode;

  const EventCard({
    super.key,
    required this.eventData,
    required this.getGroupLabel,
    required this.subjectColor,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final event = eventData['event'];
    final classType = eventData['classType'];
    final subjectName = eventData['subjectName'];
    final location = event['location'] ?? 'No especificado';

    return Container(
      margin: const EdgeInsets.only(left: 2, right: 2, top: 1, bottom: 1),
      decoration: BoxDecoration(
        color: SubjectColors.getCardBackgroundColor(subjectColor, isDarkMode),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: subjectColor,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25), // 0.1 opacity equivalent
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 8, top: 8, bottom: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subjectName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
                fontSize: 16,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '$classType - ${getGroupLabel(classType[0])}',
              style: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.black87,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${event['start_hour']} - ${event['end_hour']}',
              style: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.black87,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              location,
              style: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.black87,
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}