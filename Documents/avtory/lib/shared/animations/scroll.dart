import 'package:flutter/material.dart';
import 'animation_tokens.dart';

class MotionScrollBehavior extends ScrollBehavior {
  const MotionScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics();
  }
}

class MotionScrollController {
  MotionScrollController({double initialScrollOffset = 0})
      : controller = ScrollController(initialScrollOffset: initialScrollOffset);

  final ScrollController controller;

  bool get hasClients => controller.hasClients;
  double get offset => controller.hasClients ? controller.offset : 0;
  double get maxScrollExtent => controller.hasClients ? controller.position.maxScrollExtent : 0;

  void scrollToTop() {
    if (controller.hasClients && controller.offset > 0) {
      controller.animateTo(
        0,
        duration: MotionTokens.fast,
        curve: MotionTokens.decelerate,
      );
    }
  }

  void scrollTo(double position) {
    if (controller.hasClients) {
      controller.animateTo(
        position,
        duration: MotionTokens.normal,
        curve: MotionTokens.decelerate,
      );
    }
  }

  bool get isAtTop => !controller.hasClients || controller.offset <= 0;
  bool get isAtBottom => controller.hasClients &&
      controller.offset >= controller.position.maxScrollExtent - 10;

  void dispose() {
    if (controller.hasClients) controller.dispose();
  }
}

class AnimatedScrollToTop extends StatelessWidget {
  const AnimatedScrollToTop({
    super.key,
    required this.scrollController,
    required this.show,
  });

  final MotionScrollController scrollController;
  final bool show;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: MotionTokens.fast,
      curve: MotionTokens.decelerate,
      opacity: show ? 1.0 : 0.0,
      child: AnimatedScale(
        duration: MotionTokens.fast,
        curve: MotionTokens.decelerate,
        scale: show ? 1.0 : 0.5,
        child: show
            ? FloatingActionButton.small(
                onPressed: scrollController.scrollToTop,
                child: const Icon(Icons.keyboard_arrow_up),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
