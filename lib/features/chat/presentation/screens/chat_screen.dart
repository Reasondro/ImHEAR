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
    }
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
          backgroundColor: AppColors.haiti,
          elevation: 0, //? no shadow for a cleaner look
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
              // print("Back button pressed");
            },
          ),
        ),
        body: SafeArea(
          child: BlocListener<ChatCubit, ChatState>(
            listenWhen: (previousState, currentState) {
              //?  only trigger for actual new messages after initial load
              return currentState is ChatLoaded &&
                  previousState is ChatLoaded &&
                  currentState.messages.length > previousState.messages.length;
            },
            listener: (context, state) {
              if (state is ChatLoaded) {
                final String? currentUserId =
                    Supabase.instance.client.auth.currentUser?.id;
                final Message latestMessage =
                    state.messages.first; //? check this could be got it flip
                if (latestMessage.senderId != currentUserId) {
                  // print(
                  //   "New message received from official, triggering BLE command!",
                  // );
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
                      // print("BLE: Not connected, can't send command.");
                    }
                  } catch (e) {
                    // print("Error sending BLE command: $e");
                    // ? or show a less prentious error, e.g., a small toast
                    context.customShowSnackBar("Wristband not notified.");
                  }
                }
              }
            },

            child: Column(
              children: [
                _buildTabSelector(), //?  the "Space Chat" / "Notifications" buttons
                Expanded(
                  child: IndexedStack(
                    index: _selectedTabIndex,
                    children: [
                      _buildSpaceChatWidget(
                        context,
                      ), //? pass context (for read / watch stuffs)
                      _buildNotificationsWidget(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //?  widget for tab buttons
  Widget _buildTabSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        children: List.generate(_tabTitles.length, (index) {
          bool isSelected = _selectedTabIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTabIndex = index;
                });
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 3),
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? AppColors.bittersweet
                          : AppColors.deluge.withAlpha(180),
                  borderRadius: BorderRadius.circular(10),
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
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 14,
                      ),
                    ),
                    if (index == 1) // ? if Notifications tab
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
        }),
      ),
    );
  }

  // ? widget for the main chat area (messages + input)
  Widget _buildSpaceChatWidget(BuildContext context) {
    // ? pass context if descendantContext is needed
    return Column(
      children: [
        Expanded(
          child: BlocBuilder<ChatCubit, ChatState>(
            builder: (blocBuilderContext, state) {
              //? use a different context name (just for avoiding weird errors)
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
                  return const Center(
                    child: Text("No messages yet. Start chatting!"),
                  );
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
        //?  quick Message Panel
        if (_isQuickMessagePanelVisible)
          Container(
            height: 180,
            color: AppColors.deluge.withAlpha(230),
            child: ListView.builder(
              itemCount: _quickMessages.length,
              itemBuilder: (context, index) {
                return Material(
                  // ? inkwell ripple effect
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      _textController.text = _quickMessages[index];
                      _textController.selection = TextSelection.fromPosition(
                        TextPosition(offset: _textController.text.length),
                      );
                      setState(() {
                        _isQuickMessagePanelVisible = false;
                        _showMicIcon = false; //? text field now has content
                      });
                      FocusScope.of(
                        context,
                      ).requestFocus(); //? keep focus on text field
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

        // ? message input row (modified for quickf mesage togle) ---
        // ? builder to ensure the _sendMessage receives the correct context
        // ? ==> that is a descendant of the ChatCubit's BlocProvider.
        Builder(
          builder: (BuildContext descendantContextForInput) {
            return Container(
              margin: const EdgeInsets.only(
                left: 8.0,
                right: 8.0,
                top: 4.0,
                bottom: 8,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 4.0,
              ),
              decoration: BoxDecoration(
                color: AppColors.lavender.withAlpha(204),
                borderRadius: BorderRadius.circular(25.0),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  //? quick message toggle button
                  IconButton(
                    icon: Icon(
                      // ? dfiferent icon depending on the quick toggle state
                      _isQuickMessagePanelVisible
                          ? Icons.keyboard_arrow_down
                          : Icons.dashboard_customize_outlined,
                      color: AppColors.haiti,
                    ),
                    tooltip: "Quick Messages",
                    onPressed: () {
                      setState(() {
                        _isQuickMessagePanelVisible =
                            !_isQuickMessagePanelVisible;

                        //  // ? for now don't hide keyboard
                        if (_isQuickMessagePanelVisible) {
                          FocusScope.of(
                            context,
                          ).unfocus(); //? hide keyboard if opening quick messages
                        }
                      });
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      maxLines: 4,
                      minLines: 1,
                      textCapitalization: TextCapitalization.sentences,
                      autocorrect: true,
                      enableSuggestions: true,
                      decoration: InputDecoration(
                        filled: false,
                        hintText: "Type your message...",
                        hintStyle: TextStyle(
                          color: AppColors.haiti.withAlpha(179),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 10,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          if (_isQuickMessagePanelVisible) {
                            _isQuickMessagePanelVisible =
                                !_isQuickMessagePanelVisible;
                          }
                        });
                      },
                      onSubmitted:
                          (_) => _sendMessage(descendantContextForInput),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: _showMicIcon ? AppColors.deluge : AppColors.haiti,
                      borderRadius: BorderRadius.circular(36),
                    ),
                    child: IconButton(
                      onPressed:
                          _showMicIcon
                              ? () {
                                // TODO: Mic action
                                // print("Mic pressed");
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

  // ? widget for the notifications list
  Widget _buildNotificationsWidget() {
    //TODO  Replace with actual notification data and BlocBuilder if needed
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // ? dummy data from figma
        _buildNotificationItem(
          context,
          Icons.directions_bus,
          "Arriving at Lebak Bulus Station",
          "2 minutes ago",
          // AppColors.deluge,
          AppColors.haiti,
        ),
        _buildNotificationItem(
          context,
          Icons.directions_bus,
          "Arriving at Fatmawati Station",
          "15 minutes ago",
          // AppColors.deluge,
          AppColors.haiti,
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
          // AppColors.deluge
          AppColors.haiti,
        ),
        _buildNotificationItem(
          context,
          Icons.warning_amber_rounded,
          "Earthquake",
          "35 minutes ago",
          AppColors.rawSienna,
        ), //? assuming rawSienna for earthquake (should be red though lol)
        _buildNotificationItem(
          context,
          Icons.directions_bus,
          "Arriving at Kuningan Station",
          "55 minutes ago",
          // AppColors.deluge
          AppColors.haiti,
        ),
        _buildNotificationItem(
          context,
          Icons.directions_bus,
          "Arriving at Gambir Station",
          "1 Hour 2 minutes ago",
          // AppColors.deluge,
          AppColors.haiti,
        ),
        const SizedBox(height: 20),
        Center(
          child: Text(
            "End of Notifications",
            style: TextStyle(color: AppColors.haiti.withAlpha(179)),
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
}
