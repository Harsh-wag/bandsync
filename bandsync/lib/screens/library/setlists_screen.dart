import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/library_provider.dart';
import '../../models/setlist_model.dart';

class SetlistsScreen extends StatelessWidget {
  const SetlistsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setlists'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<LibraryProvider>(
        builder: (context, library, child) {
          final setlists = library.setlists;
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
                        onTap: () {},
                      ),
                    );
                  },
                );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateSetlistDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreateSetlistDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Setlist'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Setlist Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Provider.of<LibraryProvider>(context, listen: false).addSetlist(
                  Setlist(
                    id: DateTime.now().toString(),
                    name: controller.text,
                    songIds: [],
                  ),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
