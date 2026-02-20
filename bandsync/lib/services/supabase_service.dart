import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/song_model.dart';
import '../models/setlist_model.dart';

class SupabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  String get _userId => _supabase.auth.currentUser!.id;

  // Songs
  Stream<List<Song>> getSongs() {
    return _supabase
        .from('songs')
        .stream(primaryKey: ['id'])
        .eq('user_id', _userId)
        .order('created_at', ascending: false)
        .map((data) => data.map((json) => Song.fromMap(json)).toList());
  }

  Future<void> addSong(Song song) async {
    await _supabase.from('songs').insert({
      'id': song.id,
      'user_id': _userId,
      ...song.toMap(),
    });
  }

  Future<void> updateSong(Song song) async {
    await _supabase.from('songs').update(song.toMap()).eq('id', song.id);
  }

  Future<void> deleteSong(String songId) async {
    await _supabase.from('songs').delete().eq('id', songId);
  }

  // Setlists
  Stream<List<Setlist>> getSetlists() {
    return _supabase
        .from('setlists')
        .stream(primaryKey: ['id'])
        .eq('user_id', _userId)
        .order('created_at', ascending: false)
        .map((data) => data.map((json) => Setlist.fromMap(json)).toList());
  }

  Future<void> addSetlist(Setlist setlist) async {
    await _supabase.from('setlists').insert({
      'id': setlist.id,
      'user_id': _userId,
      ...setlist.toMap(),
    });
  }

  Future<void> updateSetlist(Setlist setlist) async {
    await _supabase.from('setlists').update(setlist.toMap()).eq('id', setlist.id);
  }

  Future<void> deleteSetlist(String setlistId) async {
    await _supabase.from('setlists').delete().eq('id', setlistId);
  }
}
