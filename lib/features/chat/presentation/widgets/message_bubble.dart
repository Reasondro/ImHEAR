import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:komunika/app/themes/app_colors.dart';
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
        // isMe ? AppColors.lavender : theme.colorScheme.secondary;
        // isMe ? AppColors.lavender : AppColors.white;
        isMe ? AppColors.lavender.withAlpha(150) : Colors.grey.withAlpha(50);
    final Color textColor =
        // isMe ? AppColors.haiti : theme.colorScheme.onSecondary;
        // AppColors.haiti;
        isMe ? AppColors.haiti : Colors.black;
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
                topRight:
                    //  const Radius.circular(12),
                    isMe ? const Radius.circular(0) : const Radius.circular(12),
                bottomLeft:
                    isMe ? const Radius.circular(12) : const Radius.circular(0),
                bottomRight: const Radius.circular(12),
                // isMe ? const Radius.circular(0) : const Radius.circular(12),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // if (!isMe)
                //   Text(
                //     "Username",
                //     style: TextStyle(fontWeight: FontWeight.bold),
                //   ),
                Text(
                  message.content,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 15,
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
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
