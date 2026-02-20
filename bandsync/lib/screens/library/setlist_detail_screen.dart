import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/library_provider.dart';
import '../../models/setlist_model.dart';
import '../../models/song_model.dart';
import 'song_viewer_screen.dart';

class SetlistDetailScreen extends StatelessWidget {
  final Setlist setlist;

  const SetlistDetailScreen({super.key, required this.setlist});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(setlist.name),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddSongsDialog(context),
          ),
        ],
      ),
      body: Consumer<LibraryProvider>(
        builder: (context, library, child) {
          final songs = setlist.songIds.isEmpty
              ? <Song>[]
              : library.getSongsForSetlist(setlist.id);
          return songs.isEmpty
              ? const Center(child: Text('No songs in this setlist'))
              : ReorderableListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: songs.length,
                  onReorder: (oldIndex, newIndex) {
                    if (newIndex > oldIndex) newIndex--;
                    final songIds = List<String>.from(setlist.songIds);
                    final item = songIds.removeAt(oldIndex);
                    songIds.insert(newIndex, item);
                    library.updateSetlist(Setlist(
                      id: setlist.id,
                      name: setlist.name,
                      songIds: songIds,
                      createdAt: setlist.createdAt,
                    ));
                  },
                  itemBuilder: (context, index) {
                    final song = songs[index];
                    return Card(
                      key: ValueKey(song.id),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(child: Text('${index + 1}')),
                        title: Text(song.title),
                        subtitle: Text(song.artist),
                        trailing: const Icon(Icons.drag_handle),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SongViewerScreen(
                                song: song,
                                setlistSongs: songs,
                                currentIndex: index,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
        },
      ),
    );
  }

  void _showAddSongsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _AddSongsDialog(setlist: setlist),
    );
  }
}

class _AddSongsDialog extends StatefulWidget {
  final Setlist setlist;

  const _AddSongsDialog({required this.setlist});

  @override
  State<_AddSongsDialog> createState() => _AddSongsDialogState();
}

class _AddSongsDialogState extends State<_AddSongsDialog> {
  @override
  Widget build(BuildContext context) {
    return Consumer<LibraryProvider>(
      builder: (context, library, child) {
        final currentSetlist = library.setlists.isEmpty
            ? widget.setlist
            : library.setlists.firstWhere(
                (s) => s.id == widget.setlist.id,
                orElse: () => widget.setlist,
              );
        final availableSongs = library.songs
            .where((song) => !currentSetlist.songIds.contains(song.id))
            .toList();

        return AlertDialog(
          title: const Text('Add Songs'),
          content: SizedBox(
            width: double.maxFinite,
            child: availableSongs.isEmpty
                ? const Text('No more songs to add')
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: availableSongs.length,
                    itemBuilder: (context, index) {
                      final song = availableSongs[index];
                      return ListTile(
                        leading: CircleAvatar(child: Text(song.key)),
                        title: Text(song.title),
                        subtitle: Text(song.artist),
                        onTap: () {
                          library.updateSetlist(Setlist(
                            id: currentSetlist.id,
                            name: currentSetlist.name,
                            songIds: [...currentSetlist.songIds, song.id],
                            createdAt: currentSetlist.createdAt,
                          ));
                        },
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }
}
