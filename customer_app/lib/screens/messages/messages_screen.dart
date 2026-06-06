import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../models/message_model.dart';
import '../../services/firebase_service.dart';

/// Read-only message thread for a customer order.
/// Customers cannot send messages; they only receive admin notes.
class MessagesScreen extends StatefulWidget {
  final String orderId;
  const MessagesScreen({super.key, required this.orderId});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  @override
  void initState() {
    super.initState();
    // Mark admin messages as read when the thread is opened.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FirebaseService.instance.markMessagesRead(widget.orderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return StreamBuilder<List<MessageModel>>(
      stream: FirebaseService.instance.messagesStream(widget.orderId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final messages = snapshot.data ?? [];
        if (messages.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Text(t.messages,
                  style: const TextStyle(color: Colors.black45)),
            ),
          );
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(12),
          itemCount: messages.length,
          itemBuilder: (context, i) => _MessageBubble(message: messages[i]),
        );
      },
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageModel message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final fromAdmin = message.fromAdmin;
    final time = message.createdAt != null
        ? DateFormat('d MMM, HH:mm').format(message.createdAt!)
        : '';
    final highlight = fromAdmin && !message.isRead;

    return Align(
      alignment: fromAdmin ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: fromAdmin
              ? (highlight ? const Color(0xFFFFF3D6) : Colors.grey.shade200)
              : const Color(0xFFF1E7D2),
          borderRadius: BorderRadius.circular(14),
          border: highlight
              ? Border.all(color: const Color(0xFFC8860D))
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message.text),
            const SizedBox(height: 2),
            Text(time,
                style:
                    const TextStyle(fontSize: 10, color: Colors.black45)),
          ],
        ),
      ),
    );
  }
}
