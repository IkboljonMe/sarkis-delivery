import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/message_model.dart';
import '../../models/user_model.dart';
import '../../services/message_service.dart';
import '../../services/user_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/constants.dart';
import '../../widgets/app_input_field.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/golden_button.dart';
import 'chat_detail_screen.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  String _search = '';
  String _groupFilter = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _broadcast,
        icon: const Icon(Icons.campaign),
        label: const Text('Рассылка'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: AppInputField(
              label: 'Поиск по имени',
              prefixIcon: Icons.search,
              onChanged: (v) => setState(() => _search = v.toLowerCase()),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _chip('Все', ''),
                ...AppConstants.groups
                    .map((g) => _chip(AppConstants.groupLabel(g), g)),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<ChatTopicModel>>(
              stream: MessageService.instance.topicsStream(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                var topics = snap.data ?? [];
                if (_groupFilter.isNotEmpty) {
                  topics = topics
                      .where((t) => t.userGroup == _groupFilter)
                      .toList();
                }
                if (_search.isNotEmpty) {
                  topics = topics
                      .where(
                          (t) => t.userName.toLowerCase().contains(_search))
                      .toList();
                }
                if (topics.isEmpty) {
                  return const EmptyState(
                      icon: Icons.chat_bubble_outline, title: 'Нет чатов');
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: topics.length,
                  itemBuilder: (context, i) => _topicTile(topics[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, String value) {
    final sel = _groupFilter == value;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(label),
        selected: sel,
        selectedColor: AppColors.primary.withOpacity(0.2),
        onSelected: (_) => setState(() => _groupFilter = value),
      ),
    );
  }

  Widget _topicTile(ChatTopicModel t) {
    final time =
        t.lastAt != null ? DateFormat('d MMM HH:mm').format(t.lastAt!) : '';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.2),
          child: Text(
              t.userName.isNotEmpty ? t.userName[0].toUpperCase() : '?',
              style: const TextStyle(color: AppColors.primary)),
        ),
        title: Text(t.userName, style: AppTextStyles.bodyBold),
        subtitle: Text(t.lastMessage,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(time, style: AppTextStyles.label),
            if (t.unread > 0) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                    color: AppColors.accent, shape: BoxShape.circle),
                child: Text('${t.unread}',
                    style: const TextStyle(
                        color: Colors.white, fontSize: 10)),
              ),
            ],
          ],
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => ChatDetailScreen(
                  topicId: t.topicId, userName: t.userName)),
        ),
      ),
    );
  }

  Future<void> _broadcast() async {
    final textController = TextEditingController();
    String target = 'all'; // all | berlin | hamburg
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.fromLTRB(
              16, 16, 16, MediaQuery.of(ctx).viewInsets.bottom + 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Рассылка сообщений', style: AppTextStyles.headingM),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  _target(ctx, setSheet, target, 'all', 'Всем',
                      (v) => target = v),
                  _target(ctx, setSheet, target, 'Berlin', 'Берлин',
                      (v) => target = v),
                  _target(ctx, setSheet, target, 'Hamburg', 'Гамбург',
                      (v) => target = v),
                ],
              ),
              const SizedBox(height: 12),
              AppInputField(
                  controller: textController,
                  label: 'Текст сообщения',
                  maxLines: 4),
              const SizedBox(height: 12),
              GoldenButton(
                label: 'Отправить',
                onPressed: () async {
                  final text = textController.text.trim();
                  if (text.isEmpty) return;
                  Navigator.pop(ctx);
                  await _sendBroadcast(target, text);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _target(BuildContext ctx, StateSetter setSheet, String current,
      String value, String label, void Function(String) onPick) {
    return ChoiceChip(
      label: Text(label),
      selected: current == value,
      selectedColor: AppColors.primary.withOpacity(0.2),
      onSelected: (_) => setSheet(() => onPick(value)),
    );
  }

  Future<void> _sendBroadcast(String target, String text) async {
    final users = await UserService.instance.usersStream().first;
    final List<UserModel> targets = users.where((u) {
      if (u.isAdmin) return false;
      if (target == 'all') return true;
      return u.group == target;
    }).toList();

    for (final u in targets) {
      await MessageService.instance.ensureTopic(
          topicId: u.id, userName: u.name, userGroup: u.group);
      await MessageService.instance.sendMessage(
        topicId: u.id,
        text: text,
        senderId: 'admin',
        senderName: 'Admin',
        isFromAdmin: true,
      );
      // Each message triggers onChatMessageCreated, which pushes to the user.
    }
  }
}
