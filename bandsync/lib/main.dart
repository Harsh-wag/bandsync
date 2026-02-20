import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/auth/login_screen.dart';
import 'screens/calendar/calendar_screen.dart';
import 'screens/calendar/add_event_screen.dart';
import 'screens/settings/bands_screen.dart';
import 'screens/library/library_lyrics_screen.dart';
import 'screens/library/import_song_screen.dart';
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LibraryProvider()),
        ChangeNotifierProvider(create: (context) => EventProvider()),
      ],
      child: MaterialApp(
        title: 'BandSync',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
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
              leading: const Icon(Icons.library_music),
              title: const Text('Import Song'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ImportSongScreen()),
                );
              },
            ),
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
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.calendar_month),
              onPressed: () => setState(() => _selectedIndex = 0),
              color: _selectedIndex == 0 ? Theme.of(context).colorScheme.primary : null,
            ),
            IconButton(
              icon: const Icon(Icons.group),
              onPressed: () => setState(() => _selectedIndex = 1),
              color: _selectedIndex == 1 ? Theme.of(context).colorScheme.primary : null,
            ),
            const SizedBox(width: 48),
            IconButton(
              icon: const Icon(Icons.library_music),
              onPressed: () => setState(() => _selectedIndex = 2),
              color: _selectedIndex == 2 ? Theme.of(context).colorScheme.primary : null,
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => setState(() => _selectedIndex = 3),
              color: _selectedIndex == 3 ? Theme.of(context).colorScheme.primary : null,
            ),
          ],
        ),
      ),
      floatingActionButton: _selectedIndex < 3
          ? FloatingActionButton(
              onPressed: _addEvent,
              child: const Icon(Icons.add),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
