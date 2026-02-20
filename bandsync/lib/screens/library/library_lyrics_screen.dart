import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/library_provider.dart';
import 'song_viewer_screen.dart';
import 'setlist_detail_screen.dart';
import 'chord_sheet_editor_screen.dart';

class LibraryLyricsScreen extends StatefulWidget {
  const LibraryLyricsScreen({super.key});

  @override
  State<LibraryLyricsScreen> createState() => _LibraryLyricsScreenState();
}

class _LibraryLyricsScreenState extends State<LibraryLyricsScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Library'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          automaticallyImplyLeading: false,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(100),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search by title, artist, or lyrics...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () => setState(() => _searchQuery = ''),
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),
                ),
                const TabBar(
                  tabs: [
                    Tab(icon: Icon(Icons.library_music), text: 'Songs'),
                    Tab(icon: Icon(Icons.queue_music), text: 'Setlists'),
                  ],
                ),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            SongsTab(searchQuery: _searchQuery),
            const SetlistsTab(),
          ],
        ),
      ),
    );
  }
}

class SongsTab extends StatelessWidget {
  final String searchQuery;

  const SongsTab({super.key, required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    return Consumer<LibraryProvider>(
      builder: (context, provider, child) {
        var songs = provider.songs;
        
        if (searchQuery.isNotEmpty) {
          final query = searchQuery.toLowerCase();
          songs = songs.where((song) {
            return song.title.toLowerCase().contains(query) ||
                   song.artist.toLowerCase().contains(query) ||
                   song.lyrics.toLowerCase().contains(query) ||
                   song.key.toLowerCase().contains(query);
          }).toList();
        }
        
        return songs.isEmpty
            ? Center(
                child: Text(searchQuery.isEmpty 
                    ? 'No songs in library' 
                    : 'No songs found for "$searchQuery"'),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: songs.length,
                itemBuilder: (context, index) {
                  final song = songs[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(song.key),
                      ),
                      title: Text(song.title),
                      subtitle: Text(song.artist),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChordSheetEditorScreen(song: song),
                                ),
                              );
                            },
                          ),
                          const Icon(Icons.arrow_forward_ios),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SongViewerScreen(song: song),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
      },
    );
  }
}

class SetlistsTab extends StatelessWidget {
  const SetlistsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LibraryProvider>(
      builder: (context, provider, child) {
        final setlists = provider.setlists;
        return setlists.isEmpty
            ? const Center(child: Text('No setlists created'))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: setlists.length,
                itemBuilder: (context, index) {
                  final setlist = setlists[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.queue_music)),
                      title: Text(setlist.name),
                      subtitle: Text('${setlist.songIds.length} songs'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SetlistDetailScreen(setlist: setlist),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
      },
    );
  }
}
