import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/band_model.dart';
import '../../models/setlist_model.dart';
import '../../services/band_service.dart';
import '../../state/library_provider.dart';
import '../library/import_song_screen.dart';
import '../library/chord_sheet_editor_screen.dart';
import '../library/lyrics_screen.dart';
import '../library/setlist_detail_screen.dart';

class BandDetailScreen extends StatelessWidget {
  final Band band;

  const BandDetailScreen({super.key, required this.band});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(band.name),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Members'),
              Tab(text: 'Setlists'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _MembersTab(bandId: band.id),
            _SetlistsTab(bandId: band.id),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddOptions(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.library_add),
            title: const Text('Add from Library'),
            onTap: () {
              Navigator.pop(context);
              _showLibrarySongsDialog(context);
            },
          ),
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
              _showCreateSetlistDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _showLibrarySongsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Consumer<LibraryProvider>(
        builder: (context, library, child) {
          final songs = library.songs;
          return AlertDialog(
            title: const Text('Add from Library'),
            content: SizedBox(
              width: double.maxFinite,
              child: songs.isEmpty
                  ? const Text('No songs in library')
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: songs.length,
                      itemBuilder: (context, index) {
                        final song = songs[index];
                        return ListTile(
                          leading: CircleAvatar(child: Text(song.key)),
                          title: Text(song.title),
                          subtitle: Text(song.artist),
                          onTap: () async {
                            try {
                              await Supabase.instance.client.from('songs').insert({
                                'id': song.id,
                                'band_id': band.id,
                                'title': song.title,
                                'artist': song.artist,
                                'album': song.album,
                                'lyrics': song.lyrics,
                                'chords': song.chords,
                                'key': song.key,
                                'tempo': song.tempo,
                                'file_path': song.filePath,
                                'created_at': song.createdAt,
                                'created_by': Supabase.instance.client.auth.currentUser!.id,
                              });
                              if (!context.mounted) return;
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('${song.title} added to band')),
                              );
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          },
                        );
                      },
                    ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showCreateSetlistDialog(BuildContext context) {
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
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                try {
                  await Supabase.instance.client.from('setlists').insert({
                    'id': DateTime.now().millisecondsSinceEpoch.toString(),
                    'band_id': band.id,
                    'name': controller.text,
                    'song_ids': [],
                    'created_at': DateTime.now().toIso8601String(),
                    'created_by': Supabase.instance.client.auth.currentUser!.id,
                  });
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Setlist "${controller.text}" created')),
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}

class _MembersTab extends StatelessWidget {
  final String bandId;

  const _MembersTab({required this.bandId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: BandService().getBandMembers(bandId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final members = snapshot.data ?? [];

        if (members.isEmpty) {
          return const Center(child: Text('No members'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: members.length,
          itemBuilder: (context, index) {
            final member = members[index];
            final user = member['users'] as Map<String, dynamic>?;
            if (user == null) return const SizedBox.shrink();
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  child: Text((user['name'] as String? ?? 'U')[0].toUpperCase()),
                ),
                title: Text(user['name'] as String? ?? 'Unknown'),
                subtitle: Text(user['email'] as String? ?? ''),
                trailing: Chip(
                  label: Text(member['role'] as String? ?? 'member'),
                  backgroundColor: (member['role'] as String?) == 'admin'
                      ? Colors.deepPurple[100]
                      : Colors.grey[200],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _SetlistsTab extends StatelessWidget {
  final String bandId;

  const _SetlistsTab({required this.bandId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: Supabase.instance.client
          .from('setlists')
          .stream(primaryKey: ['id'])
          .eq('band_id', bandId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final setlists = snapshot.data ?? [];

        if (setlists.isEmpty) {
          return const Center(child: Text('No setlists yet'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: setlists.length,
          itemBuilder: (context, index) {
            final setlist = Setlist.fromMap(setlists[index]);
            return Card(
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.playlist_play),
                ),
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
