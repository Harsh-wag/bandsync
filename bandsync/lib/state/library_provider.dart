import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/song_model.dart';
import '../models/setlist_model.dart';

class LibraryProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  final List<Song> _songs = [];
  final List<Setlist> _setlists = [];

  List<Song> get songs => _songs;
  List<Setlist> get setlists => _setlists;

  LibraryProvider() {
    _loadSongs();
  }

  Future<void> _loadSongs() async {
    try {
      if (_supabase.auth.currentUser == null) return;
      final data = await _supabase.from('library_songs').select().eq('user_id', _supabase.auth.currentUser!.id);
      _songs.clear();
      _songs.addAll((data as List).map((e) => Song.fromMap(e)));
      notifyListeners();
    } catch (e) {
      // Error loading songs
    }
  }

  Future<void> addSong(Song song) async {
    await _supabase.from('library_songs').insert({
      'id': song.id,
      'user_id': _supabase.auth.currentUser!.id,
      'title': song.title,
      'artist': song.artist,
      'album': song.album,
      'lyrics': song.lyrics,
      'chords': song.chords,
      'key': song.key,
      'tempo': song.tempo,
      'file_path': song.filePath,
      'created_at': song.createdAt.toIso8601String(),
    });
    _songs.add(song);
    notifyListeners();
  }

  void updateSong(Song song) {
    final index = _songs.indexWhere((s) => s.id == song.id);
    if (index != -1) {
      _songs[index] = song;
      notifyListeners();
    }
  }

  void deleteSong(String id) {
    _songs.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  Song? getSongById(String id) {
    try {
      return _songs.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  void addSetlist(Setlist setlist) {
    _setlists.add(setlist);
    notifyListeners();
  }

  void updateSetlist(Setlist setlist) {
    final index = _setlists.indexWhere((s) => s.id == setlist.id);
    if (index != -1) {
      _setlists[index] = setlist;
      notifyListeners();
    }
  }

  void deleteSetlist(String id) {
    _setlists.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  List<Song> getSongsForSetlist(String setlistId) {
    final setlist = _setlists.firstWhere((s) => s.id == setlistId);
    return setlist.songIds.map((id) => getSongById(id)).whereType<Song>().toList();
  }
}
