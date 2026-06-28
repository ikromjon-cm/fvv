import 'package:flutter/material.dart';
import 'live_request_status.dart';

class StatusTimeline extends StatelessWidget {
  const StatusTimeline({
    super.key,
    required this.currentStatus,
    this.statusTimestamps,
  });

  final LiveRequestStatus currentStatus;
  final Map<LiveRequestStatus, DateTime>? statusTimestamps;

  static const _allSteps = [
    LiveRequestStatus.searching,
    LiveRequestStatus.accepted,
    LiveRequestStatus.onWay,
    LiveRequestStatus.arrived,
    LiveRequestStatus.working,
    LiveRequestStatus.completed,
  ];

  @override
  Widget build(BuildContext context) {
    final isCancelled = currentStatus == LiveRequestStatus.cancelled;
    final visibleSteps = isCancelled
        ? _allSteps
            .where((s) =>
                s.stepIndex <
                (statusTimestamps?.keys
                        .map((e) => e.stepIndex)
                        .reduce(
                            (a, b) => a > b ? a : b) ??
                    0))
            .toList()
        : _allSteps.where((s) => s.stepIndex <= currentStatus.stepIndex + 1).toList();

    return Column(
      children: List.generate(visibleSteps.length, (i) {
        final step = visibleSteps[i];
        final isCompleted = isCancelled
            ? (statusTimestamps?.containsKey(step) ?? false)
            : step.stepIndex < currentStatus.stepIndex;
        final isCurrent = step == currentStatus;
        final isFuture = !isCancelled &&
            step.stepIndex > currentStatus.stepIndex;
        final ts = statusTimestamps?[step];

        return _TimelineStep(
          step: step,
          isCompleted: isCompleted,
          isCurrent: isCurrent,
          isFuture: isFuture,
          isLast: i == visibleSteps.length - 1,
          timestamp: ts,
        );
      }),
    );
  }
}

class _TimelineStep extends StatefulWidget {
  const _TimelineStep({
    required this.step,
    required this.isCompleted,
    required this.isCurrent,
    required this.isFuture,
    required this.isLast,
    this.timestamp,
  });

  final LiveRequestStatus step;
  final bool isCompleted, isCurrent, isFuture, isLast;
  final DateTime? timestamp;

  @override
  State<_TimelineStep> createState() => _TimelineStepState();
}

class _TimelineStepState extends State<_TimelineStep>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (widget.isCurrent) _pulseCtrl.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(_TimelineStep old) {
    super.didUpdateWidget(old);
    if (widget.isCurrent && !old.isCurrent) {
      _pulseCtrl.repeat(reverse: true);
    } else if (!widget.isCurrent && old.isCurrent) {
      _pulseCtrl.stop();
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.step.color;
    final displayColor = widget.isFuture
        ? const Color(0xFFE2E8F0)
        : widget.isCurrent
            ? color
            : color;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 32,
            child: Column(
              children: [
                AnimatedBuilder(
                  animation: _pulseCtrl,
                  builder: (_, child) {
                    final pulseSize = widget.isCurrent
                        ? 8 + _pulseCtrl.value * 4
                        : 0.0;
                    return Container(
                      width: 28 + pulseSize,
                      height: 28 + pulseSize,
                      decoration: BoxDecoration(
                        color: displayColor.withAlpha(widget.isFuture ? 30 : 200),
                        shape: BoxShape.circle,
                        boxShadow: widget.isCurrent
                            ? [
                                BoxShadow(
                                  color: color.withAlpha(80),
                                  blurRadius: 8 + _pulseCtrl.value * 4,
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Icon(
                          widget.step.icon,
                          size: 14,
                          color: widget.isFuture
                              ? const Color(0xFFCBD5E1)
                              : Colors.white,
                        ),
                      ),
                    );
                  },
                ),
                if (!widget.isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      decoration: BoxDecoration(
                        color: widget.isCompleted || (widget.isCurrent && !_pulseCtrl.isAnimating)
                            ? displayColor
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: widget.isLast ? 0 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.step.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: widget.isCurrent
                          ? FontWeight.w700
                          : FontWeight.w500,
                      fontFamily: 'Inter',
                      color: widget.isFuture
                          ? const Color(0xFFCBD5E1)
                          : const Color(0xFF0F172A),
                    ),
                  ),
                  if (widget.timestamp != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      _formatTime(widget.timestamp!),
                      style: const TextStyle(
                        fontSize: 11,
                        fontFamily: 'Inter',
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
