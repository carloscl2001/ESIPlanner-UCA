import 'package:esiplanner/shared/subject_colors.dart';
import 'package:flutter/material.dart';

class EventCard extends StatelessWidget {
  final Map<String, dynamic> eventData;
  final String Function(String) getGroupLabel;
  final Color subjectColor;
  final bool isDarkMode;
  final double estimatedLineHeight = 18.0;
  final double overflowThresholdHeight = 65.0;

  const EventCard({
    super.key,
    required this.eventData,
    required this.getGroupLabel,
    required this.subjectColor,
    required this.isDarkMode,
  });

  void _showEventDetails(BuildContext context) {
    final event = eventData['event'];
    final classType = eventData['classType'];
    final subjectName = eventData['subjectName'];
    final location = event['location'] ?? 'No especificado';
    final startTime = event['start_hour'];
    final endTime = event['end_hour'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.book, color: subjectColor, size: 24),
              const SizedBox(width: 8),
              Expanded(child: Text(subjectName, style: const TextStyle(fontWeight: FontWeight.bold))),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(Icons.school_rounded,  color: subjectColor, size: 16),
                    const SizedBox(width: 8),
                    Text('$classType - ${getGroupLabel(classType[0])}', style: const TextStyle(fontWeight: FontWeight.normal)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.schedule_outlined, color: subjectColor, size: 16),
                    const SizedBox(width: 8),
                    Text('$startTime - $endTime', style: const TextStyle(fontWeight: FontWeight.normal)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, color: subjectColor, size: 16),
                    const SizedBox(width: 8),
                    Text('$location', style: const TextStyle(fontWeight: FontWeight.normal)),
                  ],
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cerrar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final event = eventData['event'];
    final classType = eventData['classType'];
    final subjectName = eventData['subjectName'];
    final location = event['location'] ?? 'No especificado';

    int estimatedLines = 1;
    if ('$classType - ${getGroupLabel(classType[0])}'.isNotEmpty) estimatedLines++;
    if ('${event['start_hour']} - ${event['end_hour']}'.isNotEmpty) estimatedLines++;
    if (location.isNotEmpty) estimatedLines++;
    if (subjectName.length > 25) estimatedLines++;

    final hasEstimatedOverflow = estimatedLines * estimatedLineHeight > overflowThresholdHeight;
    final int maxLinesSubject = hasEstimatedOverflow ? 1 : 2;
    int maxLinesOther = 1; // Siempre 1 línea con icono

    return GestureDetector(
      onTap: hasEstimatedOverflow ? () => _showEventDetails(context) : null,
      child: Container(
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
              color: Colors.black.withAlpha(25),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 12, right: 8, top: 8, bottom: 8), // Reducido el padding izquierdo para el icono
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.book, size: 16, color: subjectColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      subjectName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black,
                        fontSize: 16,
                      ),
                      maxLines: maxLinesSubject,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.school, size: 14, color: subjectColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '$classType - ${getGroupLabel(classType[0])}',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.black87,
                        fontSize: 14,
                      ),
                      maxLines: maxLinesOther,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: subjectColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${event['start_hour']} - ${event['end_hour']}',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.black87,
                        fontSize: 14,
                      ),
                      maxLines: maxLinesOther,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.location_on, size: 14, color: subjectColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      location,
                      style: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.black87,
                        fontSize: 14,
                      ),
                      maxLines: maxLinesOther,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}