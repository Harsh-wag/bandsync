import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/auth/login_screen.dart';
import 'screens/calendar/calendar_screen.dart';
import 'screens/calendar/add_event_screen.dart';
import 'screens/settings/bands_screen.dart';
import 'screens/library/library_lyrics_screen.dart';
import 'screens/library/lyrics_screen.dart';
import 'screens/library/chord_sheet_editor_screen.dart';
import 'screens/library/audio_analysis_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'state/library_provider.dart';
import 'state/event_provider.dart';
import 'models/setlist_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://ovbljevlgnarhlcebubv.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im92YmxqZXZsZ25hcmhsY2VidWJ2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzEzMzc5NjUsImV4cCI6MjA4NjkxMzk2NX0.8wbFUwylJ-JMi3nJfbkB3unTBVKwaJxXchvBuVBBhYw',
  );
  
  runApp(const BandSyncApp());
}

class BandSyncApp extends StatelessWidget {
  const BandSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = const ColorScheme.dark(
      primary: Color(0xFF00E5FF),
      onPrimary: Color(0xFF00151A),
      primaryContainer: Color(0xFF00333D),
      onPrimaryContainer: Color(0xFF9FF6FF),
      secondary: Color(0xFFFF2A6D),
      onSecondary: Color(0xFF2B0011),
      secondaryContainer: Color(0xFF5A1330),
      onSecondaryContainer: Color(0xFFFFD9E6),
      tertiary: Color(0xFFB8FF00),
      onTertiary: Color(0xFF1E2B00),
      surface: Color(0xFF121826),
      onSurface: Color(0xFFE6ECFF),
      surfaceContainerLowest: Color(0xFF090D17),
      surfaceContainer: Color(0xFF1A2233),
      surfaceContainerHighest: Color(0xFF242F44),
      outline: Color(0xFF4C5A77),
      outlineVariant: Color(0xFF2C3850),
      error: Color(0xFFFF5C7A),
      onError: Color(0xFF33010D),
      errorContainer: Color(0xFF5A1321),
      onErrorContainer: Color(0xFFFFD9E0),
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LibraryProvider()),
        ChangeNotifierProvider(create: (context) => EventProvider()),
      ],
      child: MaterialApp(
        title: 'BandSync',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: colorScheme,
          scaffoldBackgroundColor: const Color(0xFF090D17),
          textTheme: const TextTheme(
            headlineMedium: TextStyle(fontSize: 30, fontWeight: FontWeight.w700, letterSpacing: -0.4),
            titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.2),
            titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            bodyLarge: TextStyle(fontSize: 16, height: 1.4),
            bodyMedium: TextStyle(fontSize: 14, height: 1.4),
            labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          appBarTheme: AppBarTheme(
            elevation: 0,
            centerTitle: false,
            surfaceTintColor: Colors.transparent,
            backgroundColor: const Color(0xFF121826),
            foregroundColor: colorScheme.onSurface,
            titleTextStyle: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          cardTheme: CardThemeData(
            elevation: 1,
            shadowColor: Colors.black.withValues(alpha: 0.35),
            surfaceTintColor: Colors.transparent,
            color: colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.45)),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.primary, width: 1.8),
            ),
            hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            ),
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          snackBarTheme: SnackBarThemeData(
            behavior: SnackBarBehavior.floating,
            backgroundColor: colorScheme.inverseSurface,
            contentTextStyle: TextStyle(color: colorScheme.onInverseSurface),
          ),
          navigationBarTheme: NavigationBarThemeData(
            elevation: 2,
            backgroundColor: const Color(0xFF121826),
            indicatorColor: colorScheme.primaryContainer,
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w600);
              }
              return TextStyle(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500);
            }),
          ),
          dialogTheme: DialogThemeData(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          bottomSheetTheme: BottomSheetThemeData(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            ),
            backgroundColor: colorScheme.surface,
            surfaceTintColor: Colors.transparent,
          ),
          useMaterial3: true,
        ),
        home: const LoginScreen(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const CalendarScreen(),
    const BandsScreen(),
    const LibraryLyricsScreen(),
    const SettingsScreen(),
  ];

  void _showCreateSetlistDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Setlist'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Setlist Name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                final setlist = Setlist(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: controller.text,
                  songIds: [],
                );
                Provider.of<LibraryProvider>(context, listen: false)
                    .addSetlist(setlist);
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _addEvent() {
    if (_selectedIndex == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AddEventScreen()),
      );
    } else if (_selectedIndex == 2) {
      showModalBottomSheet(
        context: context,
        builder: (context) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.graphic_eq),
              title: const Text('AI Audio Analysis'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AudioAnalysisScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.music_note),
              title: const Text('Create Chord Sheet'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChordSheetEditorScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.lyrics),
              title: const Text('Upload Lyrics'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UploadLyricsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.playlist_add),
              title: const Text('Create Setlist'),
              onTap: () {
                Navigator.pop(context);
                _showCreateSetlistDialog();
              },
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: KeyedSubtree(
          key: ValueKey(_selectedIndex),
          child: _pages[_selectedIndex],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (value) => setState(() => _selectedIndex = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month), label: 'Calendar'),
          NavigationDestination(icon: Icon(Icons.group_outlined), selectedIcon: Icon(Icons.group), label: 'Bands'),
          NavigationDestination(icon: Icon(Icons.library_music_outlined), selectedIcon: Icon(Icons.library_music), label: 'Library'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
      floatingActionButton: _selectedIndex < 3
          ? FloatingActionButton(
              onPressed: _addEvent,
              child: const Icon(Icons.add),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
