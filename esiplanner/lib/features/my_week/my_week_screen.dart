import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import 'my_week_logic.dart';
import 'my_week_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late HomeLogic _logic;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _logic = HomeLogic(context);
    _pageController = PageController(initialPage: _logic.weekDays.indexOf(_logic.selectedDay!));
    _loadData();
  }

  Future<void> _loadData() async {
    await _logic.loadSubjects();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      body: _buildContent(isDarkMode),
    );
  }

  Widget _buildContent(bool isDarkMode) {
    if (_logic.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_logic.subjects.isEmpty) {
      return BuildEmptyCard();
    }

    if (_logic.errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            _logic.errorMessage,
            style: const TextStyle(color: Colors.red, fontSize: 20),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final weekDates = _logic.getWeekDates();

    return Column(
      children: [
        SelectedDayRow(
          isDarkMode: isDarkMode,
          selectedDay: _logic.selectedDay!,
          weekDaysFullName: _logic.weekDaysFullName,
          weekDaysShort: _logic.weekDays, // Añade esta línea
          getMonthName: _logic.getMonthName,
        ),
        DayButtonRow(
          weekDays: _logic.weekDays,
          weekDates: weekDates,
          isDarkMode: isDarkMode,
          selectedDay: _logic.selectedDay!,
          getFilteredEvents: _logic.getFilteredEvents,
          subjects: _logic.subjects,
          onDaySelected: (day) {
            final index = _logic.weekDays.indexOf(day);
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
            );
          },
        ),
        const SizedBox(height: 8),
        const Divider(
          color: Colors.grey,
          thickness: 2,
        ),
        Expanded(
          child: EventListView(
            pageController: _pageController,
            weekDays: _logic.weekDays,
            getFilteredEvents: _logic.getFilteredEvents,
            subjects: _logic.subjects,
            groupEventsByDay: _logic.groupEventsByDay,
            getGroupLabel: _logic.getGroupLabel,
            onPageChanged: (index) {
              setState(() {
                _logic.updateSelectedDay(_logic.weekDays[index]);
              });
            },
          ),
        ),
      ],
    );
  }
}