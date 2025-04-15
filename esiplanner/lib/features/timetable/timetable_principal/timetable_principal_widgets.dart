import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'timetable_principal_logic.dart';
import '../timetable_week/timetable_week_screen.dart';

class WeekDaysHeader extends StatelessWidget {
  final bool isDarkMode;

  const WeekDaysHeader({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 600;
    
    return Container(
      margin: EdgeInsets.all(isDesktop ? 8 : 0),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.black : Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16.0),
          bottomRight: Radius.circular(16.0),
        ),
        border: Border.all(
          color: isDarkMode ? Colors.yellow.shade700 : Colors.indigo,
          width: isDesktop ? 4 : 3,
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.grey.withAlpha(115) : Colors.black.withAlpha(115),
            blurRadius: isDesktop ? 8.0 : 6.0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: isDesktop ? 16.0 : 8.0,
          horizontal: isDesktop ? 24.0 : 16.0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['Lun', 'Mar', 'Mie', 'Jue', 'Vie'].map((day) {
            return SizedBox(
              width: isDesktop ? 60 : 40,
              child: Center(
                child: Text(
                  day,
                  style: TextStyle(
                    color: isDarkMode ? Colors.yellow.shade700 : Colors.indigo,
                    fontWeight: FontWeight.bold,
                    fontSize: isDesktop ? 24 : 20,
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

class WeekSelector extends StatelessWidget {
  final TimetableLogic timetableLogic;
  final bool isDarkMode;

  const WeekSelector({
    super.key,
    required this.timetableLogic,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 600;
    final weeks = timetableLogic.getWeeksOfSemester();
    final currentWeekIndex = timetableLogic.getCurrentWeekIndex(weeks);

    return ListView.builder(
      key: const PageStorageKey('timetable'),
      shrinkWrap: false,
      physics: defaultTargetPlatform == TargetPlatform.iOS
          ? const BouncingScrollPhysics()
          : const ClampingScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 24 : 16,
        vertical: isDesktop ? 8 : 0,
      ),
      itemCount: weeks.length,
      itemBuilder: (context, index) {
        final weekDays = weeks[index];
        final startDate = weekDays.first;
        final isCurrentWeek = index == currentWeekIndex;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (index == 0 || timetableLogic.isNewMonth(weekDays, weeks[index - 1]))
              _buildMonthHeader(startDate, isDarkMode, isDesktop),
            WeekRow(
              weekDays: weekDays,
              weekIndex: index,
              isDarkMode: isDarkMode,
              isCurrentWeek: isCurrentWeek,
              timetableLogic: timetableLogic,
              isDesktop: isDesktop,
            ),
          ],
        );
      },
    );
  }

  Widget _buildMonthHeader(DateTime startDate, bool isDarkMode, bool isDesktop) {
    return Padding(
      padding: EdgeInsets.only(
        top: isDesktop ? 16.0 : 8.0,
        bottom: isDesktop ? 8.0 : 4.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade600,
              borderRadius: BorderRadius.circular(20.0),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 16.0 : 12.0,
              vertical: isDesktop ? 10.0 : 6.0,
            ),
            child: Text(
              DateFormat('MMMM', 'es_ES').format(startDate),
              style: TextStyle(
                fontSize: isDesktop ? 22 : 18,
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
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 16.0 : 12.0,
              vertical: isDesktop ? 10.0 : 6.0,
            ),
            child: Text(
              DateFormat('y', 'es_ES').format(startDate),
              style: TextStyle(
                fontSize: isDesktop ? 22 : 18,
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

class WeekRow extends StatelessWidget {
  final List<DateTime> weekDays;
  final int weekIndex;
  final bool isDarkMode;
  final bool isCurrentWeek;
  final TimetableLogic timetableLogic;
  final bool isDesktop;

  const WeekRow({
    super.key,
    required this.weekDays,
    required this.weekIndex,
    required this.isDarkMode,
    required this.isCurrentWeek,
    required this.timetableLogic,
    this.isDesktop = false,
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
        margin: EdgeInsets.symmetric(vertical: isDesktop ? 8.0 : 4.0),
        padding: EdgeInsets.symmetric(
          vertical: isDesktop ? 16 : 8,
          horizontal: isDesktop ? 8 : 0,
        ),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(isDesktop ? 20 : 16),
          border: isCurrentWeek
              ? Border.all(
                  color: isDarkMode ? Colors.yellow.shade700 : Colors.indigo,
                  width: isDesktop ? 4 : 3,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: !isDarkMode
                  ? Colors.black.withAlpha(115)
                  : Colors.grey.withAlpha(115),
              blurRadius: isDesktop ? 12.0 : 8.0,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: weekDays.map((day) {
            final hasClass = timetableLogic.dayHasClass(day);

            return SizedBox(
              width: isDesktop ? 60 : 40,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    DateFormat('d', 'es_ES').format(day),
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                      fontSize: isDesktop ? 32 : 26,
                    ),
                  ),
                  if (hasClass)
                    Positioned(
                      bottom: isDesktop ? 4 : 0,
                      child: Container(
                        width: isDesktop ? 8 : 5,
                        height: isDesktop ? 8 : 5,
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

class BuildEmptyCard extends StatelessWidget {
  const BuildEmptyCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 600;
    
    return Center(
      child: Card(
        margin: EdgeInsets.all(isDesktop ? 24 : 16),
        elevation: isDesktop ? 4 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
        ),
        child: Padding(
          padding: EdgeInsets.all(isDesktop ? 32.0 : 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person,
                    size: isDesktop ? 96 : 64,
                    color: Theme.of(context).disabledColor,
                  ),
                  Icon(
                    Icons.arrow_right_rounded, 
                    size: isDesktop ? 96 : 64, 
                    color: Theme.of(context).disabledColor,
                  ),
                  Icon(
                    Icons.edit_note_rounded,
                    size: isDesktop ? 96 : 64,
                    color: Theme.of(context).disabledColor,
                  ),
                ],
              ),
              SizedBox(height: isDesktop ? 24 : 16),
              Text(
                'Selecciona asignaturas en perfil',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).disabledColor,
                  fontSize: isDesktop ? 24 : null,
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