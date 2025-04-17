import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'timetable_principal_logic.dart';
import '../timetable_week/timetable_week_screen.dart';

class WeekDaysHeaderMobile extends StatelessWidget {
  final bool isDarkMode;

  const WeekDaysHeaderMobile({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.black : Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16.0),
          bottomRight: Radius.circular(16.0),
        ),
        border: Border.all(
          color: isDarkMode ? Colors.yellow.shade700 : Colors.indigo,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.grey.withAlpha(115) : Colors.black.withAlpha(115),
            blurRadius: 6.0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['Lun', 'Mar', 'Mie', 'Jue', 'Vie'].map((day) {
            return SizedBox(
              width: 40,
              child: Center(
                child: Text(
                  day,
                  style: TextStyle(
                    color: isDarkMode ? Colors.yellow.shade700 : Colors.indigo,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
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

class WeekSelectorMobile extends StatelessWidget {
  final TimetablePrincipalLogic timetableLogic;
  final bool isDarkMode;

  const WeekSelectorMobile({
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
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
            WeekRowMobile(
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
      padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey : Colors.grey,
              borderRadius: BorderRadius.circular(20.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
            child: Text(
              DateFormat('MMMM', 'es_ES').format(startDate),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.white,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey: Colors.grey,
              borderRadius: BorderRadius.circular(20.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
            child: Text(
              DateFormat('y', 'es_ES').format(startDate),
              style: TextStyle(
                fontSize: 18,
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

class WeekRowMobile extends StatelessWidget {
  final List<DateTime> weekDays;
  final int weekIndex;
  final bool isDarkMode;
  final bool isCurrentWeek;
  final TimetablePrincipalLogic timetableLogic;

  const WeekRowMobile({
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
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isCurrentWeek
              ? Border.all(
                  color: isDarkMode ? Colors.yellow.shade700 : Colors.indigo,
                  width: 3,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: !isDarkMode
                  ? Colors.black.withAlpha(115)
                  : Colors.grey.withAlpha(115),
              blurRadius: 8.0,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: weekDays.map((day) {
            final hasClass = timetableLogic.dayHasClass(day);

            return SizedBox(
              width: 40,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    DateFormat('d', 'es_ES').format(day),
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                      fontSize: 26,
                    ),
                  ),
                  if (hasClass)
                    Positioned(
                      bottom: 0,
                      child: Container(
                        width: 5,
                        height: 5,
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

class BuildEmptyCardMobile extends StatelessWidget {
  const BuildEmptyCardMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(16),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person,
                    size: 64,
                    color: Theme.of(context).disabledColor,
                  ),
                  Icon(
                    Icons.arrow_right_rounded, 
                    size: 64, 
                    color: Theme.of(context).disabledColor,
                  ),
                  Icon(
                    Icons.edit_note_rounded,
                    size: 64,
                    color: Theme.of(context).disabledColor,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Selecciona asignaturas en perfil',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).disabledColor,
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