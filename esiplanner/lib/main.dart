import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:google_fonts/google_fonts.dart';

// Providers
import 'package:provider/provider.dart';
import '/providers/auth_provider.dart';
import '/providers/theme_provider.dart';

// Navigation menu
import 'features/login/login_screen.dart';
import 'features/register/register_screen.dart';
import 'shared/navigation_menu_bar.dart';

// Screens
import 'non_features/profile_menu_screen.dart';


// Screens of features
import 'features/timetable/timetable_home/timetable_home_logic.dart';
import 'features/edit_password/edit_password_screen.dart';
import 'features/view_profile/view_profile_screen.dart';
import 'features/selection_subjects/select_subjects_home/select_subjects_home_screen.dart';
import 'features/view_subjects/view_subjects_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa los datos de localización para español (ajusta a tu idioma y región)
  await initializeDateFormatting('es_ES', null); // O el locale que desees

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => TimetableLogic(context)),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Cargar el tema guardado al iniciar la aplicación
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    themeProvider.loadTheme();

    // Cargar el estado de autenticación al iniciar la aplicación
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.loadAuthState();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // TEMA CLARO
      theme: ThemeData.light().copyWith(
        // Usar la fuente Inter para el tema claro
        textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue.shade900,
          brightness: Brightness.light,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
          labelStyle: GoogleFonts.inter(color: Colors.indigo), // Usar Inter
          hintStyle: GoogleFonts.inter(color: Colors.grey[400]), // Usar Inter
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.indigo, width: 1.5),
            borderRadius: BorderRadius.circular(12.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.indigo, width: 2.0),
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
            if (states.contains(WidgetState.selected)) {
              return GoogleFonts.inter( // Usar Inter
                color: Colors.blue.shade900,
                fontWeight: FontWeight.bold,
              );
            }
            return GoogleFonts.inter(color: Colors.grey); // Usar Inter
          }),
          indicatorColor: Colors.indigo.shade100,
          backgroundColor: Colors.white,
        ),
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Colors.indigo, width: 1.5),
          ),
          margin: const EdgeInsets.all(8),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: Colors.indigo.shade700,
            textStyle: GoogleFonts.inter( // Usar Inter
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue.shade900,
          titleTextStyle: GoogleFonts.inter( // Usar Inter
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
      ),

      // TEMA OSCURO
      darkTheme: ThemeData.dark().copyWith(
        // Usar la fuente Inter para el tema oscuro
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.yellow.shade700,
          brightness: Brightness.dark,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.black,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
          labelStyle: GoogleFonts.inter(color: Colors.white), // Usar Inter
          hintStyle: GoogleFonts.inter(color: Colors.white), // Usar Inter
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.yellow.shade700, width: 1.5),
            borderRadius: BorderRadius.circular(12.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.yellow.shade700, width: 2.5),
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
            if (states.contains(WidgetState.selected)) {
              return GoogleFonts.inter( // Usar Inter
                color: Colors.yellow.shade700,
                fontWeight: FontWeight.bold,
              );
            }
            return GoogleFonts.inter(color: Colors.grey); // Usar Inter
          }),
          indicatorColor: Colors.yellow.shade700,
          backgroundColor: Colors.black,
        ),
        cardTheme: CardTheme(
          color: Colors.black,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Colors.white, width: 1.5),
          ),
          margin: const EdgeInsets.all(8),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            backgroundColor: Colors.yellow.shade700,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: GoogleFonts.inter( // Usar Inter
              fontSize: 18,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black,
          titleTextStyle: GoogleFonts.inter( // Usar Inter
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
      ),
      themeMode: themeProvider.themeMode, // Usa el tema actual del ThemeProvider
      initialRoute: '/',
      routes: {
        '/': (context) => Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return authProvider.isAuthenticated
                    ? const NavigationMenuBar()
                    : const LoginScreen();
              },
            ),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const NavigationMenuBar(),
        '/profileMenu': (context) => const ProfileMenuScreen(),
        '/viewProfile': (context) => const ViewProfileScreen(),
        '/editPassWord': (context) => const EditPasswordScreen(),
        '/viewSubjects': (context) => const ViewSubjectsScreen(),
        '/selectionSubjects': (context) => const SubjectSelectionScreen(),
      },
    );
  }
}