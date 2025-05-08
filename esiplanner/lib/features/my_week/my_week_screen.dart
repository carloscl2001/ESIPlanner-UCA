import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import 'my_week_logic.dart';
import 'my_week_widgets_mobile.dart';
import 'my_week_widgets_desktop.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late HomeLogic _logic;
  late PageController _pageController;
  int _currentPage = 0;
  bool _showGoogleView = false;
  bool _isDesktop = false; // Nueva variable de estado para almacenar si es desktop

  @override
  void initState() {
    super.initState();
    _logic = HomeLogic(context);
    _currentPage = _logic.weekDays.indexOf(_logic.selectedDay!);
    _pageController = PageController(initialPage: _currentPage);
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.delayed(const Duration(milliseconds: 1));
    await _logic.loadSubjects();
    if (mounted) {
      setState(() {});
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
      _logic.updateSelectedDay(_logic.weekDays[index]);
    });
  }

  void _toggleView() {
    setState(() {
      _showGoogleView = !_showGoogleView;
    });
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          _isDesktop = constraints.maxWidth > 1024; // Actualizamos el estado

          // Asegurarse de que el PageController está en la página correcta después de reconstruir
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_pageController.hasClients && _pageController.page?.round() != _currentPage) {
              _pageController.jumpToPage(_currentPage);
            }
          });

          if (_logic.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (_logic.subjects.isEmpty) {
            return _isDesktop 
              ? const BuildEmptyCardDesktop() 
              : const BuildEmptyCardMobile();
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

          return Column(
            children: [
              if (_isDesktop) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: SelectedDayRowDesktop(
                        isDarkMode: isDarkMode,
                        selectedDay: _logic.selectedDay!,
                        weekDaysFullName: _logic.weekDaysFullName,
                        weekDaysShort: _logic.weekDays,
                        getMonthName: _logic.getMonthName,
                      ),
                    ),
                    DayButtonRowDesktop(
                      weekDays: _logic.weekDays,
                      weekDates: _logic.getWeekDates(),
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
                  ],
                ),
                Expanded(
                  child: EventListViewDesktop(
                    pageController: _pageController,
                    weekDays: _logic.weekDays,
                    getFilteredEvents: _logic.getFilteredEvents,
                    subjects: _logic.subjects,
                    groupEventsByDay: _logic.groupEventsByDay,
                    getGroupLabel: _logic.getGroupLabel,
                    onPageChanged: _onPageChanged,
                  ),
                ),
              ] else ...[
                SelectedDayRowMobile(
                  isDarkMode: isDarkMode,
                  selectedDay: _logic.selectedDay!,
                  weekDaysFullName: _logic.weekDaysFullName,
                  weekDaysShort: _logic.weekDays,
                  getMonthName: _logic.getMonthName,
                ),
                DayButtonRowMobile(
                  weekDays: _logic.weekDays,
                  weekDates: _logic.getWeekDates(),
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
                Expanded(
                  child: _showGoogleView
                    ? EventListViewMobile(
                      pageController: _pageController,
                      weekDays: _logic.weekDays,
                      getFilteredEvents: _logic.getFilteredEvents,
                      subjects: _logic.subjects,
                      groupEventsByDay: _logic.groupEventsByDay,
                      getGroupLabel: _logic.getGroupLabel,
                      onPageChanged: _onPageChanged,
                    )
                    : EventListViewMobileGoogle(
                      pageController: _pageController,
                      weekDays: _logic.weekDays,
                      getFilteredEvents: _logic.getFilteredEvents,
                      subjects: _logic.subjects,
                      groupEventsByDay: _logic.groupEventsByDay,
                      getGroupLabel: _logic.getGroupLabel,
                      onPageChanged: _onPageChanged,
                    ),
                      
                ),
              ],
            ],
          );
        },
      ),
      floatingActionButton: !_isDesktop
        ? ViewToggleFab(
            isDarkMode: isDarkMode,
            showGoogleView: _showGoogleView,
            onPressed: _toggleView,
          )
        : null,
    );
  }
}