import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import '../controllers/chat_controller.dart';
import '../components/message_bubble.dart';
import '../components/skeleton_loader.dart';

/// Chat Screen
/// One-to-one chat interface - 100% dumb UI
class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller with Get.put to ensure it's created
    final controller = Get.put(ChatController());

    // Scroll to bottom after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.scrollToBottomOnInit();
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: Row(
          children: [
            // Friend avatar
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF4A90E2), Color(0xFF6C63FF)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4A90E2).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: CircleAvatar(
                backgroundColor: Colors.transparent,
                radius: 18,
                child: Text(
                  controller.friendName.isNotEmpty
                      ? controller.friendName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Friend name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.friendName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Text(
                    'Online',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF43A047),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam_outlined),
            onPressed: () {
              Get.snackbar(
                "Coming Soon",
                "Video call functionality is coming soon",
                backgroundColor: Colors.black,
                colorText: Colors.white,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.call_outlined),
            onPressed: () {
              Get.snackbar(
                "Coming Soon",
                "Voice call functionality is coming soon",
                backgroundColor: Colors.black,
                colorText: Colors.white,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              Get.snackbar(
                "Coming Soon",
                "More options is coming soon",
                backgroundColor: Colors.black,
                colorText: Colors.white,
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: GestureDetector(
              onTap: () => controller.hideEmojiPicker(),
              child: Stack(
                children: [
                  Obx(() {
                    if (controller.isLoading.value &&
                        controller.messages.isEmpty) {
                      return const MessagesListSkeleton();
                    }

                    if (controller.messages.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No messages yet',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Start the conversation!',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: controller.scrollController,
                      padding: const EdgeInsets.only(
                        top: 12,
                        bottom: 60, // 🔥 space for typing indicator
                      ),
                      itemCount: controller.messages.length,
                      itemBuilder: (context, index) {
                        return MessageBubble(
                          message: controller.messages[index],
                        );
                      },
                    );
                  }),

                  // ================= TYPING INDICATOR =================
                  Obx(() {
                    if (!controller.isFriendTyping.value) {
                      return const SizedBox.shrink();
                    }

                    return Positioned(
                      left: 12,
                      bottom: 8,
                      child: TypingBubble(friendName: controller.friendName),
                    );
                  }),
                ],
              ),
            ),
          ),

          // Message input area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Emoji button
                  Obx(
                    () => IconButton(
                      icon: Icon(
                        controller.showEmojiPicker.value
                            ? Icons.keyboard
                            : Icons.emoji_emotions_outlined,
                        color: controller.showEmojiPicker.value
                            ? const Color(0xFF4A90E2)
                            : Colors.grey[600],
                      ),
                      onPressed: () {
                        controller.toggleEmojiPicker();
                      },
                    ),
                  ),

                  // Text input field
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: controller.messageController,
                        focusNode: controller.messageFocusNode,
                        onChanged: controller.onTextChanged,
                        decoration: const InputDecoration(
                          hintText: 'Type a message...',
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            fontSize: 15,
                            color: Colors.grey,
                          ),
                        ),
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                        onSubmitted: (_) => controller.sendMessage(),
                        onTap: () => controller.hideEmojiPicker(),
                      ),
                    ),
                  ),

                  const SizedBox(width: 4),

                  // Attach button
                  IconButton(
                    icon: Icon(Icons.attach_file, color: Colors.grey[600]),
                    onPressed: () {
                      Get.snackbar(
                        "Coming Soon",
                        "File attachment functionality is coming soon",
                        backgroundColor: Colors.black,
                        colorText: Colors.white,
                        snackPosition: SnackPosition.TOP,
                        margin: const EdgeInsets.all(10),
                      );
                    },
                  ),

                  // Send button
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4A90E2), Color(0xFF6C63FF)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4A90E2).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: controller.sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Emoji Picker
          Obx(
            () => Offstage(
              offstage: !controller.showEmojiPicker.value,
              child: SizedBox(
                height: 250,
                child: EmojiPicker(
                  onEmojiSelected: (category, emoji) {
                    controller.onEmojiSelected(emoji.emoji);
                  },
                  config: Config(
                    height: 256,
                    checkPlatformCompatibility: true,
                    emojiViewConfig: EmojiViewConfig(
                      columns: 7,
                      emojiSizeMax: 28,
                      verticalSpacing: 0,
                      horizontalSpacing: 0,
                      gridPadding: EdgeInsets.zero,
                      backgroundColor: const Color(0xFFF5F7FA),
                      buttonMode: ButtonMode.MATERIAL,
                    ),
                    skinToneConfig: const SkinToneConfig(),
                    categoryViewConfig: const CategoryViewConfig(
                      iconColor: Colors.grey,
                      iconColorSelected: Color(0xFF4A90E2),
                      backspaceColor: Color(0xFF4A90E2),
                      backgroundColor: Color(0xFFF5F7FA),
                    ),
                    bottomActionBarConfig: const BottomActionBarConfig(
                      backgroundColor: Color(0xFFF5F7FA),
                      buttonColor: Color(0xFFF5F7FA),
                      buttonIconColor: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TypingBubble extends StatelessWidget {
  final String friendName;

  const TypingBubble({super.key, required this.friendName});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            ' $friendName is typing...',
            style: TextStyle(
              fontSize: 13,
              fontStyle: FontStyle.italic,
              color: Colors.black54,
            ),
          ),
        ),
      ),
    );
  }
}
