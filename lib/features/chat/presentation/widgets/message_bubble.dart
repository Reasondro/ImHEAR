import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:komunika/features/chat/domain/entities/message.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({required this.message, required this.isMe, super.key});

  final Message message;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final CrossAxisAlignment allignment =
        isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final Color bubbleColor =
        isMe ? theme.colorScheme.primary : theme.colorScheme.secondary;
    final Color textColor =
        isMe ? theme.colorScheme.onPrimary : theme.colorScheme.onSecondary;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Column(
        crossAxisAlignment: allignment,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 12.0,
            ),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(12),
                topRight: const Radius.circular(12),
                bottomLeft:
                    isMe ? const Radius.circular(12) : const Radius.circular(0),
                bottomRight:
                    isMe ? const Radius.circular(0) : const Radius.circular(12),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.content,
                  style: theme.textTheme.bodyMedium?.copyWith(color: textColor),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    DateFormat("HH:mm").format(message.createdAt.toLocal()),

                    // DateFormat.Hm().format((message.createdAt.toLocal())),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: textColor.withAlpha(204),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
