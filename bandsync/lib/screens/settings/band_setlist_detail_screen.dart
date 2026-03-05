import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import '../../models/setlist_model.dart';
import '../../models/song_model.dart';
import '../../state/library_provider.dart';

class BandSetlistDetailScreen extends StatefulWidget {
  final Setlist setlist;
  final String bandId;

  const BandSetlistDetailScreen({super.key, required this.setlist, required this.bandId});

  @override
  State<BandSetlistDetailScreen> createState() => _BandSetlistDetailScreenState();
}

class _BandSetlistDetailScreenState extends State<BandSetlistDetailScreen> {
  final _supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.setlist.name),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddSongsDialog,
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _supabase.from('setlists').stream(primaryKey: ['id']).eq('id', widget.setlist.id),
        builder: (context, setlistSnapshot) {
          if (!setlistSnapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          final currentSetlist = Setlist.fromMap(setlistSnapshot.data!.first);
          
          return StreamBuilder<List<Map<String, dynamic>>>(
            stream: _supabase.from('songs').stream(primaryKey: ['id']).eq('band_id', widget.bandId),
            builder: (context, songsSnapshot) {
              if (!songsSnapshot.hasData) return const Center(child: CircularProgressIndicator());
              
              final allSongs = songsSnapshot.data!.map((e) => Song.fromMap(e)).toList();
              final songs = currentSetlist.songIds.map((id) => allSongs.firstWhere((s) => s.id == id, orElse: () => Song(id: id, title: 'Unknown', artist: '', lyrics: ''))).where((s) => s.title != 'Unknown').toList();
              
              return songs.isEmpty
                  ? const Center(child: Text('No songs in this setlist'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: songs.length,
                      itemBuilder: (context, index) {
                        final song = songs[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(child: Text('${index + 1}')),
                            title: Text(song.title),
                            subtitle: Text(song.artist),
                          ),
                        );
                      },
                    );
            },
          );
        },
      ),
    );
  }

  void _showAddSongsDialog() async {
    final bandSongs = await _supabase.from('songs').select().eq('band_id', widget.bandId);
    final librarySongs = Provider.of<LibraryProvider>(context, listen: false).songs;
    
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Songs'),
        content: DefaultTabController(
          length: 2,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const TabBar(
                tabs: [
                  Tab(text: 'Band Songs'),
                  Tab(text: 'From Library'),
                ],
              ),
              SizedBox(
                width: double.maxFinite,
                height: 300,
                child: TabBarView(
                  children: [
                    _buildBandSongsList(bandSongs),
                    _buildLibrarySongsList(librarySongs),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Widget _buildBandSongsList(List<dynamic> bandSongs) {
    final availableSongs = (bandSongs).map((e) => Song.fromMap(e)).where((s) => !widget.setlist.songIds.contains(s.id)).toList();
    
    return availableSongs.isEmpty
        ? const Center(child: Text('No more band songs'))
        : ListView.builder(
            itemCount: availableSongs.length,
            itemBuilder: (context, index) {
              final song = availableSongs[index];
              return ListTile(
                leading: CircleAvatar(child: Text(song.key)),
                title: Text(song.title),
                subtitle: Text(song.artist),
                onTap: () async {
                  final navigator = Navigator.of(context);
                  await _supabase.from('setlists').update({
                    'song_ids': [...widget.setlist.songIds, song.id],
                  }).eq('id', widget.setlist.id);
                  if (!mounted) return;
                  navigator.pop();
                },
              );
            },
          );
  }

  Widget _buildLibrarySongsList(List<Song> librarySongs) {
    return librarySongs.isEmpty
        ? const Center(child: Text('No songs in library'))
        : ListView.builder(
            itemCount: librarySongs.length,
            itemBuilder: (context, index) {
              final song = librarySongs[index];
              return ListTile(
                leading: CircleAvatar(child: Text(song.key)),
                title: Text(song.title),
                subtitle: Text(song.artist),
                onTap: () async {
                  final navigator = Navigator.of(context);
                  await _supabase.from('songs').insert({
                    'id': song.id,
                    'band_id': widget.bandId,
                    'title': song.title,
                    'artist': song.artist,
                    'album': song.album,
                    'lyrics': song.lyrics,
                    'chords': song.chords,
                    'key': song.key,
                    'tempo': song.tempo,
                    'file_path': song.filePath,
                    'created_at': song.createdAt.toIso8601String(),
                    'created_by': _supabase.auth.currentUser!.id,
                  });
                  await _supabase.from('setlists').update({
                    'song_ids': [...widget.setlist.songIds, song.id],
                  }).eq('id', widget.setlist.id);
                  if (!mounted) return;
                  navigator.pop();
                },
              );
            },
          );
  }
}
