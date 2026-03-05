import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/band_service.dart';

class BandChatScreen extends StatefulWidget {
  final String bandId;

  const BandChatScreen({super.key, required this.bandId});

  @override
  State<BandChatScreen> createState() => _BandChatScreenState();
}

class _BandChatScreenState extends State<BandChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSending = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<Map<String, String>> _loadMemberNames() async {
    final members = await BandService().getBandMembers(widget.bandId);
    final result = <String, String>{};

    for (final member in members) {
      final userId = member['user_id'] as String?;
      final user = member['users'] as Map<String, dynamic>?;
      final name = user?['name'] as String?;
      if (userId != null) {
        result[userId] = (name != null && name.trim().isNotEmpty) ? name : 'Member';
      }
    }

    return result;
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    final user = Supabase.instance.client.auth.currentUser;
    if (text.isEmpty || user == null || _isSending) return;

    setState(() => _isSending = true);

    try {
      await Supabase.instance.client.from('band_messages').insert({
        'band_id': widget.bandId,
        'user_id': user.id,
        'message': text,
      });

      _messageController.clear();
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, String>>(
      future: _loadMemberNames(),
      builder: (context, namesSnapshot) {
        if (namesSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final names = namesSnapshot.data ?? <String, String>{};
        return Column(
          children: [
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: Supabase.instance.client
                    .from('band_messages')
                    .stream(primaryKey: ['id'])
                    .eq('band_id', widget.bandId)
                    .map((rows) {
                  final mapped = List<Map<String, dynamic>>.from(rows);
                  mapped.sort((a, b) {
                    final aTime = DateTime.tryParse(a['created_at'] as String? ?? '');
                    final bTime = DateTime.tryParse(b['created_at'] as String? ?? '');
                    if (aTime == null && bTime == null) return 0;
                    if (aTime == null) return -1;
                    if (bTime == null) return 1;
                    return aTime.compareTo(bTime);
                  });
                  return mapped;
                }),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          'Chat is not configured yet. Please run the updated Supabase SQL setup to create band_messages.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  final messages = snapshot.data ?? [];
                  if (messages.isEmpty) {
                    return const Center(child: Text('No messages yet. Start the conversation.'));
                  }

                  final currentUserId = Supabase.instance.client.auth.currentUser?.id;

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(12),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final item = messages[index];
                      final userId = item['user_id'] as String? ?? '';
                      final isMe = userId == currentUserId;
                      final messageText = item['message'] as String? ?? '';
                      final timestamp = DateTime.tryParse(item['created_at'] as String? ?? '');
                      final senderName = isMe ? 'You' : (names[userId] ?? 'Member');

                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(10),
                          constraints: const BoxConstraints(maxWidth: 320),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.deepPurple[100] : Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                senderName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(messageText),
                              if (timestamp != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  _formatTime(timestamp.toLocal()),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        minLines: 1,
                        maxLines: 4,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _isSending ? null : _sendMessage,
                      icon: _isSending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.send),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatTime(DateTime value) {
    final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final minute = value.minute.toString().padLeft(2, '0');
    final suffix = value.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $suffix';
  }
}
