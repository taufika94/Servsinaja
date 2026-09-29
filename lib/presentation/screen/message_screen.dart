import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/dummy/dummy_data.dart';
import '../../data/models/chat_model.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ChatConversation> get _filteredConversations {
    if (_searchQuery.isEmpty) return DummyData.conversations;
    return DummyData.conversations
        .where((c) =>
            c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            c.lastMessage
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()))
        .toList();
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) {
      final h = time.hour.toString().padLeft(2, '0');
      final m = time.minute.toString().padLeft(2, '0');
      return '$h:$m';
    }
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    return '${time.day}/${time.month}';
  }

  @override
  Widget build(BuildContext context) {
    final conversations = _filteredConversations;

    return Scaffold(
      backgroundColor: AppColors.background,

      // ═══ APPBAR ═══
      appBar: AppBar(
        backgroundColor: AppColors.primaryOrange,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "Pesan",
          style: AppTextStyles.medium(
              weight: FontWeight.w700, color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      // ═══ BODY ═══
      body: Column(
        children: [
          // ═══ SEARCH BAR ═══
          Container(
            color: AppColors.primaryOrange,
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenH, 0, AppSpacing.screenH, AppSpacing.lg),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius:
                    BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: AppTextStyles.small(),
                      onChanged: (v) =>
                          setState(() => _searchQuery = v),
                      decoration: InputDecoration(
                        hintText: 'Cari Pesan',
                        hintStyle: AppTextStyles.small(
                            color: AppColors.textHint),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                  const Icon(Icons.search,
                      color: AppColors.primaryOrange, size: 22),
                ],
              ),
            ),
          ),

          // ═══ LIST CHAT ═══
          Expanded(
            child: conversations.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenH,
                      vertical: AppSpacing.md,
                    ),
                    itemCount: conversations.length + 1,
                    itemBuilder: (context, index) {
                      if (index == conversations.length) {
                        // ═══ FOOTER "Tidak ada pesan lagi" ═══
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.lg),
                          child: Center(
                            child: Text(
                              'Tidak ada pesan lagi',
                              style: AppTextStyles.small(
                                  color: AppColors.textHint),
                            ),
                          ),
                        );
                      }

                      final chat = conversations[index];
                      return _buildChatTile(chat);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // EMPTY STATE
  // ═══════════════════════════════════════
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.chat_bubble_outline,
              size: 80, color: AppColors.textHint),
          const SizedBox(height: AppSpacing.lg),
          Text('Belum ada pesan',
              style: AppTextStyles.medium(
                  weight: FontWeight.w600,
                  color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // CHAT TILE
  // ═══════════════════════════════════════
  Widget _buildChatTile(ChatConversation chat) {
    return GestureDetector(
      onTap: () {
        // Tandai sebagai dibaca
        setState(() => chat.isRead = true);

        // TODO: Navigate ke detail chat
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Buka chat dengan ${chat.name}',
              style: AppTextStyles.small(color: Colors.white),
            ),
            backgroundColor: AppColors.primaryOrange,
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(color: AppColors.divider, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ═══ AVATAR ═══
            Stack(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.softOrange,
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      chat.avatar,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Center(
                        child: Text(
                          chat.name.substring(0, 1).toUpperCase(),
                          style: AppTextStyles.medium(
                              weight: FontWeight.w700,
                              color: AppColors.primaryOrange),
                        ),
                      ),
                    ),
                  ),
                ),
                // ═══ STATUS ONLINE (dot hijau) ═══
                if (chat.isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: AppSpacing.md),

            // ═══ INFO CHAT ═══
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama + waktu
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          chat.name,
                          style: AppTextStyles.medium(
                            weight: chat.isRead
                                ? FontWeight.w400              // ← read = normal
                                : FontWeight.w500,             // ← unread = bold tipis
                            color: chat.isRead
                                ? AppColors.textSecondary
                                : AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        _formatTime(chat.lastMessageTime),
                        style: AppTextStyles.small(
                          color: chat.isRead
                              ? AppColors.textHint
                              : AppColors.primaryOrange,
                          weight: chat.isRead
                              ? FontWeight.w300
                              : FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),

                  // Pesan + dot unread
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          chat.lastMessage,
                          style: AppTextStyles.small(
                            color: chat.isRead
                                ? AppColors.textSecondary
                                : AppColors.textPrimary,
                            weight: chat.isRead
                                ? FontWeight.w300
                                : FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // ═══ DOT UNREAD ═══
                      if (!chat.isRead) ...[
                        const SizedBox(width: AppSpacing.sm),
                        Container(
                          margin: const EdgeInsets.only(top: 6),
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.discountPrice,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}