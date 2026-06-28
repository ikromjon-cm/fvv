import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/design_tokens.dart';
import '../../core/network/auth_guard.dart';
import '../../core/responsive/responsive.dart';
import '../../core/utils/phone.dart';
import '../../data/local/app_storage.dart';
import '../../services/api_service.dart';
import '../../shared/widgets/app_icon.dart';
import '../../shared/widgets/mechanic_avatar.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.requestId,
    required this.mechanicName,
    this.isDriver = true,
  });
  final String requestId;
  final String mechanicName;
  final bool isDriver;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _textCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _messages = <Map<String, dynamic>>[];
  Timer? _pollTimer;
  bool _sending = false;
  int? _numericRequestId;
  String _otherPhone = '';
  String _otherStatus = '';
  bool _showAttachments = false;
  bool _showQuickReplies = true;
  bool _isFetching = false;
  final _flashNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _numericRequestId = int.tryParse(widget.requestId);
    _init();
  }

  Future<void> _init() async {
    _loadPhone();
    await _fetchMessages();
    _pollTimer =
        Timer.periodic(const Duration(seconds: 3), (_) => _fetchMessages(silent: true));
  }

  Future<void> _loadPhone() async {
    final reqId = _numericRequestId;
    if (reqId == null) return;
    try {
      final r = await ApiService.getRequest(reqId);
      final phone = (widget.isDriver ? r['mechanic_phone'] : r['driver_phone']) as String?;
      final status = (widget.isDriver ? r['mechanic_status'] : r['driver_status']) as String?;
      if (mounted && phone != null && phone.isNotEmpty) {
        setState(() => _otherPhone = phone);
      }
      if (mounted && status != null && status.isNotEmpty) {
        setState(() => _otherStatus = status);
      }
    } on ApiException catch (e) {
      AuthGuard.handleUnauthorized(context, e);
    } catch (_) {}
  }

  Future<void> _fetchMessages({bool silent = false}) async {
    final reqId = _numericRequestId;
    if (reqId == null) {
      if (!silent) {
        final saved = await AppStorage.getChatMessages(widget.requestId);
        if (mounted && saved.isNotEmpty) {
          setState(() {
            _messages.clear();
            for (final m in saved) {
              _messages.add({
                'id': null,
                'text': m['text'] as String,
                'isMe': m['isMe'] as bool,
                'time': (m['time'] as DateTime).toIso8601String(),
              });
            }
          });
          _scrollToBottom();
        }
      }
      return;
    }

    if (mounted) setState(() => _isFetching = true);
    try {
      final raw = await ApiService.getChatMessages(reqId);
      if (!mounted) return;
      final incoming = raw.map((e) {
        final m = e as Map<String, dynamic>;
        return {
          'id': m['id'],
          'text': m['text'] as String,
          'isMe': m['is_me'] as bool? ?? false,
          'time': m['created_at'] as String,
        };
      }).toList();

      if (incoming.length != _messages.length) {
        final prevCount = _messages.length;
        setState(() {
          _messages.clear();
          _messages.addAll(incoming);
        });
        _scrollToBottom();
        if (incoming.length > prevCount && prevCount > 0 && silent) {
          _flashNotifier.value = true;
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) _flashNotifier.value = false;
          });
        }
      }
    } on ApiException catch (e) {
      if (mounted) AuthGuard.handleUnauthorized(context, e);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isFetching = false);
    }
  }

  void _onQuickReply(String text) {
    _textCtrl.text = text;
    _send();
  }

  Future<void> _send() async {
    final text = _textCtrl.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() {
      _sending = true;
      _showQuickReplies = false;
    });
    _textCtrl.clear();

    final reqId = _numericRequestId;
    if (reqId == null) {
      setState(() {
        _messages.add({
          'id': null,
          'text': text,
          'isMe': true,
          'time': DateTime.now().toIso8601String()
        });
      });
      await AppStorage.saveChatMessages(widget.requestId,
          _messages.map((m) => {
                'text': m['text'],
                'isMe': m['isMe'],
                'time': DateTime.parse(m['time'] as String)
              }).toList());
      setState(() => _sending = false);
      _scrollToBottom();
      return;
    }

    try {
      final msg = await ApiService.sendChatMessage(reqId, text);
      if (mounted) {
        setState(() {
          _messages.add({
            'id': msg['id'],
            'text': msg['text'] as String,
            'isMe': msg['is_me'] as bool? ?? true,
            'time': msg['created_at'] as String,
          });
        });
        _scrollToBottom();
      }
    } on ApiException catch (e) {
      if (mounted) AuthGuard.handleUnauthorized(context, e);
    } catch (_) {
      if (mounted) {
        setState(() {
          _messages.add({
            'id': null,
            'text': text,
            'isMe': true,
            'time': DateTime.now().toIso8601String()
          });
        });
        _scrollToBottom();
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          0,
          duration: DesignTokens.animNormal,
          curve: DesignTokens.easeOut,
        );
      }
    });
  }

  String _formatTime(String iso) {
    try {
      final t = DateTime.parse(iso).toLocal();
      return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final msgDate = DateTime(dt.year, dt.month, dt.day);

    if (msgDate == today) return 'Bugun';
    if (msgDate == yesterday) return 'Kecha';
    const months = ['', 'Yanv', 'Fev', 'Mart', 'Apr', 'May', 'Iyun', 'Iyul', 'Avg', 'Sent', 'Okt', 'Noy', 'Dek'];
    return '${dt.day} ${months[dt.month]}';
  }

  String _messageDateStr(Map<String, dynamic> msg) {
    final time = msg['time'] as String?;
    if (time == null) return '';
    try {
      return _formatDate(DateTime.parse(time).toLocal());
    } catch (_) {
      return '';
    }
  }

  List<dynamic> get _displayItems {
    final items = <dynamic>[];
    String? lastDate;
    for (final msg in _messages) {
      final date = _messageDateStr(msg);
      if (date != lastDate) {
        items.add(date);
        lastDate = date;
      }
      items.add(msg);
    }
    return items.reversed.toList();
  }

  int get _displayCount => _displayItems.length;

  @override
  void dispose() {
    _pollTimer?.cancel();
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    _flashNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.cScaffold,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          _buildStatusBanner(context),
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    reverse: true,
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                    itemCount: _displayCount,
                    itemBuilder: (_, i) {
                      final item = _displayItems[i];
                      if (item is String) {
                        return _DateDivider(date: item);
                      }
                      final msg = item as Map<String, dynamic>;
                      final isMe = msg['isMe'] as bool? ?? false;
                      final text = msg['text'] as String? ?? '';
                      final time = _formatTime(msg['time'] as String? ?? '');
                      return _Bubble(
                        text: text,
                        isMe: isMe,
                        time: time,
                        isLast: i == 0 && isMe,
                      );
                    },
                  ),
          ),
          _buildQuickReplies(),
          if (_otherStatus == 'online' || _isFetching)
            _buildTypingIndicator(),
          _buildInputBar(context),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: context.cScaffold,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const AppIcon('arrow_back_ios_new', size: 20),
        onPressed: () => context.pop(),
      ),
      title: Row(
        children: [
          MechanicAvatar(name: widget.mechanicName, size: 38),
          SizedBox(width: context.spMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.mechanicName.isNotEmpty ? widget.mechanicName : 'Mexanik',
                  overflow: TextOverflow.ellipsis,
                  style: context.labelLarge(color: context.cTextPrimary).copyWith(fontWeight: FontWeight.w700),
                ),
                SizedBox(height: context.spXXS),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _otherStatus == 'online' ? DesignTokens.success : context.cTextTertiary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: context.spXS),
                    Text(
                      _otherStatus == 'online' ? 'Online' : 'Offline',
                      style: context.labelSmall(
                        color: _otherStatus == 'online' ? DesignTokens.success : context.cTextTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        if (_otherPhone.isNotEmpty)
          IconButton(
            icon: AppIcon('phone_outlined', color: context.cPrimary),
            onPressed: () => dialPhone(_otherPhone),
          ),
      ],
    );
  }

  Widget _buildTypingIndicator() {
    return _TypingDots();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: DesignTokens.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: context.cPrimary.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const AppIcon('chat_bubble_outline_rounded', size: 36, color: Colors.white),
          ),
          SizedBox(height: context.spXL),
          Text('Xabar yozing', style: context.headingSmall(color: context.cTextPrimary)),
          SizedBox(height: context.spSM),
          Text(
            "Birinchi xabarni yozing",
            style: context.bodyMedium(color: context.cTextSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBanner(BuildContext context) {
    if (_otherStatus.isEmpty) return const SizedBox.shrink();

    Color color;
    String label;

    switch (_otherStatus) {
      case 'onWay':
        color = DesignTokens.info;
        label = "Yo'lda";
        break;
      case 'arrived':
        color = DesignTokens.success;
        label = 'Yetib keldi';
        break;
      case 'ish_boshladi':
        color = DesignTokens.emergency;
        label = 'Ish boshladi';
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: color.withValues(alpha: 0.1),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(label, style: context.labelSmall(color: color)),
        ],
      ),
    );
  }

  Widget _buildQuickReplies() {
    if (!_showQuickReplies || _messages.isNotEmpty) return const SizedBox.shrink();

    const replies = [
      'Qayerdasiz?',
      'Qancha vaqt?',
      'Narxi qancha?',
      'Yordam kerak',
      'Keling',
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: replies.map((text) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => _onQuickReply(text),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: context.cFieldFill,
                  borderRadius: BorderRadius.circular(context.radiusFull),
                  border: Border.all(color: context.cBorder),
                ),
                child: Text(text, style: context.bodySmall(color: context.cTextPrimary)),
              ),
            ),
          )).toList(),
        ),
      ),
    );
  }

  Widget _buildInputBar(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(context.spSM, context.spSM, context.spSM, context.spSM + bottomPad),
      decoration: BoxDecoration(
        color: context.glassFill,
        border: Border(top: BorderSide(color: context.glassBorder)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_showAttachments)
            Container(
              height: 100,
              margin: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _AttachmentBtn(
                    icon: 'camera_alt_outlined',
                    label: 'Kamera',
                    onTap: () {},
                  ),
                  _AttachmentBtn(
                    icon: 'image_outlined',
                    label: 'Galereya',
                    onTap: () {},
                  ),
                  _AttachmentBtn(
                    icon: 'my_location_rounded',
                    label: 'Lokatsiya',
                    onTap: () {},
                  ),
                ],
              ),
            ),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _showAttachments = !_showAttachments);
                },
                child: Container(
                  width: 40,
                  height: 40,
                  margin: const EdgeInsets.only(left: 4),
                  decoration: BoxDecoration(
                    color: context.cFieldFill,
                    borderRadius: BorderRadius.circular(context.radiusMD),
                  ),
                  child: AppIcon(
                    'add_rounded',
                    size: 22,
                    color: context.cTextSecondary,
                  ),
                ),
              ),
              SizedBox(width: context.spSM),
              Tooltip(
                message: 'Joylashuvni ulashish',
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: context.cFieldFill,
                    borderRadius: BorderRadius.circular(context.radiusMD),
                  ),
                  child: AppIcon(
                    'my_location_rounded',
                    size: 20,
                    color: context.cTextTertiary,
                  ),
                ),
              ),
              SizedBox(width: context.spSM),
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 120),
                  decoration: BoxDecoration(
                    color: context.cFieldFill,
                    borderRadius: BorderRadius.circular(context.radiusFull),
                    border: Border.all(color: context.glassBorder),
                  ),
                  child: TextField(
                    controller: _textCtrl,
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: null,
                    onSubmitted: (_) => _send(),
                    decoration: InputDecoration(
                      hintText: 'Xabar yozing...',
                      hintStyle: context.bodyMedium(color: context.cTextTertiary),
                      filled: true,
                      fillColor: Colors.transparent,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(context.radiusFull),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: context.spSM),
              ListenableBuilder(
                listenable: Listenable.merge([_textCtrl, _flashNotifier]),
                builder: (_, __) {
                  final canSend =
                      _textCtrl.text.trim().isNotEmpty && !_sending;
                  final flash = _flashNotifier.value && canSend;
                  return GestureDetector(
                    onTap: canSend ? _send : null,
                    child: AnimatedContainer(
                      duration: DesignTokens.animNormal,
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: canSend
                            ? context.gPrimary
                            : null,
                        color: canSend ? null : context.cFieldFill,
                        shape: BoxShape.circle,
                        boxShadow: canSend
                            ? [
                                BoxShadow(
                                  color: (flash
                                          ? context.cEmergency
                                          : context.cPrimary)
                                      .withValues(alpha: 0.3),
                                  blurRadius: flash ? 20 : 12,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: _sending
                          ? const Padding(
                              padding: EdgeInsets.all(13),
                              child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white),
                            )
                          : AppIcon(
                              'send_rounded',
                              size: 20,
                              color: canSend
                                  ? Colors.white
                                  : DesignTokens.lightTextTertiary,
                            ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DateDivider extends StatelessWidget {
  const _DateDivider({required this.date});
  final String date;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(child: Divider(color: context.cBorder)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: context.cFieldFill,
                borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
              ),
              child: Text(
                date,
                style: context.labelSmall(color: context.cTextSecondary).copyWith(letterSpacing: 0.3),
              ),
            ),
          ),
          Expanded(child: Divider(color: context.cBorder)),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.text,
    required this.isMe,
    required this.time,
    this.isLast = false,
  });

  final String text;
  final bool isMe;
  final String time;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: isMe ? context.gPrimary : null,
                color: isMe ? null : context.cSurface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isMe ? 18 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 18),
                ),
                border: isMe
                    ? null
                    : Border.all(color: context.cBorder, width: 0.5),
                boxShadow: isMe ? null : context.shadowSM,
              ),
              child: Column(
                crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: context.bodyLarge(
                      color: isMe ? Colors.white : context.cTextPrimary,
                    ).copyWith(height: 1.4),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (time.isNotEmpty)
                        Text(
                          time,
                          style: context.labelSmall(
                            color: isMe
                                ? Colors.white.withValues(alpha: 0.65)
                                : context.cTextTertiary,
                          ),
                        ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.check,
                          size: 14,
                          color: isMe
                              ? Colors.white.withValues(alpha: 0.65)
                              : context.cTextTertiary,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isMe) const SizedBox(width: 4),
        ],
      ),
    );
  }
}

class _TypingDots extends StatefulWidget {
  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: context.cSurface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: context.cBorder, width: 0.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                return AnimatedBuilder(
                  animation: _ctrl,
                  builder: (_, __) {
                    final t = (_ctrl.value * 3 - i).clamp(0.0, 1.0);
                    final scale = 0.4 + 0.6 * (t < 0.5 ? t * 2 : 2 - t * 2);
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Transform.scale(
                        scale: scale,
                        child: Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: context.cTextTertiary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _AttachmentBtn extends StatelessWidget {
  const _AttachmentBtn({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final String icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: context.cPrimary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
            ),
            child: AppIcon(icon, size: 22, color: context.cPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: context.labelSmall(color: context.cTextSecondary),
          ),
        ],
      ),
    );
  }
}
