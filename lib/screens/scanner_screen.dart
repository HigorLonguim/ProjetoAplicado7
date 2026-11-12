import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/product_model.dart';
import '../services/history_service.dart';
import '../services/product_service.dart';
import '../theme/app_theme.dart';
import '../widgets/origem_scanner.dart';
import 'product_result_screen.dart';

export '../widgets/origem_scanner.dart'
    show ScannerFlowState, ScannerPermissionKind;

typedef ScannerProductLookup = Future<ProductModel> Function(String barcode);
typedef ScannerPermissionReader = Future<ScannerPermissionKind> Function();
typedef ScannerCameraBuilder =
    Widget Function(
      BuildContext context,
      MobileScannerController controller,
      ValueChanged<BarcodeCapture> onDetect,
    );

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({
    super.key,
    this.showBackButton = true,
    this.productLookup,
    this.permissionReader,
    this.permissionRequester,
    this.cameraBuilder,
    this.historyWriter,
  });

  final bool showBackButton;
  final ScannerProductLookup? productLookup;
  final ScannerPermissionReader? permissionReader;
  final ScannerPermissionReader? permissionRequester;
  final ScannerCameraBuilder? cameraBuilder;
  final Future<void> Function(ProductModel product)? historyWriter;

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  late final MobileScannerController _controller;
  late final AnimationController _entrance;
  late final AnimationController _barcodeMotion;
  late final AnimationController _loadingMotion;

  ScannerFlowState _state = ScannerFlowState.preparing;
  Rect? _lockRect;
  String _code = '';
  String? _lastCode;
  DateTime? _lastReadAt;
  ProductModel? _product;
  bool _busy = false;
  bool _torchOn = false;
  bool _permanentlyDenied = false;
  String? _cameraUnavailableReason;
  bool _slowLookup = false;
  int _loadingStep = 0;
  int _requestGeneration = 0;
  Timer? _stepTimerOne;
  Timer? _stepTimerTwo;
  Timer? _slowTimer;

  bool get _reduceMotion =>
      MediaQuery.maybeOf(context)?.disableAnimations ?? false;
  bool get _usesRealCamera => widget.cameraBuilder == null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = MobileScannerController(
      autoStart: true,
      detectionSpeed: DetectionSpeed.normal,
      detectionTimeoutMs: 350,
      facing: CameraFacing.back,
      formats: const [
        BarcodeFormat.ean8,
        BarcodeFormat.ean13,
        BarcodeFormat.upcA,
        BarcodeFormat.upcE,
      ],
    );
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _barcodeMotion = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _loadingMotion = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    unawaited(_initialize());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_reduceMotion) {
      _entrance.value = 1;
    } else if (!_entrance.isAnimating && _entrance.value == 0) {
      _entrance.forward();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_usesRealCamera || !mounted) return;
    if (state == AppLifecycleState.resumed &&
        _state == ScannerFlowState.ready) {
      unawaited(_safeStartCamera());
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      unawaited(_safeStopCamera());
    }
  }

  Future<void> _initialize() async {
    final permission =
        await (widget.permissionReader?.call() ?? _readPermission());
    if (!mounted) return;
    switch (permission) {
      case ScannerPermissionKind.granted:
        setState(() => _state = ScannerFlowState.ready);
      case ScannerPermissionKind.permanentlyDenied:
        setState(() {
          _permanentlyDenied = true;
          _state = ScannerFlowState.permissionDenied;
        });
      case ScannerPermissionKind.unavailable:
        setState(() => _state = ScannerFlowState.unavailable);
      case ScannerPermissionKind.denied:
        setState(() => _state = ScannerFlowState.permissionRequired);
    }
  }

  Future<ScannerPermissionKind> _readPermission() async {
    final status = await Permission.camera.status;
    if (status.isGranted || status.isLimited) {
      return ScannerPermissionKind.granted;
    }
    if (status.isPermanentlyDenied || status.isRestricted) {
      return ScannerPermissionKind.permanentlyDenied;
    }
    return ScannerPermissionKind.denied;
  }

  Future<ScannerPermissionKind> _requestPermissionPlatform() async {
    final status = await Permission.camera.request();
    if (status.isGranted || status.isLimited) {
      return ScannerPermissionKind.granted;
    }
    if (status.isPermanentlyDenied || status.isRestricted) {
      return ScannerPermissionKind.permanentlyDenied;
    }
    return ScannerPermissionKind.denied;
  }

  Future<void> _requestPermission() async {
    if (_state == ScannerFlowState.preparing) return;
    setState(() => _state = ScannerFlowState.preparing);
    final permission =
        await (widget.permissionRequester?.call() ??
            _requestPermissionPlatform());
    if (!mounted) return;
    if (permission == ScannerPermissionKind.granted) {
      setState(() {
        _permanentlyDenied = false;
        _state = ScannerFlowState.ready;
      });
      return;
    }
    setState(() {
      _permanentlyDenied =
          permission == ScannerPermissionKind.permanentlyDenied;
      _state = permission == ScannerPermissionKind.unavailable
          ? ScannerFlowState.unavailable
          : ScannerFlowState.permissionDenied;
    });
  }

  Future<void> _openSettings() async {
    if (widget.permissionRequester != null) {
      await _requestPermission();
      return;
    }
    await openAppSettings();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_busy ||
        !const {
          ScannerFlowState.ready,
          ScannerFlowState.locating,
        }.contains(_state)) {
      return;
    }
    for (final barcode in capture.barcodes) {
      final code = _normalize(barcode.rawValue ?? '');
      if (!_validBarcode(code)) continue;
      unawaited(_acceptCode(code, _rectForBarcode(barcode, capture.size)));
      return;
    }
  }

  Rect? _rectForBarcode(Barcode barcode, Size captureSize) {
    if (barcode.corners.isEmpty || captureSize.isEmpty) return null;
    var left = barcode.corners.first.dx;
    var right = left;
    var top = barcode.corners.first.dy;
    var bottom = top;
    for (final point in barcode.corners.skip(1)) {
      left = mathMin(left, point.dx);
      right = mathMax(right, point.dx);
      top = mathMin(top, point.dy);
      bottom = mathMax(bottom, point.dy);
    }
    return Rect.fromLTRB(
      (left / captureSize.width).clamp(0.0, 1.0),
      (top / captureSize.height).clamp(0.0, 1.0),
      (right / captureSize.width).clamp(0.0, 1.0),
      (bottom / captureSize.height).clamp(0.0, 1.0),
    );
  }

  Future<void> _acceptCode(
    String code,
    Rect? rect, {
    bool force = false,
  }) async {
    final now = DateTime.now();
    if (!force &&
        _lastCode == code &&
        _lastReadAt != null &&
        now.difference(_lastReadAt!) < const Duration(seconds: 2)) {
      return;
    }
    if (_busy) return;
    _busy = true;
    _lastCode = code;
    _lastReadAt = now;
    _code = code;
    _lockRect = rect;
    _product = null;
    setState(() => _state = ScannerFlowState.locked);
    unawaited(HapticFeedback.selectionClick());
    await Future<void>.delayed(
      _reduceMotion ? Duration.zero : const Duration(milliseconds: 120),
    );
    if (!mounted) return;
    setState(() => _state = ScannerFlowState.confirmed);
    unawaited(HapticFeedback.mediumImpact());
    if (_reduceMotion) {
      _barcodeMotion.value = 1;
    } else {
      unawaited(_barcodeMotion.forward(from: 0));
    }
    if (_usesRealCamera) unawaited(_safeStopCamera());
    unawaited(_fetchProduct(code));
  }

  Future<void> _fetchProduct(String code) async {
    final generation = ++_requestGeneration;
    _cancelTimers();
    setState(() {
      _state = ScannerFlowState.fetching;
      _loadingStep = 0;
      _slowLookup = false;
    });
    if (!_reduceMotion) _loadingMotion.repeat();
    _stepTimerOne = Timer(const Duration(milliseconds: 550), () {
      if (mounted &&
          generation == _requestGeneration &&
          _state == ScannerFlowState.fetching) {
        setState(() => _loadingStep = 1);
      }
    });
    _stepTimerTwo = Timer(const Duration(milliseconds: 1250), () {
      if (mounted &&
          generation == _requestGeneration &&
          _state == ScannerFlowState.fetching) {
        setState(() => _loadingStep = 2);
      }
    });
    _slowTimer = Timer(const Duration(seconds: 7), () {
      if (mounted &&
          generation == _requestGeneration &&
          _state == ScannerFlowState.fetching) {
        setState(() => _slowLookup = true);
      }
    });
    try {
      final product =
          await (widget.productLookup?.call(code) ??
              const ProductService().findByBarcode(code));
      if (!mounted || generation != _requestGeneration) return;
      await (widget.historyWriter?.call(product) ??
          HistoryService().add(product));
      if (!mounted || generation != _requestGeneration) return;
      _cancelTimers();
      _loadingMotion.stop();
      setState(() {
        _product = product;
        _loadingStep = 2;
        _state = ScannerFlowState.success;
      });
      await Future<void>.delayed(
        _reduceMotion ? Duration.zero : const Duration(milliseconds: 240),
      );
      if (!mounted || generation != _requestGeneration) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ProductResultScreen(
            product: product,
            heroTag: 'scanner-product-${product.barcode}',
          ),
        ),
      );
      if (mounted && generation == _requestGeneration) {
        await _resetScanner();
      }
    } on ProductNotFoundException {
      _showLookupError(ScannerFlowState.notFound, generation);
    } on ProductOfflineException {
      _showLookupError(ScannerFlowState.offline, generation);
    } on ProductConnectionException {
      _showLookupError(ScannerFlowState.networkError, generation);
    } on ProductLookupException {
      _showLookupError(ScannerFlowState.networkError, generation);
    } catch (_) {
      _showLookupError(ScannerFlowState.networkError, generation);
    }
  }

  void _showLookupError(ScannerFlowState state, int generation) {
    if (!mounted || generation != _requestGeneration) return;
    _cancelTimers();
    _loadingMotion.stop();
    setState(() {
      _busy = false;
      _state = state;
    });
  }

  Future<void> _resetScanner() async {
    _requestGeneration++;
    _cancelTimers();
    _loadingMotion.stop();
    _barcodeMotion.reset();
    if (!mounted) return;
    setState(() {
      _busy = false;
      _code = '';
      _product = null;
      _lockRect = null;
      _slowLookup = false;
      _loadingStep = 0;
      _state = ScannerFlowState.ready;
    });
    if (_usesRealCamera) await _safeStartCamera();
  }

  Future<void> _retry() async {
    if (_code.isEmpty) {
      await _resetScanner();
      return;
    }
    _busy = false;
    await _acceptCode(_code, _lockRect, force: true);
  }

  Future<void> _cancelLookup() async {
    _requestGeneration++;
    await _resetScanner();
  }

  Future<void> _openManualEntry() async {
    if (_state == ScannerFlowState.fetching) await _cancelLookup();
    if (!mounted) return;
    final code = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: AppColors.petroleumRaised,
      builder: (_) => const ManualBarcodeSheet(),
    );
    if (!mounted || code == null) return;
    _busy = false;
    await _acceptCode(code, null, force: true);
  }

  Future<void> _showHelp() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: AppColors.petroleumRaised,
      builder: (_) => const FractionallySizedBox(
        heightFactor: .9,
        child: ScannerHelpSheet(),
      ),
    );
  }

  Future<void> _toggleTorch() async {
    if (!_usesRealCamera || _state != ScannerFlowState.ready) return;
    try {
      await _controller.toggleTorch();
      if (mounted) setState(() => _torchOn = !_torchOn);
    } catch (_) {}
  }

  Future<void> _switchCamera() async {
    if (!_usesRealCamera || _state != ScannerFlowState.ready) return;
    try {
      await _controller.switchCamera();
    } catch (_) {}
  }

  Future<void> _safeStartCamera() async {
    try {
      await _controller.start();
    } catch (_) {}
  }

  Future<void> _safeStopCamera() async {
    try {
      await _controller.stop();
    } catch (_) {}
  }

  void _cameraError(MobileScannerException error) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (error.errorCode == MobileScannerErrorCode.permissionDenied) {
        setState(() => _state = ScannerFlowState.permissionDenied);
      } else {
        final detail = error.errorDetails?.message?.toLowerCase() ?? '';
        setState(() {
          _cameraUnavailableReason =
              detail.contains('in use') || detail.contains('busy')
              ? 'A câmera está em uso por outro aplicativo.'
              : null;
          _state = ScannerFlowState.unavailable;
        });
      }
    });
  }

  void _back() {
    if (Navigator.of(context).canPop()) Navigator.of(context).pop();
  }

  Widget _cameraPreview() {
    if (widget.cameraBuilder != null) {
      return widget.cameraBuilder!(context, _controller, _onDetect);
    }
    return MobileScanner(
      key: const Key('origem-live-camera'),
      controller: _controller,
      onDetect: _onDetect,
      placeholderBuilder: (_, _) => const ScannerPoster(),
      errorBuilder: (_, error, _) {
        _cameraError(error);
        return const ColoredBox(color: AppColors.petroleum);
      },
    );
  }

  (String, String, Color) get _statusCopy => switch (_state) {
    ScannerFlowState.locked => (
      'Código localizado',
      'Mantenha o produto firme',
      const Color(0xFF8CC5FF),
    ),
    ScannerFlowState.confirmed => (
      'Código encontrado',
      'Consultando produto',
      AppColors.apricot,
    ),
    _ => (
      'Aponte para o código de barras',
      'A leitura acontece automaticamente',
      AppColors.mineral,
    ),
  };

  Widget _cameraStage({required bool desktop}) {
    final status = _statusCopy;
    final loading = _state == ScannerFlowState.fetching;
    return ClipRRect(
      borderRadius: BorderRadius.circular(desktop ? 34 : 0),
      child: ColoredBox(
        color: AppColors.petroleum,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _cameraPreview(),
            if (_state == ScannerFlowState.fetching ||
                _state == ScannerFlowState.success)
              ColoredBox(color: AppColors.petroleum.withValues(alpha: .56)),
            IgnorePointer(
              child: OrigemScannerFrame(
                state: _state,
                animation: _barcodeMotion,
                normalizedLockRect: _lockRect,
                code: _code,
              ),
            ),
            if (!loading && _state != ScannerFlowState.success)
              Positioned(
                left: 18,
                right: 18,
                bottom: desktop ? 22 : 102,
                child: Center(
                  child: ScannerStatusMessage(
                    title: status.$1,
                    subtitle: status.$2,
                    accent: status.$3,
                    compact: !desktop,
                  ),
                ),
              ),
            if (loading)
              Positioned.fill(
                child: ScannerLoadingNarrative(
                  step: _loadingStep,
                  barcode: _code,
                  animation: _loadingMotion,
                  delayed: _slowLookup,
                  onCancel: _cancelLookup,
                  onManual: _openManualEntry,
                ),
              ),
            if (_state == ScannerFlowState.success && _product != null)
              Center(
                child: Hero(
                  tag: 'scanner-product-${_product!.barcode}',
                  child: Container(
                    width: 136,
                    height: 136,
                    decoration: BoxDecoration(
                      color: AppColors.mineral,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _product!.imageUrl == null
                        ? const Icon(
                            Icons.inventory_2_outlined,
                            color: AppColors.petroleum,
                            size: 52,
                          )
                        : Image.network(
                            _product!.imageUrl!,
                            fit: BoxFit.contain,
                            errorBuilder: (_, _, _) => const Icon(
                              Icons.inventory_2_outlined,
                              color: AppColors.petroleum,
                              size: 52,
                            ),
                          ),
                  ),
                ),
              ),
            if (!desktop)
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: ScannerControlDock(
                  onBack: widget.showBackButton ? _back : null,
                  onTorch: _toggleTorch,
                  onSwitchCamera: _switchCamera,
                  onManual: _openManualEntry,
                  onHelp: _showHelp,
                  torchOn: _torchOn,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _desktopPanel() => Container(
    width: 340,
    padding: const EdgeInsets.fromLTRB(26, 30, 26, 24),
    color: AppColors.petroleumRaised,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'LENTE NUTRICIONAL',
          style: TextStyle(
            color: AppColors.apricot,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.7,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'O rótulo vira informação.',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 12),
        const Text(
          'Centralize o código. A leitura começa automaticamente e consulta os dados nutricionais do produto.',
          style: TextStyle(color: AppColors.sand, height: 1.5),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.petroleum,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.privacy_tip_outlined, color: AppColors.sage, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'A câmera é usada para identificar o código. Confirme sempre os dados na embalagem.',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        ScannerControlDock(
          desktop: true,
          onBack: widget.showBackButton ? _back : null,
          onTorch: _toggleTorch,
          onSwitchCamera: _switchCamera,
          onManual: _openManualEntry,
          onHelp: _showHelp,
          torchOn: _torchOn,
        ),
      ],
    ),
  );

  Widget _bodyForState(BoxConstraints constraints) {
    if (_state == ScannerFlowState.preparing) return const ScannerPoster();
    if (_state == ScannerFlowState.permissionRequired ||
        _state == ScannerFlowState.permissionDenied) {
      return CameraPermissionState(
        permanentlyDenied: _permanentlyDenied,
        onRequest: _requestPermission,
        onSettings: _permanentlyDenied ? _openSettings : null,
        onManual: _openManualEntry,
        onBack: widget.showBackButton ? _back : null,
      );
    }
    if (const {
      ScannerFlowState.notFound,
      ScannerFlowState.networkError,
      ScannerFlowState.offline,
      ScannerFlowState.unavailable,
    }.contains(_state)) {
      return ScannerErrorState(
        state: _state,
        titleOverride: _cameraUnavailableReason,
        bodyOverride: _cameraUnavailableReason == null
            ? null
            : 'Feche o outro aplicativo ou continue digitando o código manualmente.',
        onRetry: _retry,
        onManual: _openManualEntry,
        onBack: widget.showBackButton ? _back : null,
      );
    }
    final desktop = constraints.maxWidth >= 900;
    if (!desktop) return _cameraStage(desktop: false);
    return Padding(
      padding: const EdgeInsets.all(22),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Row(
            children: [
              Expanded(child: _cameraStage(desktop: true)),
              const SizedBox(width: 16),
              _desktopPanel(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.petroleum,
    body: SafeArea(
      child: FadeTransition(
        opacity: CurvedAnimation(parent: _entrance, curve: Curves.easeOutCubic),
        child: LayoutBuilder(
          builder: (context, constraints) => _bodyForState(constraints),
        ),
      ),
    ),
  );

  void _cancelTimers() {
    _stepTimerOne?.cancel();
    _stepTimerTwo?.cancel();
    _slowTimer?.cancel();
    _stepTimerOne = null;
    _stepTimerTwo = null;
    _slowTimer = null;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _requestGeneration++;
    _cancelTimers();
    _entrance.dispose();
    _barcodeMotion.dispose();
    _loadingMotion.dispose();
    _controller.dispose();
    super.dispose();
  }
}

String _normalize(String value) => value.replaceAll(RegExp(r'\D'), '');
bool _validBarcode(String value) => value.length >= 8 && value.length <= 14;
double mathMin(double a, double b) => a < b ? a : b;
double mathMax(double a, double b) => a > b ? a : b;
