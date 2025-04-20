import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'timetable_principal_logic.dart';
import '../timetable_week/timetable_week_screen.dart';

class WeekDaysHeaderDesktop extends StatelessWidget {
  final bool isDarkMode;
  final TimetablePrincipalLogic timetableLogic;

  const WeekDaysHeaderDesktop({super.key, required this.isDarkMode, required this.timetableLogic});

  @override
  Widget build(BuildContext context) {
    final accentColor = isDarkMode ? Colors.yellow.shade700 : Colors.white;
    final bgColor = isDarkMode ? Colors.black : Colors.blue.shade900;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(5, (index) {
            final dayNames = timetableLogic.weekFullDays;
            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                // decoration: BoxDecoration(
                //   border: Border(
                //     bottom: BorderSide(
                //       color: accentColor,
                //       width: 2,
                //     ),
                //   ),
                // ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Center(
                    child: Text(
                      dayNames[index],
                      style: TextStyle(
                        color: accentColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class WeekSelectorDesktop extends StatelessWidget {
  final TimetablePrincipalLogic timetableLogic;
  final bool isDarkMode;

  const WeekSelectorDesktop({
    super.key,
    required this.timetableLogic,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final weeks = timetableLogic.getWeeksOfSemester();
    final currentWeekIndex = timetableLogic.getCurrentWeekIndex(weeks);

    return ListView.builder(
      key: const PageStorageKey('timetable'),
      shrinkWrap: false,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: weeks.length,
      itemBuilder: (context, index) {
        final weekDays = weeks[index];
        final startDate = weekDays.first;
        final isCurrentWeek = index == currentWeekIndex;

        return Column(
          children: [
            if (index == 0 || timetableLogic.isNewMonth(weekDays, weeks[index - 1]))
              _buildMonthHeader(startDate, isDarkMode),
            WeekRowDesktop(
              weekDays: weekDays,
              weekIndex: index,
              isDarkMode: isDarkMode,
              isCurrentWeek: isCurrentWeek,
              timetableLogic: timetableLogic,
            ),
          ],
        );
      },
    );
  }

  Widget _buildMonthHeader(DateTime startDate, bool isDarkMode) {
    final bgColor = isDarkMode ? Colors.grey[800]! : Colors.grey[600]!;
    
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Container(
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Text(
                DateFormat('MMMM', 'es_ES').format(startDate),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Flexible(
            child: Container(
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Text(
                DateFormat('y').format(startDate),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WeekRowDesktop extends StatelessWidget {
  final List<DateTime> weekDays;
  final int weekIndex;
  final bool isDarkMode;
  final bool isCurrentWeek;
  final TimetablePrincipalLogic timetableLogic;

  const WeekRowDesktop({
    super.key,
    required this.weekDays,
    required this.weekIndex,
    required this.isDarkMode,
    required this.isCurrentWeek,
    required this.timetableLogic,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = isDarkMode ? Colors.yellow.shade700 : Colors.indigo;
    final bgColor = isDarkMode ? Colors.grey[850]! : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    
    return GestureDetector(
      onTap: () => _navigateToWeekScreen(context),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: isCurrentWeek
              ? Border.all(color: accentColor, width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: List.generate(5, (index) {
              final day = weekDays[index];
              final hasClass = timetableLogic.dayHasClass(day);
              
              return Expanded(
                child: _buildDayCell(day, hasClass, textColor, accentColor),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildDayCell(DateTime day, bool hasClass, Color textColor, Color accentColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          DateFormat('d').format(day),
          style: TextStyle(
            color: textColor,
            fontSize: 28,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(
          height: 8, // Misma altura que el punto
          child: hasClass
              ? Container(
                  decoration: BoxDecoration(
                    color: accentColor,
                    shape: BoxShape.circle,
                  ),
                )
              : const SizedBox.shrink(), // Widget vacío cuando no hay clase
        ),
      ],
    );
  }

  void _navigateToWeekScreen(BuildContext context) {
    final weekRange = timetableLogic.weekRanges[weekIndex];
    final allEvents = timetableLogic.getFilteredEvents(weekRange);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TimetableWeekScreen(
          events: allEvents,
          selectedWeekIndex: weekIndex,
          isDarkMode: isDarkMode,
          weekStartDate: weekDays.first,
        ),
      ),
    );
  }
}

class BuildEmptyCardDesktop extends StatelessWidget {
  const BuildEmptyCardDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white70 : Colors.black54;
    
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        margin: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_outlined,
              size: 120,
              color: textColor,
            ),
            const SizedBox(height: 24),
            Text(
              'Planifica tu horario',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Selecciona tus asignaturas en la sección de perfil para comenzar a visualizar tu horario semanal',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: textColor,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () {
                // Navegar a la sección de perfil
              },
              icon: const Icon(Icons.person),
              label: const Text('Ir a Perfil'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}