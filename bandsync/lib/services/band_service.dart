import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/band_model.dart';
import 'dart:math';

class BandService {
  final SupabaseClient _supabase = Supabase.instance.client;

  String get _userId => _supabase.auth.currentUser!.id;

  // Generate random invite code
  String _generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(6, (index) => chars[random.nextInt(chars.length)]).join();
  }

  // Get user's bands
  Stream<List<Band>> getUserBands() {
    return _supabase
        .from('band_members')
        .stream(primaryKey: ['id'])
        .eq('user_id', _userId)
        .asyncMap((members) async {
      if (members.isEmpty) return [];
      
      final bandIds = members.map((m) => m['band_id']).toList();
      final bands = await _supabase
          .from('bands')
          .select()
          .filter('id', 'in', '(${bandIds.join(',')})');
      
      return (bands as List).map((b) => Band.fromMap(b)).toList();
    });
  }

  // Create new band
  Future<Band> createBand(String name) async {
    final inviteCode = _generateInviteCode();
    
    final response = await _supabase.from('bands').insert({
      'name': name,
      'invite_code': inviteCode,
      'created_by': _userId,
    }).select().single();
    
    final band = Band.fromMap(response);
    
    // Add creator as member
    await _supabase.from('band_members').insert({
      'band_id': band.id,
      'user_id': _userId,
      'role': 'admin',
    });
    
    return band;
  }

  // Join band with invite code
  Future<Band> joinBand(String inviteCode) async {
    final response = await _supabase
        .from('bands')
        .select()
        .eq('invite_code', inviteCode.toUpperCase())
        .maybeSingle();
    
    if (response == null) {
      throw Exception('Invalid invite code');
    }
    
    final band = Band.fromMap(response);
    
    // Check if already a member
    final existing = await _supabase
        .from('band_members')
        .select()
        .eq('band_id', band.id)
        .eq('user_id', _userId)
        .maybeSingle();
    
    if (existing == null) {
      await _supabase.from('band_members').insert({
        'band_id': band.id,
        'user_id': _userId,
        'role': 'member',
      });
    }
    
    return band;
  }

  // Leave band
  Future<void> leaveBand(String bandId) async {
    await _supabase
        .from('band_members')
        .delete()
        .eq('band_id', bandId)
        .eq('user_id', _userId);
  }

  // Get band members
  Future<List<Map<String, dynamic>>> getBandMembers(String bandId) async {
    final members = await _supabase
        .from('band_members')
        .select('id, role, user_id, users!inner(name, email)')
        .eq('band_id', bandId);
    
    return List<Map<String, dynamic>>.from(members);
  }
}
