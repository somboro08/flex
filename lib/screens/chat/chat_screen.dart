import 'package:flutter/material.dart';
import '../../theme/flex_theme.dart';
import '../../models/models.dart';
import '../../repositories/message_repository.dart';
import '../../services/chat_cache_service.dart';

class ChatScreen extends StatefulWidget {
  final Listing listing;
  final String recipientId;
  final String initialMessage;
  const ChatScreen({
    super.key,
    required this.listing,
    required this.recipientId,
    this.initialMessage = '',
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _msgRepo = MessageRepository();
  final List<_ChatMessage> _messages = [];
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final history = await _msgRepo.getConversation(widget.recipientId);
      if (!mounted) return;
      setState(() {
        _messages.clear();
        for (final m in history) {
          // senderId is the other user's ID → isMe = false
          final isMe = m['senderId'] != widget.recipientId;
          _messages.add(_ChatMessage(
            text: m['content'] ?? '',
            isMe: isMe,
            time: DateTime.tryParse(m['createdAt'] ?? '') ?? DateTime.now(),
          ));
        }
      });
      // If an initial message provided, send it now
      if (widget.initialMessage.isNotEmpty && _messages.isEmpty) {
        _messageController.text = widget.initialMessage;
        _sendMessage();
      } else if (_messages.isNotEmpty) {
        _saveToCache(_messages.last);
      }
    } catch (e) {
      debugPrint('Chat history error: $e');
    }
  }

  void _saveToCache(_ChatMessage msg) {
    ChatCacheService().saveConversation(ChatSummary(
      recipientId: widget.recipientId,
      listingId: widget.listing.id,
      listingTitre: widget.listing.titre,
      listingVille: widget.listing.ville,
      listingQuartier: widget.listing.quartier,
      lastMessage: msg.text,
      lastTime: msg.time,
    ));
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() {
      _isSending = true;
      _messages.add(_ChatMessage(text: text, isMe: true, time: DateTime.now()));
      _messageController.clear();
    });
    _scrollToBottom();

    try {
      await _msgRepo.sendMessage(
        recipientId: widget.recipientId,
        content: text,
        listingId: widget.listing.id,
      );
      _saveToCache(_messages.last);
    } catch (e) {
      debugPrint('Send error: $e');
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: FlexColors.primary100,
              child: Text(widget.listing.titre[0], style: TextStyle(color: FlexColors.primary500, fontSize: 14)),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hôte · ${widget.listing.titre}', style: FlexTextStyles.caption.copyWith(fontWeight: FontWeight.w600)),
                Text('En ligne', style: FlexTextStyles.caption.copyWith(color: FlexColors.success, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(FlexSpacing.md),
              itemCount: _messages.length,
              itemBuilder: (_, i) {
                final msg = _messages[i];
                return _MessageBubble(message: msg, isDark: isDark);
              },
            ),
          ),
          _buildInputBar(isDark),
        ],
      ),
    );
  }

  Widget _buildInputBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(FlexSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? FlexColors.neutral800 : Colors.white,
        border: Border(top: BorderSide(color: isDark ? FlexColors.neutral700 : FlexColors.neutral200)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isDark ? FlexColors.neutral700 : FlexColors.neutral100,
                  borderRadius: BorderRadius.circular(FlexRadius.full),
                ),
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    hintText: 'Écrivez un message...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                width: 44, height: 44,
                decoration: const BoxDecoration(
                  color: FlexColors.primary500, shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class _ChatMessage {
  final String text; final bool isMe; final DateTime time;
  _ChatMessage({required this.text, required this.isMe, required this.time});
}

class _MessageBubble extends StatelessWidget {
  final _ChatMessage message; final bool isDark;
  const _MessageBubble({required this.message, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isMe) ...[
            CircleAvatar(
              radius: 12,
              backgroundColor: FlexColors.primary100,
              child: Text('H', style: TextStyle(color: FlexColors.primary500, fontSize: 10)),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: message.isMe ? FlexColors.primary500 : (isDark ? FlexColors.neutral700 : Colors.white),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(FlexRadius.lg),
                  topRight: const Radius.circular(FlexRadius.lg),
                  bottomLeft: message.isMe ? const Radius.circular(FlexRadius.lg) : Radius.zero,
                  bottomRight: message.isMe ? Radius.zero : const Radius.circular(FlexRadius.lg),
                ),
                border: message.isMe ? null : Border.all(color: isDark ? FlexColors.neutral600 : FlexColors.neutral200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(message.text, style: TextStyle(
                    color: message.isMe ? Colors.white : (isDark ? FlexColors.neutral0 : FlexColors.neutral700),
                    fontSize: 14,
                  )),
                  const SizedBox(height: 4),
                  Text('${message.time.hour}:${message.time.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(fontSize: 10, color: message.isMe ? Colors.white60 : FlexColors.neutral400)),
                ],
              ),
            ),
          ),
          if (message.isMe) const SizedBox(width: 8),
        ],
      ),
    );
  }
}
