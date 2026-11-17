import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../shared/widgets/app_feedback.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/topographic_scaffold.dart';
import '../../domain/entities/ai_entities.dart';
import '../bloc/ai_cubits.dart';

/// [FE-05] Trò chuyện với trợ lý du lịch AI (RAG trên cơ sở tri thức SmartTravel).
class AiTravelChatScreen extends StatelessWidget {
  const AiTravelChatScreen({super.key, this.initialQuestion});

  final String? initialQuestion;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = sl<AiChatCubit>();
        if (initialQuestion != null) cubit.send(initialQuestion!);
        return cubit;
      },
      child: const _ChatView(),
    );
  }
}

class _ChatView extends StatefulWidget {
  const _ChatView();

  @override
  State<_ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<_ChatView> {
  final _input = TextEditingController();
  final _scroll = ScrollController();

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send([String? text]) {
    final value = text ?? _input.text;
    if (value.trim().isEmpty) return;
    context.read<AiChatCubit>().send(value);
    _input.clear();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return TopographicScaffold(
      seed: 13,
      appBar: CustomAppBar(
        title: context.tr('ai.chat_title'),
        subtitle: context.tr('ai.chat_subtitle'),
      ),
      body: BlocConsumer<AiChatCubit, AiChatState>(
        listener: (context, state) {
          _scrollToEnd();
          if (state.errorMessage != null) {
            showAppSnackBar(context, state.errorMessage!, type: SnackType.error);
          }
        },
        builder: (context, state) {
          final last = state.messages.isEmpty ? null : state.messages.last;
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: state.messages.length + (state.isTyping ? 1 : 0),
                  itemBuilder: (_, i) {
                    if (i == state.messages.length) return const _TypingBubble();
                    return _MessageBubble(message: state.messages[i]);
                  },
                ),
              ),
              if (!state.isTyping && last != null && !last.isUser && last.suggestions.isNotEmpty)
                SizedBox(
                  height: 44,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      for (final s in last.suggestions)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ActionChip(label: Text(s), onPressed: () => _send(s)),
                        ),
                    ],
                  ),
                ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _input,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _send(),
                          minLines: 1,
                          maxLines: 4,
                          decoration: InputDecoration(hintText: context.tr('ai.chat_input_hint')),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton.filled(
                        tooltip: context.tr('ai.send_btn'),
                        onPressed: state.isTyping ? null : _send,
                        icon: const Icon(Icons.send_rounded),
                        style: IconButton.styleFrom(minimumSize: const Size(52, 52)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.8),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: isUser ? AppColors.primaryGradient : null,
          color: isUser ? null : AppColors.surfaceWhite,
          border: isUser ? null : Border.all(color: AppColors.cardBorder),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 18),
          ),
          boxShadow: isUser ? null : AppColors.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser)
              const Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome_rounded, size: 14, color: AppColors.accentSoftGold),
                    SizedBox(width: 4),
                    Text('SmartTravel AI',
                        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.accentSoftGold)),
                  ],
                ),
              ),
            Text(
              message.text,
              style: TextStyle(color: isUser ? Colors.white : AppColors.textPrimary, height: 1.5),
            ),
            if (message.sources.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                context.tr('ai.sources_prefix', params: {'sources': message.sources.join(' · ')}),
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontStyle: FontStyle.italic),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          border: Border.all(color: AppColors.cardBorder),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
            const SizedBox(width: 10),
            Text(context.tr('ai.typing_message'), style: const TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
