import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Controls how a newly mounted reveal enters the Hoje screen.
enum OrigemRevealReplayPolicy { sessionAware, always, finalState }

/// Named beats of the cinematic presentation.
enum OrigemRevealStage {
  loading,
  entering,
  searching,
  scanning,
  decoding,
  opening,
  revealing,
  dissolving,
  settled,
}

/// Lets the Hoje screen resolve the visual beat before opening the scanner.
class OrigemProductRevealController {
  VoidCallback? _complete;
  VoidCallback? _replay;

  void completePresentation() => _complete?.call();
  void replay() => _replay?.call();

  void _attach({required VoidCallback complete, required VoidCallback replay}) {
    _complete = complete;
    _replay = replay;
  }

  void _detach() {
    _complete = null;
    _replay = null;
  }
}

/// Reusable 2.5D product reveal used by the Hoje screen.
///
/// A 4.6 second timeline orchestrates scan, barcode decoding, articulated
/// panels, product reveal and surface-to-data dissolve. A second controller
/// only supplies the settled 3 px breathing drift.
class OrigemProductReveal extends StatefulWidget {
  const OrigemProductReveal({
    super.key,
    this.replayPolicy = OrigemRevealReplayPolicy.sessionAware,
    this.controller,
  });

  final OrigemRevealReplayPolicy replayPolicy;
  final OrigemProductRevealController? controller;

  static const packagePosterAsset =
      'assets/images/generated/origem_scan_package_transparent_v3.png';
  static const wordmarkAsset =
      'assets/brand/origem_wordmark_transparent_v2.png';
  static const canAsset = 'assets/images/generated/origem_product_can_v4.png';
  static const yogurtAsset =
      'assets/images/generated/origem_product_yogurt_v4.png';
  static const pastaAsset =
      'assets/images/generated/origem_product_pasta_v4.png';
  static const tomatoAsset =
      'assets/images/generated/origem_product_tomato_v4.png';
  static const leafAsset = 'assets/images/generated/origem_product_leaf_v4.png';

  static const productAssets = <String>[
    wordmarkAsset,
    canAsset,
    yogurtAsset,
    pastaAsset,
    tomatoAsset,
    leafAsset,
  ];

  @visibleForTesting
  static void debugResetReplayHistory() {
    _OrigemProductRevealState._lastFullPresentation = null;
  }

  @override
  State<OrigemProductReveal> createState() => _OrigemProductRevealState();
}

enum _ReplayKind { full, short, reduced, finalState }

class _OrigemProductRevealState extends State<OrigemProductReveal>
    with TickerProviderStateMixin {
  static DateTime? _lastFullPresentation;
  static const _replayAfter = Duration(minutes: 8);
  static const _fullDuration = Duration(milliseconds: 4600);
  static const _shortDuration = Duration(milliseconds: 900);
  static const _reducedDuration = Duration(milliseconds: 300);

  late final AnimationController _timeline;
  late final AnimationController _rest;
  _ReplayKind _kind = _ReplayKind.full;
  bool _assetsReady = false;
  bool _assetFallbackActive = false;
  bool _precacheStarted = false;

  @override
  void initState() {
    super.initState();
    _timeline = AnimationController(vsync: this, duration: _fullDuration)
      ..addStatusListener(_onTimelineStatus);
    _rest = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6800),
    );
    widget.controller?._attach(complete: _complete, replay: _replay);
  }

  @override
  void didUpdateWidget(covariant OrigemProductReveal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._detach();
      widget.controller?._attach(complete: _complete, replay: _replay);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_precacheStarted) return;
    _precacheStarted = true;
    _prepareAssets();
  }

  Future<void> _prepareAssets() async {
    var failed = false;
    await Future.wait(
      OrigemProductReveal.productAssets.map(
        (asset) => precacheImage(
          AssetImage(asset),
          context,
          onError: (exception, stackTrace) => failed = true,
        ),
      ),
    );
    if (!mounted) return;
    setState(() {
      _assetsReady = true;
      _assetFallbackActive = failed;
    });
    _startInitialPresentation();
  }

  void _startInitialPresentation() {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (widget.replayPolicy == OrigemRevealReplayPolicy.finalState) {
      _kind = _ReplayKind.finalState;
      _timeline.value = 1;
      return;
    }
    if (reduceMotion) {
      _kind = _ReplayKind.reduced;
      _timeline.duration = _reducedDuration;
      _timeline.forward(from: 0);
      return;
    }

    final now = DateTime.now();
    final playFull =
        widget.replayPolicy == OrigemRevealReplayPolicy.always ||
        _lastFullPresentation == null ||
        now.difference(_lastFullPresentation!) > _replayAfter;
    if (playFull) {
      _lastFullPresentation = now;
      _kind = _ReplayKind.full;
      _timeline.duration = _fullDuration;
    } else {
      _kind = _ReplayKind.short;
      _timeline.duration = _shortDuration;
    }
    _timeline.forward(from: 0);
  }

  void _onTimelineStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed || !mounted) return;
    if (!MediaQuery.disableAnimationsOf(context) &&
        _kind != _ReplayKind.finalState) {
      _rest.repeat(reverse: true);
    }
  }

  void _complete() {
    if (!_assetsReady || _timeline.isCompleted) return;
    _timeline.animateTo(
      1,
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOutCubic,
    );
  }

  void _replay() {
    if (!_assetsReady || MediaQuery.disableAnimationsOf(context)) return;
    _rest.stop();
    _rest.value = 0;
    setState(() => _kind = _ReplayKind.full);
    _timeline.duration = _fullDuration;
    _timeline.forward(from: 0);
  }

  double _presentationProgress(double value) {
    if (_kind != _ReplayKind.short) return value;
    if (value < .32) {
      return _lerp(.13, .30, Curves.easeInOutCubic.transform(value / .32));
    }
    if (value < .68) {
      return _lerp(
        .48,
        .80,
        Curves.easeOutCubic.transform((value - .32) / .36),
      );
    }
    return _lerp(.80, 1, Curves.easeInOutCubic.transform((value - .68) / .32));
  }

  @override
  void dispose() {
    widget.controller?._detach();
    _timeline
      ..removeStatusListener(_onTimelineStatus)
      ..dispose();
    _rest.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final reduceMotion = MediaQuery.disableAnimationsOf(context);
      return Semantics(
        image: true,
        label:
            'Produto Origem escaneado e revelado em alimentos frescos e embalados, representando a análise do conteúdo nutricional.',
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (!_assetsReady)
              const _ImmediatePoster(key: Key('origem-reveal-loading'))
            else
              RepaintBoundary(
                child: AnimatedBuilder(
                  animation: Listenable.merge([_timeline, _rest]),
                  builder: (context, _) {
                    final rest = _timeline.isCompleted && !reduceMotion
                        ? math.sin(_rest.value * math.pi) * 1.2
                        : 0.0;
                    final rawProgress = _presentationProgress(_timeline.value);
                    final stage = _stageFor(rawProgress, _assetsReady);
                    return Semantics(
                      value: stage.name,
                      child: Transform.translate(
                        offset: Offset(0, -rest),
                        child: _kind == _ReplayKind.reduced
                            ? _ReducedMotionComposition(
                                progress: _timeline.value,
                                fallbackActive: _assetFallbackActive,
                              )
                            : _RevealComposition(
                                progress: rawProgress,
                                compact: constraints.maxWidth < 420,
                                fallbackActive: _assetFallbackActive,
                              ),
                      ),
                    );
                  },
                ),
              ),
            if (kDebugMode && _assetsReady && !reduceMotion)
              Positioned(
                right: 4,
                bottom: 4,
                child: IconButton(
                  key: const Key('origem-reveal-replay'),
                  tooltip: 'Reiniciar apresentação',
                  onPressed: _replay,
                  visualDensity: VisualDensity.compact,
                  style: IconButton.styleFrom(
                    foregroundColor: AppColors.sand,
                    backgroundColor: AppColors.petroleum.withValues(alpha: .62),
                  ),
                  icon: const Icon(Icons.replay_rounded, size: 18),
                ),
              ),
            if (_assetFallbackActive)
              const Positioned(
                key: Key('origem-reveal-fallback'),
                left: 0,
                top: 0,
                child: SizedBox.shrink(),
              ),
          ],
        ),
      );
    },
  );
}

OrigemRevealStage _stageFor(double progress, bool ready) {
  if (!ready) return OrigemRevealStage.loading;
  if (progress < .152) return OrigemRevealStage.entering;
  if (progress < .235) return OrigemRevealStage.searching;
  if (progress < .283) return OrigemRevealStage.scanning;
  if (progress < .413) return OrigemRevealStage.decoding;
  if (progress < .54) return OrigemRevealStage.opening;
  if (progress < .696) return OrigemRevealStage.revealing;
  if (progress < .87) return OrigemRevealStage.dissolving;
  return OrigemRevealStage.settled;
}

class _ImmediatePoster extends StatelessWidget {
  const _ImmediatePoster({super.key});

  @override
  Widget build(BuildContext context) => const FittedBox(
    fit: BoxFit.contain,
    child: SizedBox(
      width: 520,
      height: 580,
      child: Stack(
        children: [
          _GroundShadow(opacity: .36, spread: 0),
          _PackageAssembly(opening: 0, dissolve: 0, scan: 0),
          _PackageForegroundPanels(
            progress: 0,
            opening: 0,
            dissolve: 0,
            scan: 0,
          ),
        ],
      ),
    ),
  );
}

class _ReducedMotionComposition extends StatelessWidget {
  const _ReducedMotionComposition({
    required this.progress,
    required this.fallbackActive,
  });

  final double progress;
  final bool fallbackActive;

  @override
  Widget build(BuildContext context) {
    final crossfade = _phase(progress, .5, 1, Curves.easeInOutCubic);
    return Stack(
      fit: StackFit.expand,
      children: [
        Opacity(opacity: 1 - crossfade, child: const _ImmediatePoster()),
        Opacity(
          opacity: crossfade,
          child: _RevealComposition(
            progress: 1,
            compact: false,
            fallbackActive: fallbackActive,
          ),
        ),
      ],
    );
  }
}

class _RevealComposition extends StatelessWidget {
  const _RevealComposition({
    required this.progress,
    required this.compact,
    required this.fallbackActive,
  });

  final double progress;
  final bool compact;
  final bool fallbackActive;

  @override
  Widget build(BuildContext context) {
    final entrance = _phase(progress, 0, .152, Curves.easeOutCubic);
    final search = _phase(progress, .152, .235, Curves.easeInOutCubic);
    final scan = _phase(progress, .20, .283, Curves.easeInOutCubic);
    final decode = _phase(progress, .283, .413, Curves.easeInOutCubic);
    final opening = _phase(progress, .391, .652, Curves.easeInOutCubic);
    final dissolve = _phase(progress, .696, .89, Curves.easeInOutCubic);
    final finalSettle = _phase(progress, .87, 1, Curves.easeInOutCubic);
    final scale = (.88 + .12 * entrance) * (compact ? .92 : 1);

    return ClipRect(
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: 520,
          height: 580,
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, .001)
              ..translateByDouble(0, 24 * (1 - entrance), 0, 1)
              ..scaleByDouble(scale, scale, scale, 1)
              ..rotateX(.035 * (1 - entrance))
              ..rotateY(-.055 * (1 - entrance) + .012 * search),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                _GroundShadow(opacity: .14 + entrance * .34, spread: opening),
                CustomPaint(
                  key: const Key('barcode-orbits'),
                  size: const Size(520, 580),
                  painter: _NutritionOrbitPainter(
                    decode: decode,
                    reveal: _phase(progress, .50, .89),
                    settle: finalSettle,
                    foreground: false,
                  ),
                ),
                _PackageAssembly(
                  opening: opening,
                  dissolve: dissolve,
                  scan: scan,
                ),
                _ProductRevealLayer(
                  progress: progress,
                  fallbackActive: fallbackActive,
                ),
                IgnorePointer(
                  child: _PackageForegroundPanels(
                    progress: progress,
                    opening: opening,
                    dissolve: dissolve,
                    scan: scan,
                  ),
                ),
                IgnorePointer(
                  child: CustomPaint(
                    size: const Size(520, 580),
                    painter: _NutritionOrbitPainter(
                      decode: decode,
                      reveal: _phase(progress, .50, .89),
                      settle: finalSettle,
                      foreground: true,
                    ),
                  ),
                ),
                IgnorePointer(
                  child: CustomPaint(
                    key: const Key('origem-focus-lens'),
                    size: const Size(520, 580),
                    painter: _ScannerFocusPainter(
                      visibility:
                          _phase(progress, .035, .17) *
                          (1 - _phase(progress, .30, .42)),
                      search: search,
                      scan: scan,
                      recognized: scan > .92,
                      recognizedColor: const Color(0xFF58A6FF),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductRevealLayer extends StatelessWidget {
  const _ProductRevealLayer({
    required this.progress,
    required this.fallbackActive,
  });

  final double progress;
  final bool fallbackActive;

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      _ProductLayer(
        key: const Key('origem-product-leaf'),
        asset: OrigemProductReveal.leafAsset,
        kind: _ProductKind.leaf,
        rect: const Rect.fromLTWH(72, 135, 180, 182),
        progress: _phase(progress, .69, .82),
        originOffset: const Offset(128, 112),
        rotation: -.13,
      ),
      _ProductLayer(
        key: const Key('origem-product-can'),
        asset: OrigemProductReveal.canAsset,
        kind: _ProductKind.can,
        rect: const Rect.fromLTWH(278, 72, 184, 190),
        progress: _phase(progress, .50, .65),
        originOffset: const Offset(-92, 148),
        rotation: .09,
      ),
      _ProductLayer(
        key: const Key('origem-product-yogurt'),
        asset: OrigemProductReveal.yogurtAsset,
        kind: _ProductKind.yogurt,
        rect: const Rect.fromLTWH(304, 266, 180, 177),
        progress: _phase(progress, .56, .71),
        originOffset: const Offset(-105, -15),
        rotation: -.06,
      ),
      _ProductLayer(
        key: const Key('origem-product-pasta'),
        asset: OrigemProductReveal.pastaAsset,
        kind: _ProductKind.pasta,
        rect: const Rect.fromLTWH(58, 340, 190, 225),
        progress: _phase(progress, .61, .76),
        originOffset: const Offset(112, -102),
        rotation: .08,
      ),
      _ProductLayer(
        key: const Key('origem-product-tomato'),
        asset: OrigemProductReveal.tomatoAsset,
        kind: _ProductKind.tomato,
        rect: const Rect.fromLTWH(132, 205, 264, 230),
        progress: _phase(progress, .65, .80),
        originOffset: const Offset(4, 52),
        rotation: -.07,
      ),
      if (fallbackActive)
        const Positioned.fill(child: IgnorePointer(child: SizedBox.shrink())),
    ],
  );
}

enum _ProductKind { can, yogurt, pasta, tomato, leaf }

class _ProductLayer extends StatelessWidget {
  const _ProductLayer({
    super.key,
    required this.asset,
    required this.kind,
    required this.rect,
    required this.progress,
    required this.originOffset,
    required this.rotation,
  });

  final String asset;
  final _ProductKind kind;
  final Rect rect;
  final double progress;
  final Offset originOffset;
  final double rotation;

  @override
  Widget build(BuildContext context) {
    final settle = _controlledOvershoot(progress);
    final scale = _lerp(.58, 1, settle);
    return Positioned.fromRect(
      rect: rect,
      child: RepaintBoundary(
        child: Opacity(
          opacity: progress,
          child: Transform.translate(
            offset: originOffset * (1 - settle),
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, .0012)
                ..scaleByDouble(scale, scale, scale, 1)
                ..rotateY(rotation * (1 - settle))
                ..rotateZ(rotation * .55 * (1 - settle)),
              child: Image.asset(
                asset,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
                errorBuilder: (_, _, _) =>
                    CustomPaint(painter: _FallbackProductPainter(kind)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PackageAssembly extends StatelessWidget {
  const _PackageAssembly({
    required this.opening,
    required this.dissolve,
    required this.scan,
  });

  final double opening;
  final double dissolve;
  final double scan;

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      _HingedPanel(
        key: const Key('origem-package-back'),
        rect: const Rect.fromLTWH(151, 124, 218, 332),
        progress: _phase(opening, 0, .70),
        translate: const Offset(0, -28),
        scale: .93,
        surface: _PanelSurface(kind: _PanelKind.back, dissolve: dissolve),
      ),
      _HingedPanel(
        key: const Key('origem-package-left'),
        rect: const Rect.fromLTWH(126, 124, 42, 332),
        progress: _phase(opening, .22, .88),
        translate: const Offset(-76, 2),
        rotateY: -1.02,
        alignment: Alignment.centerRight,
        surface: _PanelSurface(kind: _PanelKind.side, dissolve: dissolve),
      ),
      _HingedPanel(
        key: const Key('origem-package-right'),
        rect: const Rect.fromLTWH(360, 124, 38, 332),
        progress: _phase(opening, .34, 1),
        translate: const Offset(78, 6),
        rotateY: 1.05,
        alignment: Alignment.centerLeft,
        surface: _PanelSurface(kind: _PanelKind.side, dissolve: dissolve),
      ),
      _HingedPanel(
        key: const Key('origem-package-top'),
        rect: const Rect.fromLTWH(151, 69, 218, 82),
        progress: _phase(opening, 0, .62),
        translate: const Offset(0, -58),
        rotateX: -1.12,
        rotateY: .04,
        alignment: Alignment.bottomCenter,
        surface: _PanelSurface(kind: _PanelKind.top, dissolve: dissolve),
      ),
      _HingedPanel(
        rect: const Rect.fromLTWH(168, 118, 72, 32),
        progress: _phase(opening, .16, .78),
        translate: const Offset(-34, -32),
        rotateY: -.74,
        alignment: Alignment.centerRight,
        surface: _PanelSurface(kind: _PanelKind.flap, dissolve: dissolve),
      ),
      _HingedPanel(
        rect: const Rect.fromLTWH(280, 118, 72, 32),
        progress: _phase(opening, .28, .90),
        translate: const Offset(36, -28),
        rotateY: .74,
        alignment: Alignment.centerLeft,
        surface: _PanelSurface(kind: _PanelKind.flap, dissolve: dissolve),
      ),
    ],
  );
}

class _PackageForegroundPanels extends StatelessWidget {
  const _PackageForegroundPanels({
    required this.progress,
    required this.opening,
    required this.dissolve,
    required this.scan,
  });

  final double progress;
  final double opening;
  final double dissolve;
  final double scan;

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      _HingedPanel(
        key: const Key('origem-package-front'),
        rect: const Rect.fromLTWH(151, 124, 218, 332),
        progress: _phase(opening, .10, .92),
        translate: const Offset(-16, 112),
        rotateX: -.16,
        rotateY: -.18,
        alignment: Alignment.topCenter,
        surface: _FrontPanel(
          scan: scan,
          dissolve: dissolve,
          logoOpacity: 1 - _phase(dissolve, .56, 1),
        ),
      ),
      if (dissolve > 0)
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _DissolvingContourPainter(
                progress: dissolve,
                opening: opening,
              ),
            ),
          ),
        ),
    ],
  );
}

enum _PanelKind { front, side, top, back, flap }

class _HingedPanel extends StatelessWidget {
  const _HingedPanel({
    super.key,
    required this.rect,
    required this.progress,
    required this.translate,
    required this.surface,
    this.rotateX = 0,
    this.rotateY = 0,
    this.scale = 1,
    this.alignment = Alignment.center,
  });

  final Rect rect;
  final double progress;
  final Offset translate;
  final Widget surface;
  final double rotateX;
  final double rotateY;
  final double scale;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) => Positioned.fromRect(
    rect: rect,
    child: Transform(
      alignment: alignment,
      transform: Matrix4.identity()
        ..setEntry(3, 2, .0016)
        ..translateByDouble(
          translate.dx * progress,
          translate.dy * progress,
          30 * progress,
          1,
        )
        ..scaleByDouble(
          _lerp(1, scale, progress),
          _lerp(1, scale, progress),
          1,
          1,
        )
        ..rotateX(rotateX * progress)
        ..rotateY(rotateY * progress),
      child: RepaintBoundary(child: surface),
    ),
  );
}

class _PanelSurface extends StatelessWidget {
  const _PanelSurface({required this.kind, required this.dissolve});

  final _PanelKind kind;
  final double dissolve;

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _PanelPainter(
      kind: kind,
      surfaceOpacity: 1 - dissolve,
      outlineOpacity: math.sin(dissolve * math.pi),
    ),
  );
}

class _FrontPanel extends StatelessWidget {
  const _FrontPanel({
    required this.scan,
    required this.dissolve,
    required this.logoOpacity,
  });

  final double scan;
  final double dissolve;
  final double logoOpacity;

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      CustomPaint(
        painter: _PanelPainter(
          kind: _PanelKind.front,
          surfaceOpacity: 1 - dissolve,
          outlineOpacity: math.sin(dissolve * math.pi),
        ),
      ),
      Positioned(
        left: 18,
        right: 18,
        top: 57,
        height: 62,
        child: Opacity(
          opacity: logoOpacity,
          child: Image.asset(
            OrigemProductReveal.wordmarkAsset,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
        ),
      ),
      Positioned(
        left: 42,
        right: 42,
        bottom: 23,
        height: 55,
        child: Opacity(
          opacity: 1 - dissolve,
          child: CustomPaint(painter: _BarcodePainter(scan: scan)),
        ),
      ),
    ],
  );
}

class _PanelPainter extends CustomPainter {
  const _PanelPainter({
    required this.kind,
    required this.surfaceOpacity,
    required this.outlineOpacity,
  });

  final _PanelKind kind;
  final double surfaceOpacity;
  final double outlineOpacity;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final radius = kind == _PanelKind.top
        ? const Radius.circular(15)
        : const Radius.circular(7);
    final panel = RRect.fromRectAndRadius(rect.deflate(.8), radius);
    final fill = switch (kind) {
      _PanelKind.side => const Color(0xFFE6DED1),
      _PanelKind.back => const Color(0xFFD8CEBF),
      _PanelKind.flap => const Color(0xFFEDE7DC),
      _ => AppColors.mineral,
    };
    canvas.drawRRect(
      panel,
      Paint()..color = fill.withValues(alpha: surfaceOpacity),
    );

    if (kind == _PanelKind.front && surfaceOpacity > 0) {
      final navyPath = Path()
        ..moveTo(0, size.height * .59)
        ..cubicTo(
          size.width * .23,
          size.height * .67,
          size.width * .53,
          size.height * .61,
          size.width,
          size.height * .49,
        )
        ..lineTo(size.width, size.height * .76)
        ..cubicTo(
          size.width * .63,
          size.height * .83,
          size.width * .30,
          size.height * .79,
          0,
          size.height * .88,
        )
        ..close();
      canvas.drawPath(
        navyPath,
        Paint()
          ..color = const Color(0xFF1C3554).withValues(alpha: surfaceOpacity),
      );
      final apricotLine = Path()
        ..moveTo(0, size.height * .58)
        ..cubicTo(
          size.width * .24,
          size.height * .66,
          size.width * .55,
          size.height * .60,
          size.width,
          size.height * .48,
        );
      canvas.drawPath(
        apricotLine,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = AppColors.apricot.withValues(alpha: surfaceOpacity),
      );
    }

    if (kind == _PanelKind.top && surfaceOpacity > 0) {
      final capCenter = Offset(size.width * .52, size.height * .42);
      canvas.drawOval(
        Rect.fromCenter(center: capCenter, width: 60, height: 37),
        Paint()..color = AppColors.petroleum.withValues(alpha: surfaceOpacity),
      );
      for (var i = 0; i < 12; i++) {
        final x = capCenter.dx - 25 + i * 4.5;
        canvas.drawLine(
          Offset(x, capCenter.dy - 12),
          Offset(x, capCenter.dy + 11),
          Paint()
            ..strokeWidth = 1
            ..color = AppColors.sage.withValues(alpha: surfaceOpacity * .24),
        );
      }
    }

    if (surfaceOpacity > 0) {
      final fiber = Paint()
        ..strokeWidth = .55
        ..color = const Color(
          0xFF9B8F7D,
        ).withValues(alpha: surfaceOpacity * .10);
      for (var i = 0; i < 24; i++) {
        final y = (i + .5) * size.height / 24;
        final x = (math.sin(i * 2.13) * .5 + .5) * size.width * .82;
        canvas.drawLine(Offset(x, y), Offset(x + 11, y + 2), fiber);
      }
    }

    if (outlineOpacity > 0) {
      canvas.drawRRect(
        panel,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4
          ..color = AppColors.apricot.withValues(alpha: outlineOpacity * .72),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PanelPainter oldDelegate) =>
      oldDelegate.surfaceOpacity != surfaceOpacity ||
      oldDelegate.outlineOpacity != outlineOpacity ||
      oldDelegate.kind != kind;
}

class _BarcodePainter extends CustomPainter {
  const _BarcodePainter({required this.scan});
  final double scan;

  @override
  void paint(Canvas canvas, Size size) {
    const widths = <double>[2, 4, 2, 3, 5, 2, 4, 2, 6, 2, 3, 5, 2, 4, 2, 3];
    final total =
        widths.fold<double>(0, (sum, value) => sum + value) +
        (widths.length - 1) * 2.2;
    var x = (size.width - total) / 2;
    for (var i = 0; i < widths.length; i++) {
      final barProgress = ((scan * (widths.length + 3)) - i).clamp(0.0, 1.0);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, 4, widths[i], size.height - 8),
          const Radius.circular(1),
        ),
        Paint()
          ..color = Color.lerp(
            AppColors.petroleum,
            AppColors.apricot,
            barProgress,
          )!,
      );
      x += widths[i] + 2.2;
    }
  }

  @override
  bool shouldRepaint(covariant _BarcodePainter oldDelegate) =>
      oldDelegate.scan != scan;
}

class _ScannerFocusPainter extends CustomPainter {
  const _ScannerFocusPainter({
    required this.visibility,
    required this.search,
    required this.scan,
    required this.recognized,
    required this.recognizedColor,
  });

  final double visibility;
  final double search;
  final double scan;
  final bool recognized;
  final Color recognizedColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (visibility <= 0) return;
    final drift = math.sin(search * math.pi * 2) * 5;
    final rect = Rect.fromCenter(
      center: Offset(size.width * .5 + drift, size.height * .47),
      width: 302,
      height: 428,
    );
    final color = Color.lerp(
      AppColors.sand,
      recognizedColor,
      recognized ? 1 : scan,
    )!.withValues(alpha: visibility * .86);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    const length = 24.0;
    final segments = <Path>[
      Path()
        ..moveTo(rect.left + length, rect.top)
        ..quadraticBezierTo(rect.left, rect.top, rect.left, rect.top + length),
      Path()
        ..moveTo(rect.right - length, rect.top)
        ..quadraticBezierTo(
          rect.right,
          rect.top,
          rect.right,
          rect.top + length,
        ),
      Path()
        ..moveTo(rect.left, rect.bottom - length)
        ..quadraticBezierTo(
          rect.left,
          rect.bottom,
          rect.left + length,
          rect.bottom,
        ),
      Path()
        ..moveTo(rect.right, rect.bottom - length)
        ..quadraticBezierTo(
          rect.right,
          rect.bottom,
          rect.right - length,
          rect.bottom,
        ),
    ];
    for (final path in segments) {
      canvas.drawPath(path, paint);
    }

    if (scan > 0 && scan < 1) {
      final beamX = _lerp(196, 324, scan);
      final beamPaint = Paint()
        ..color = AppColors.apricot.withValues(
          alpha: math.sin(scan * math.pi) * visibility,
        )
        ..strokeWidth = 3.2
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);
      canvas.drawLine(Offset(beamX, 392), Offset(beamX, 446), beamPaint);
    }

    if (scan > .88) {
      final click = ((scan - .88) / .12).clamp(0.0, 1.0);
      canvas.drawCircle(
        Offset(size.width * .5, size.height * .47),
        18 + 18 * click,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = recognizedColor.withValues(alpha: 1 - click),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ScannerFocusPainter oldDelegate) =>
      oldDelegate.visibility != visibility ||
      oldDelegate.search != search ||
      oldDelegate.scan != scan ||
      oldDelegate.recognized != recognized;
}

class _NutritionOrbitPainter extends CustomPainter {
  const _NutritionOrbitPainter({
    required this.decode,
    required this.reveal,
    required this.settle,
    required this.foreground,
  });

  final double decode;
  final double reveal;
  final double settle;
  final bool foreground;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * .51, size.height * .51);
    final opacity = .22 + reveal * .35;
    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = foreground ? 3.2 : 2.4
      ..color = (foreground ? AppColors.apricot : AppColors.mineral).withValues(
        alpha: opacity,
      );

    if (decode > 0) {
      for (var i = 0; i < 6; i++) {
        final local = ((decode * 1.34) - i * .075).clamp(0.0, 1.0);
        final path = Path()
          ..moveTo(224 + i * 14, 421)
          ..cubicTo(
            180 - i * 5,
            350 - i * 8,
            168 + i * 19,
            220 + i * 10,
            374 - i * 13,
            174 + i * 22,
          );
        final metric = path.computeMetrics().first;
        canvas.drawPath(
          metric.extractPath(0, metric.length * local),
          basePaint,
        );
        if (local > .25 && local < .95) {
          final tangent = metric.getTangentForOffset(metric.length * local);
          if (tangent != null) {
            canvas.drawLine(
              tangent.position - const Offset(0, 5),
              tangent.position + const Offset(0, 5),
              Paint()
                ..strokeWidth = i.isEven ? 3 : 1.5
                ..color = AppColors.apricot.withValues(alpha: .72),
            );
          }
        }
      }
    }

    if (reveal <= .18) return;
    final ringProgress = ((reveal - .18) / .82).clamp(0.0, 1.0);
    final rings = foreground
        ? const [(.01, .0, .78, .25)]
        : const [(-.19, -.12, .88, .29), (.18, .13, .72, .22)];
    for (final ring in rings) {
      canvas.save();
      canvas.translate(center.dx, center.dy + size.height * ring.$2);
      canvas.rotate(ring.$1);
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset.zero,
          width: size.width * ring.$3,
          height: size.height * ring.$4,
        ),
        foreground ? -.15 : math.pi,
        math.pi * (foreground ? 1 : 1.08) * ringProgress,
        false,
        basePaint,
      );
      canvas.restore();
    }

    if (foreground && settle > .08 && settle < .92) {
      final glowAngle = -math.pi + settle * math.pi * 2;
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(.01);
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset.zero,
          width: size.width * .78,
          height: size.height * .25,
        ),
        glowAngle,
        .18,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 6
          ..color = AppColors.warmYellow.withValues(alpha: .72)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _NutritionOrbitPainter oldDelegate) =>
      oldDelegate.decode != decode ||
      oldDelegate.reveal != reveal ||
      oldDelegate.settle != settle ||
      oldDelegate.foreground != foreground;
}

class _DissolvingContourPainter extends CustomPainter {
  const _DissolvingContourPainter({
    required this.progress,
    required this.opening,
  });

  final double progress;
  final double opening;

  @override
  void paint(Canvas canvas, Size size) {
    final opacity = math.sin(progress * math.pi) * .62;
    if (opacity <= 0) return;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..color = AppColors.apricot.withValues(alpha: opacity);
    final source = Offset(244 - 16 * opening, 410 + 92 * opening);
    for (var i = 0; i < 4; i++) {
      final local = ((progress * 1.25) - i * .08).clamp(0.0, 1.0);
      final path = Path()
        ..moveTo(source.dx + i * 18, source.dy - i * 22)
        ..cubicTo(128, 438 - i * 20, 126 + i * 16, 210, 380, 182 + i * 30);
      final metric = path.computeMetrics().first;
      canvas.drawPath(metric.extractPath(0, metric.length * local), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DissolvingContourPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.opening != opening;
}

class _GroundShadow extends StatelessWidget {
  const _GroundShadow({required this.opacity, required this.spread});

  final double opacity;
  final double spread;

  @override
  Widget build(BuildContext context) => Positioned(
    left: 128 - spread * 26,
    right: 128 - spread * 26,
    bottom: 66,
    height: 30,
    child: DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.elliptical(190, 22)),
        boxShadow: [
          BoxShadow(
            color: AppColors.apricot.withValues(alpha: opacity * .16),
            blurRadius: 28,
            spreadRadius: 6,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: opacity),
            blurRadius: 22,
            spreadRadius: 3,
          ),
        ],
      ),
    ),
  );
}

class _FallbackProductPainter extends CustomPainter {
  const _FallbackProductPainter(this.kind);
  final _ProductKind kind;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    switch (kind) {
      case _ProductKind.can:
        final body = RRect.fromRectAndRadius(
          Rect.fromLTWH(size.width * .18, 4, size.width * .64, size.height - 8),
          const Radius.circular(16),
        );
        canvas.drawRRect(body, Paint()..color = AppColors.mineral);
        canvas.drawRect(
          Rect.fromLTWH(
            size.width * .18,
            size.height * .52,
            size.width * .64,
            size.height * .28,
          ),
          Paint()..color = const Color(0xFF294C5A),
        );
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(center.dx, 14),
            width: size.width * .64,
            height: 22,
          ),
          Paint()..color = const Color(0xFFB9B8B3),
        );
      case _ProductKind.yogurt:
        final cup = Path()
          ..moveTo(size.width * .18, size.height * .18)
          ..lineTo(size.width * .28, size.height * .91)
          ..quadraticBezierTo(
            center.dx,
            size.height,
            size.width * .72,
            size.height * .91,
          )
          ..lineTo(size.width * .82, size.height * .18)
          ..close();
        canvas.drawPath(cup, Paint()..color = const Color(0xFFF0E4DA));
        canvas.drawOval(
          Rect.fromLTWH(5, 2, size.width - 10, size.height * .28),
          Paint()..color = const Color(0xFFD8D8D5),
        );
      case _ProductKind.pasta:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(8, 4, size.width - 16, size.height - 8),
            const Radius.circular(8),
          ),
          Paint()..color = AppColors.sand.withValues(alpha: .72),
        );
        final pastaPaint = Paint()
          ..color = AppColors.warmYellow
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6;
        for (var y = 34.0; y < size.height - 24; y += 24) {
          for (var x = 28.0; x < size.width - 20; x += 30) {
            canvas.drawArc(
              Rect.fromCenter(center: Offset(x, y), width: 22, height: 11),
              0,
              math.pi,
              false,
              pastaPaint,
            );
          }
        }
      case _ProductKind.tomato:
        canvas.drawOval(
          Rect.fromCenter(
            center: center,
            width: size.width * .86,
            height: size.height * .72,
          ),
          Paint()..color = const Color(0xFFF04B31),
        );
        canvas.drawLine(
          Offset(center.dx - 50, center.dy + 45),
          Offset(center.dx + 48, center.dy - 44),
          Paint()
            ..color = const Color(0xFFFFC59A)
            ..strokeWidth = 15,
        );
      case _ProductKind.leaf:
        final leaf = Path()
          ..moveTo(size.width * .08, size.height * .86)
          ..quadraticBezierTo(
            size.width * .18,
            size.height * .12,
            size.width * .92,
            size.height * .08,
          )
          ..quadraticBezierTo(
            size.width * .88,
            size.height * .76,
            size.width * .08,
            size.height * .86,
          )
          ..close();
        canvas.drawPath(leaf, Paint()..color = const Color(0xFF6C9D36));
        canvas.drawLine(
          Offset(size.width * .12, size.height * .82),
          Offset(size.width * .82, size.height * .16),
          Paint()
            ..color = AppColors.sage
            ..strokeWidth = 3,
        );
    }
  }

  @override
  bool shouldRepaint(covariant _FallbackProductPainter oldDelegate) =>
      oldDelegate.kind != kind;
}

double _phase(
  double value,
  double begin,
  double end, [
  Curve curve = Curves.easeOutCubic,
]) {
  if (end <= begin) return value >= end ? 1 : 0;
  final local = ((value - begin) / (end - begin)).clamp(0.0, 1.0);
  return curve.transform(local);
}

double _controlledOvershoot(double progress) {
  if (progress <= .76) {
    return _lerp(0, 1.035, Curves.easeOutCubic.transform(progress / .76));
  }
  return _lerp(
    1.035,
    1,
    Curves.easeInOutCubic.transform((progress - .76) / .24),
  );
}

double _lerp(double a, double b, double t) => a + (b - a) * t;
