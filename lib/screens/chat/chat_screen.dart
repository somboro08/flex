import 'package:flutter/material.dart';
import '../../theme/flex_theme.dart';
import '../../models/models.dart';

class ChatScreen extends StatefulWidget {
  final Listing listing;
  final String initialMessage;
  const ChatScreen({super.key, required this.listing, this.initialMessage = ''});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialMessage.isNotEmpty) {
      _messages.add(_ChatMessage(
        text: widget.initialMessage, isMe: true, time: DateTime.now(),
      ));
    }
    _messages.addAll([
      _ChatMessage(text: 'Bonjour ! Oui, le logement est disponible.', isMe: false, time: DateTime.now().subtract(const Duration(seconds: 30))),
    ]);
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_ChatMessage(text: text, isMe: true, time: DateTime.now()));
      _messageController.clear();
    });
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() {
        _messages.add(_ChatMessage(
          text: 'Merci pour votre message ! Je vous réponds dans les plus brefs délais.',
          isMe: false, time: DateTime.now(),
        ));
      });
      _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    });
    _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
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
