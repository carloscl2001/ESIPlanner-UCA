import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'timetable_principal_logic.dart';
import '../timetable_week/timetable_week_screen.dart';

class WeekDaysHeaderDesktop extends StatelessWidget {
  final bool isDarkMode;

  const WeekDaysHeaderDesktop({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.black : Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16.0),
          bottomRight: Radius.circular(16.0),
        ),
        border: Border.all(
          color: isDarkMode ? Colors.yellow.shade700 : Colors.indigo,
          width: 4,
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.grey.withAlpha(115) : Colors.black.withAlpha(115),
            blurRadius: 8.0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['Lun', 'Mar', 'Mie', 'Jue', 'Vie'].map((day) {
            return SizedBox(
              child: Center(
                child: Text(
                  day,
                  style: TextStyle(
                    color: isDarkMode ? Colors.yellow.shade700 : Colors.indigo,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ),
            );
          }).toList(),
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
      physics: defaultTargetPlatform == TargetPlatform.iOS
          ? const BouncingScrollPhysics()
          : const ClampingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      itemCount: weeks.length,
      itemBuilder: (context, index) {
        final weekDays = weeks[index];
        final startDate = weekDays.first;
        final isCurrentWeek = index == currentWeekIndex;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
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
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade600,
              borderRadius: BorderRadius.circular(20.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: Text(
              DateFormat('MMMM', 'es_ES').format(startDate),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.white,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade600,
              borderRadius: BorderRadius.circular(20.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: Text(
              DateFormat('y', 'es_ES').format(startDate),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.white,
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
    return GestureDetector(
      onTap: () {
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
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isCurrentWeek
              ? Border.all(
                  color: isDarkMode ? Colors.yellow.shade700 : Colors.indigo,
                  width: 4,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: !isDarkMode
                  ? Colors.black.withAlpha(115)
                  : Colors.grey.withAlpha(115),
              blurRadius: 12.0,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: weekDays.map((day) {
            final hasClass = timetableLogic.dayHasClass(day);

            return SizedBox(
              width: 60,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    DateFormat('d', 'es_ES').format(day),
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                      fontSize: 32,
                    ),
                  ),
                  if (hasClass)
                    Positioned(
                      bottom: 4,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.white : Colors.black,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class BuildEmptyCardDesktop extends StatelessWidget {
  const BuildEmptyCardDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(24),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person,
                    size: 96,
                    color: Theme.of(context).disabledColor,
                  ),
                  Icon(
                    Icons.arrow_right_rounded, 
                    size: 96, 
                    color: Theme.of(context).disabledColor,
                  ),
                  Icon(
                    Icons.edit_note_rounded,
                    size: 96,
                    color: Theme.of(context).disabledColor,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Selecciona asignaturas en perfil',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).disabledColor,
                  fontSize: 24,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}