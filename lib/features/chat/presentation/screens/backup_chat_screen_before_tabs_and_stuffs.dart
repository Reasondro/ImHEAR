import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:komunika/app/themes/app_colors.dart';
import 'package:komunika/core/extensions/snackbar_extension.dart';
import 'package:komunika/core/services/custom_bluetooth_service.dart';
import 'package:komunika/features/chat/domain/entities/message.dart';
import 'package:komunika/features/chat/domain/repositories/chat_repository.dart';
import 'package:komunika/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:komunika/features/chat/presentation/widgets/message_bubble.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    required this.roomId,
    required this.subSpaceName,
    this.officialName,
    super.key,
  });

  final int roomId;
  final String subSpaceName;
  final String? officialName;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  // int _lastMessageCount = 0; //? only use for debugging
  bool _showMicIcon = true;

  // ? state for tabs
  int _selectedTabIndex = 0; //? 0 --> Space Chat, 1 -->  Notifications
  final List<String> _tabTitles = ['Space Chat', 'Notifications'];
  //? placeholder for notification count, ideally from a Cubit/service
  final ValueNotifier<int> _notificationCount = ValueNotifier(5);

  // ?state for quick messages
  bool _isQuickMessagePanelVisible = false;
  final List<String> _quickMessages = [
    "Where can I pay the fare?",
    "How much is the fare?",
    "I want to stop at the next station",
    "Thank you for the help!",
    "Is this the right way to...?",
  ];

  @override
  void initState() {
    super.initState();
    _textController.addListener(() {
      if (mounted) {
        setState(() {
          _showMicIcon = _textController.text.trim().isEmpty;
        });
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _notificationCount.dispose();
    super.dispose();
  }

  void _sendMessage(BuildContext descendantContext) {
    final String text = _textController.text.trim();

    if (text.isNotEmpty) {
      // ? use the descendantContext to find the ChatCubit
      descendantContext.read<ChatCubit>().sendMessage(text);
      _textController.clear();
      // // ? use the descendantContext for FocusScope as well
      // FocusScope.of(descendantContext).unfocus();
    }
  }

  // --- Widget for the tab buttons ---
  Widget _buildTabSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        children:
            List.generate(_tabTitles.length, (index) {
                  bool isSelected = _selectedTabIndex == index;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedTabIndex = index;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? AppColors.bittersweet
                                  : AppColors.deluge.withAlpha(180),
                          borderRadius: BorderRadius.circular(
                            10,
                          ), // Figma-like rounding
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _tabTitles[index],
                              style: TextStyle(
                                color: AppColors.white,
                                fontWeight:
                                    isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                fontSize: 14,
                              ),
                            ),
                            if (index == 1) // If it's the Notifications tab
                              ValueListenableBuilder<int>(
                                valueListenable: _notificationCount,
                                builder: (context, count, child) {
                                  if (count > 0) {
                                    return Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: CircleAvatar(
                                        radius: 11,
                                        backgroundColor: AppColors.white,
                                        child: CircleAvatar(
                                          radius: 9,
                                          backgroundColor:
                                              isSelected
                                                  ? AppColors.white
                                                  : AppColors.paleCarmine,
                                          child: Text(
                                            count.toString(),
                                            style: TextStyle(
                                              color:
                                                  isSelected
                                                      ? AppColors.bittersweet
                                                      : AppColors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                })
                .expand(
                  (widget) => [
                    widget,
                    if (widget !=
                        (List.generate(
                          _tabTitles.length,
                          (index) => widget,
                        )).last)
                      const SizedBox(width: 10),
                  ],
                )
                .toList(),
      ),
    );
  }

  // --- Widget for the main chat area (messages + input) ---
  Widget _buildSpaceChatWidget(BuildContext context) {
    // Pass context if descendantContext is needed
    return Column(
      children: [
        Expanded(
          child: BlocBuilder<ChatCubit, ChatState>(
            builder: (blocBuilderContext, state) {
              // Use a different context name
              final String? currentUserId =
                  Supabase.instance.client.auth.currentUser?.id;
              // ... (your existing BlocBuilder logic for message list) ...
              if (state is ChatLoading || state is ChatInitial) {
                /* ... */
              } else if (state is ChatError) {
                /* ... */
              } else if (state is ChatLoaded) {
                if (state.messages.isEmpty) {
                  /* ... */
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(
                    top: 8.0,
                    bottom: 8.0,
                    left: 8.0,
                    right: 8.0,
                  ), // Add padding
                  reverse: true,
                  itemCount: state.messages.length,
                  itemBuilder: (itemContext, index) {
                    // Different context name
                    final Message message = state.messages[index];
                    final bool isMe = message.senderId == currentUserId;
                    return MessageBubble(message: message, isMe: isMe);
                  },
                );
              }
              return const Center(child: Text("Something went wrong"));
            },
          ),
        ),
        // --- Quick Message Panel ---
        if (_isQuickMessagePanelVisible)
          Container(
            height: 180, // Adjust as needed
            color: AppColors.deluge.withAlpha(230),
            child: ListView.builder(
              itemCount: _quickMessages.length,
              itemBuilder: (context, index) {
                return Material(
                  // For InkWell ripple effect
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      _textController.text = _quickMessages[index];
                      _textController.selection = TextSelection.fromPosition(
                        TextPosition(offset: _textController.text.length),
                      );
                      setState(() {
                        _isQuickMessagePanelVisible = false;
                        _showMicIcon = false; // Text field now has content
                      });
                      FocusScope.of(
                        context,
                      ).requestFocus(); // Keep focus on text field
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                      child: Text(
                        _quickMessages[index],
                        style: const TextStyle(color: AppColors.white),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

        // --- Message Input Row (modified for Quick Message Toggle) ---
        // This Builder is to ensure the _sendMessage receives the correct context
        // that is a descendant of the ChatCubit's BlocProvider.
        Builder(
          builder: (BuildContext descendantContextForInput) {
            return Container(
              margin: EdgeInsets.only(
                left: 8.0,
                right: 8.0,
                top: 4.0,
                bottom:
                    MediaQuery.of(descendantContextForInput).viewInsets.bottom >
                            0
                        ? 8.0
                        : 8.0, // Consistent bottom padding
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 4.0,
              ),
              decoration: BoxDecoration(
                color: AppColors.lavender.withAlpha(
                  204,
                ), // Background for the whole input area
                borderRadius: BorderRadius.circular(25.0),
              ),
              child: Row(
                children: [
                  // Quick Message Toggle Button
                  IconButton(
                    icon: Icon(
                      _isQuickMessagePanelVisible
                          ? Icons.keyboard_arrow_down
                          : Icons.dashboard_customize_outlined, // Change icon
                      color: AppColors.haiti,
                    ),
                    tooltip: "Quick Messages",
                    onPressed: () {
                      setState(() {
                        _isQuickMessagePanelVisible =
                            !_isQuickMessagePanelVisible;
                        if (_isQuickMessagePanelVisible) {
                          FocusScope.of(
                            context,
                          ).unfocus(); // Hide keyboard if opening quick messages
                        }
                      });
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      maxLines: 6,
                      minLines: 1,
                      textCapitalization: TextCapitalization.sentences,
                      autocorrect: true,
                      enableSuggestions: true,
                      decoration: InputDecoration(
                        filled: false, // No separate fill needed now
                        hintText: "Type your message...",
                        hintStyle: TextStyle(
                          color: AppColors.haiti.withAlpha(179),
                        ),
                        border:
                            InputBorder
                                .none, // Remove border inside the outer container
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 10,
                        ),
                      ),
                      onChanged: (text) {
                        // Already handled by _textController.addListener
                        // setState(() { _showMicIcon = text.trim().isEmpty; });
                      },
                      onSubmitted:
                          (_) => _sendMessage(descendantContextForInput),
                    ),
                  ),
                  //const SizedBox(width: 8.0), // Already spaced by padding
                  Container(
                    decoration: BoxDecoration(
                      color: _showMicIcon ? AppColors.deluge : AppColors.haiti,
                      borderRadius: BorderRadius.circular(36),
                    ),
                    child: IconButton(
                      onPressed:
                          _showMicIcon
                              ? () {
                                /* TODO: Mic action */
                                print("Mic pressed");
                              }
                              : () => _sendMessage(descendantContextForInput),
                      icon: Icon(
                        _showMicIcon ? Icons.mic_rounded : Icons.send,
                        color: AppColors.white,
                      ),
                      tooltip: _showMicIcon ? "Voice message" : "Send Message",
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // --- Widget for the Notifications list ---
  Widget _buildNotificationsWidget() {
    // Replace with actual notification data and BlocBuilder if needed
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Example data from Figma, style with AppColors
        _buildNotificationItem(
          context,
          Icons.directions_bus,
          "Arriving at Lebak Bulus Station",
          "2 minutes ago",
          AppColors.deluge,
        ),
        _buildNotificationItem(
          context,
          Icons.directions_bus,
          "Arriving at Fatmawati Station",
          "15 minutes ago",
          AppColors.deluge,
        ),
        _buildNotificationItem(
          context,
          Icons.traffic,
          "Congestion on Fatmawati",
          "17 minutes ago",
          AppColors.paleCarmine,
        ),
        _buildNotificationItem(
          context,
          Icons.directions_bus,
          "Arriving at Senayan Station",
          "33 minutes ago",
          AppColors.deluge,
        ),
        _buildNotificationItem(
          context,
          Icons.warning_amber_rounded,
          "Earthquake",
          "35 minutes ago",
          AppColors.rawSienna,
        ), // Assuming rawSienna for earthquake
        _buildNotificationItem(
          context,
          Icons.directions_bus,
          "Arriving at Kuningan Station",
          "55 minutes ago",
          AppColors.deluge,
        ),
        _buildNotificationItem(
          context,
          Icons.directions_bus,
          "Arriving at Gambir Station",
          "1 Hour 2 minutes ago",
          AppColors.deluge,
        ),
        const SizedBox(height: 20),
        Center(
          child: Text(
            "End of Notifications",
            style: TextStyle(color: AppColors.lavender.withAlpha(179)),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Color tileColor,
  ) {
    return Card(
      color: tileColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: AppColors.white, size: 28),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.lavender.withAlpha(204),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (blocContext) => ChatCubit(
            chatRepository: blocContext.read<ChatRepository>(),
            roomId: widget.roomId,
          ),
      child: Scaffold(
        appBar: AppBar(
          title:
              widget.officialName != null && widget.officialName!.isNotEmpty
                  ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.subSpaceName,
                        style: const TextStyle(fontSize: 18.0),
                      ),
                      Text(
                        "currently operate by ${widget.officialName}",
                        style: TextStyle(
                          fontSize: 13.0,
                          color: AppColors.white.withAlpha(204),
                        ),
                      ),
                    ],
                  )
                  : Text(
                    widget.subSpaceName,
                  ), //? fallback if officialName is not available
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.white),
            onPressed: () {
              GoRouter.of(context).pop();
              print("Back button pressed");
            },
          ),
        ),
        body: SafeArea(
          child: BlocListener<ChatCubit, ChatState>(
            listenWhen: (previousState, currentState) {
              return currentState is ChatLoaded &&
                  previousState is ChatLoaded &&
                  currentState.messages.length > previousState.messages.length;
            },
            listener: (context, state) {
              if (state is ChatLoaded) {
                final String? currentUserId =
                    Supabase.instance.client.auth.currentUser?.id;
                // if (state.messages.isNotEmpty &&
                //     state.messages.length > _lastMessageCount) {

                final Message latestMessage =
                    state.messages.first; //? check this could be got it flip
                if (latestMessage.senderId != currentUserId) {
                  print(
                    "New message received from official, triggering BLE command!",
                  );
                  try {
                    // ? make sure to provide/use CustomBluetoothService
                    //?  and the device is connected.
                    final CustomBluetoothService bleService =
                        context.read<CustomBluetoothService>();
                    if (bleService.isConnected.value) {
                      //? check if connected
                      bleService.sendCommand(
                        "Vibrate",
                      ); //? "vibrate" for new message
                    } else {
                      print("BLE: Not connected, can't send command.");
                    }
                  } catch (e) {
                    print("Error sending BLE command: $e");
                    // ? or show a less prentious error, e.g., a small toast
                    context.customShowSnackBar("Wristband not notified.");
                  }
                }
                // }
                //? update the last message count for debugging
                // _lastMessageCount = state.messages.length;
                // print("Just updated message count to: $_lastMessageCount");
              }
            },
            //? Optional: listenWhen to optimize if needed, e.g.,
            //? listenWhen: (previous, current) =>
            // ?   current is ChatLoaded && previous is ChatLoaded && current.messages.length > previous.messages.length,
            child: Column(
              children: [
                Expanded(
                  child: BlocBuilder<ChatCubit, ChatState>(
                    builder: (context, state) {
                      final String? currentUserId =
                          Supabase.instance.client.auth.currentUser?.id;
                      if (state is ChatLoading || state is ChatInitial) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is ChatError) {
                        return Center(
                          child: Text(
                            "Error: ${state.message}",
                            style: const TextStyle(color: Colors.red),
                          ),
                        );
                      } else if (state is ChatLoaded) {
                        if (state.messages.isEmpty) {
                          // _lastMessageCount = 0; //? reset if messages empty
                          return const Center(
                            child: Text("No messages yet. Start chatting!"),
                          );
                        }
                        // ? here chat is loaded and not empty
                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 0),
                          reverse: true,
                          itemCount: state.messages.length,
                          itemBuilder: (context, index) {
                            final Message message = state.messages[index];
                            final bool isMe = message.senderId == currentUserId;

                            return MessageBubble(message: message, isMe: isMe);
                          },
                        );
                      } else {
                        return const Center(
                          child: Text("Something went wrong"),
                        );
                      }
                    },
                  ),
                ),
                Builder(
                  builder: (BuildContext descendantContext) {
                    return Container(
                      margin: EdgeInsets.only(
                        left: 0.0,
                        right: 0.0,
                        top: 4.0,
                        bottom:
                            MediaQuery.of(context).viewInsets.bottom > 0
                                ? 3.5
                                : 0,
                      ),

                      padding: const EdgeInsets.only(
                        top: 0,
                        bottom: 0,
                        left: 8.0,
                        right: 8.0,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              maxLines: 6,
                              minLines: 1,
                              controller: _textController,
                              textCapitalization: TextCapitalization.sentences,
                              autocorrect: true,
                              enableSuggestions: true,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: AppColors.lavender,
                                hintText: "Type your message...",
                                hintStyle: TextStyle(
                                  color: AppColors.haiti.withAlpha(200),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                              ),
                              // onChanged: (_) {
                              //   setState(() {
                              //     _showMicIcon =
                              //         _textController.text.trim().isEmpty;
                              //   });
                              // },
                              onSubmitted:
                                  (_) => _sendMessage(descendantContext),
                            ),
                          ),
                          const SizedBox(width: 8.0),

                          _showMicIcon
                              ? Container(
                                decoration: BoxDecoration(
                                  color: AppColors.deluge,
                                  borderRadius: BorderRadius.circular(36),
                                ),
                                child: IconButton(
                                  onPressed: () {},
                                  icon: const Icon(
                                    Icons.mic_rounded,
                                    color: AppColors.white,
                                  ),
                                ),
                              )
                              : Container(
                                decoration: BoxDecoration(
                                  color: AppColors.haiti,
                                  borderRadius: BorderRadius.circular(36),
                                ),
                                child: IconButton(
                                  onPressed:
                                      () => _sendMessage(descendantContext),
                                  tooltip: "Send Message",
                                  icon: const Icon(
                                    Icons.send,
                                    color: AppColors.white,
                                  ),
                                ),
                              ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
