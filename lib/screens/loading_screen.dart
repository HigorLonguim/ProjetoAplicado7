import 'dart:async';

import 'package:flutter/material.dart';

import '../services/history_service.dart';
import '../services/product_service.dart';
import '../theme/app_theme.dart';
import '../widgets/origem_scanner.dart';
import 'product_result_screen.dart';

/// Compatibility route for callers outside the scanner. The primary scanner
/// now performs this same narrative in place so camera state is preserved.
class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key, required this.barcode});
  final String barcode;

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motion;
  ScannerFlowState _state = ScannerFlowState.fetching;
  int _step = 0;
  bool _delayed = false;
  int _generation = 0;
  Timer? _secondStep;
  Timer? _thirdStep;
  Timer? _slow;

  @override
  void initState() {
    super.initState();
    _motion = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetch());
  }

  Future<void> _fetch() async {
    final generation = ++_generation;
    _cancelTimers();
    setState(() {
      _state = ScannerFlowState.fetching;
      _step = 0;
      _delayed = false;
    });
    if (!MediaQuery.disableAnimationsOf(context)) _motion.repeat();
    _secondStep = Timer(const Duration(milliseconds: 550), () {
      if (mounted && generation == _generation) setState(() => _step = 1);
    });
    _thirdStep = Timer(const Duration(milliseconds: 1250), () {
      if (mounted && generation == _generation) setState(() => _step = 2);
    });
    _slow = Timer(const Duration(seconds: 7), () {
      if (mounted && generation == _generation) setState(() => _delayed = true);
    });
    try {
      final product = await const ProductService().findByBarcode(
        widget.barcode,
      );
      if (!mounted || generation != _generation) return;
      await HistoryService().add(product);
      if (!mounted || generation != _generation) return;
      _cancelTimers();
      _motion.stop();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ProductResultScreen(product: product),
        ),
      );
    } on ProductNotFoundException {
      _fail(ScannerFlowState.notFound, generation);
    } on ProductOfflineException {
      _fail(ScannerFlowState.offline, generation);
    } on ProductConnectionException {
      _fail(ScannerFlowState.networkError, generation);
    }
  }

  void _fail(ScannerFlowState state, int generation) {
    if (!mounted || generation != _generation) return;
    _cancelTimers();
    _motion.stop();
    setState(() => _state = state);
  }

  void _cancel() {
    _generation++;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.petroleum,
    body: SafeArea(
      child: _state == ScannerFlowState.fetching
          ? ScannerLoadingNarrative(
              step: _step,
              barcode: widget.barcode,
              animation: _motion,
              delayed: _delayed,
              onCancel: _cancel,
              onManual: _cancel,
            )
          : ScannerErrorState(
              state: _state,
              onRetry: _fetch,
              onManual: _cancel,
              onBack: _cancel,
            ),
    ),
  );

  void _cancelTimers() {
    _secondStep?.cancel();
    _thirdStep?.cancel();
    _slow?.cancel();
  }

  @override
  void dispose() {
    _generation++;
    _cancelTimers();
    _motion.dispose();
    super.dispose();
  }
}
