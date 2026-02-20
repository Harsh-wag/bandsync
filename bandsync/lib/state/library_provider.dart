import 'package:flutter/material.dart';
import '../models/song_model.dart';
import '../models/setlist_model.dart';

class LibraryProvider extends ChangeNotifier {
  final List<Song> _songs = [];
  final List<Setlist> _setlists = [];

  List<Song> get songs => _songs;
  List<Setlist> get setlists => _setlists;

  void addSong(Song song) {
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
