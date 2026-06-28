import 'package:flutter/material.dart';

abstract class Disposable {
  void dispose();
}

class DisposableManager {
  final List<Disposable> _disposables = [];

  void add(Disposable d) => _disposables.add(d);
  void addAll(Iterable<Disposable> disposables) => _disposables.addAll(disposables);

  void dispose() {
    for (final d in _disposables) {
      d.dispose();
    }
    _disposables.clear();
  }
}

mixin DisposableMixin<T extends StatefulWidget> on State<T> {
  final DisposableManager _manager = DisposableManager();

  void registerDisposable(Disposable d) => _manager.add(d);

  @override
  void dispose() {
    _manager.dispose();
    super.dispose();
  }
}

class ConditionalBuilder extends StatelessWidget {
  const ConditionalBuilder({
    super.key,
    required this.condition,
    required this.builder,
    this.fallbackBuilder,
  });

  final bool condition;
  final Widget Function() builder;
  final Widget Function()? fallbackBuilder;

  @override
  Widget build(BuildContext context) {
    if (condition) return builder();
    return fallbackBuilder?.call() ?? const SizedBox.shrink();
  }
}

extension ImagePerformance on Image {
  static Widget network({
    required String url,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget Function(BuildContext, String, Object)? errorBuilder,
    Widget Function(BuildContext, String)? placeholder,
  }) =>
      Image.network(
        url,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) =>
            errorBuilder?.call(context, url, error) ??
            Container(
              color: Colors.grey.withValues(alpha: 0.1),
              width: width,
              height: height,
            ),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return placeholder?.call(context, url) ??
              Container(
                color: Colors.grey.withValues(alpha: 0.05),
                width: width,
                height: height,
              );
        },
      );
}

extension BuildOptimization on Widget {
  Widget optimize() => RepaintBoundary(child: this);

  Widget keepAlive() => AutomaticKeepAliveClientWrapper(child: this);
}

class AutomaticKeepAliveClientWrapper extends StatefulWidget {
  const AutomaticKeepAliveClientWrapper({super.key, required this.child});

  final Widget child;

  @override
  State<AutomaticKeepAliveClientWrapper> createState() =>
      _AutomaticKeepAliveClientWrapperState();
}

class _AutomaticKeepAliveClientWrapperState
    extends State<AutomaticKeepAliveClientWrapper>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }

  @override
  bool get wantKeepAlive => true;
}
