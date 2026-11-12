import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';

enum ScannerFlowState {
  preparing,
  permissionRequired,
  permissionDenied,
  ready,
  locating,
  locked,
  confirmed,
  fetching,
  success,
  notFound,
  networkError,
  offline,
  unavailable,
}

enum ScannerPermissionKind { granted, denied, permanentlyDenied, unavailable }

class ScannerStatusMessage extends StatelessWidget {
  const ScannerStatusMessage({
    super.key,
    required this.title,
    required this.subtitle,
    this.accent = AppColors.mineral,
    this.compact = false,
  });

  final String title;
  final String subtitle;
  final Color accent;
  final bool compact;

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    label: '$title. $subtitle',
    child: Container(
      constraints: const BoxConstraints(maxWidth: 520),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 14 : 18,
        vertical: compact ? 11 : 14,
      ),
      decoration: BoxDecoration(
        color: AppColors.petroleum.withValues(alpha: .86),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: .38)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x55000000),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: TextStyle(
              color: accent,
              fontSize: compact ? 14 : 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.sand,
              fontSize: 12,
              height: 1.35,
            ),
          ),
        ],
      ),
    ),
  );
}

class OrigemScannerFrame extends StatelessWidget {
  const OrigemScannerFrame({
    super.key,
    required this.state,
    required this.animation,
    this.normalizedLockRect,
    this.code = '',
  });

  final ScannerFlowState state;
  final Animation<double> animation;
  final Rect? normalizedLockRect;
  final String code;

  bool get _locked => const {
    ScannerFlowState.locked,
    ScannerFlowState.confirmed,
    ScannerFlowState.fetching,
    ScannerFlowState.success,
  }.contains(state);

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final size = constraints.biggest;
      final fallback = Rect.fromCenter(
        center: size.center(Offset.zero),
        width: math.min(size.width * .76, 520),
        height: math.min(size.height * .26, 190),
      );
      final normalized = normalizedLockRect;
      Rect target = fallback;
      if (_locked && normalized != null) {
        final mapped = Rect.fromLTRB(
          normalized.left * size.width,
          normalized.top * size.height,
          normalized.right * size.width,
          normalized.bottom * size.height,
        ).inflate(22);
        final safe = Rect.fromLTWH(16, 70, size.width - 32, size.height - 180);
        target = mapped.intersect(safe);
        if (target.width < 150 || target.height < 70) target = fallback;
      }
      final color = _locked ? const Color(0xFF8CC5FF) : AppColors.sage;
      return Stack(
        fit: StackFit.expand,
        children: [
          AnimatedPositioned.fromRect(
            rect: target,
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                ScannerCornerSegment(
                  alignment: Alignment.topLeft,
                  color: color,
                ),
                ScannerCornerSegment(
                  alignment: Alignment.topRight,
                  color: color,
                ),
                ScannerCornerSegment(
                  alignment: Alignment.bottomLeft,
                  color: color,
                ),
                ScannerCornerSegment(
                  alignment: Alignment.bottomRight,
                  color: color,
                ),
              ],
            ),
          ),
          AnimatedBuilder(
            animation: animation,
            builder: (context, _) => RepaintBoundary(
              child: CustomPaint(
                painter: BarcodeLockOverlayPainter(
                  focusRect: target,
                  state: state,
                  progress: animation.value,
                ),
              ),
            ),
          ),
          if (state == ScannerFlowState.fetching ||
              state == ScannerFlowState.success)
            AnimatedBuilder(
              animation: animation,
              builder: (context, _) => RepaintBoundary(
                child: CustomPaint(
                  painter: BarcodeTransformationPainter(
                    focusRect: target,
                    progress: animation.value,
                    seed: code.hashCode,
                  ),
                ),
              ),
            ),
        ],
      );
    },
  );
}

class ScannerCornerSegment extends StatelessWidget {
  const ScannerCornerSegment({
    super.key,
    required this.alignment,
    required this.color,
  });

  final Alignment alignment;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final left = alignment.x < 0;
    final top = alignment.y < 0;
    return Align(
      alignment: alignment,
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.diagonal3Values(left ? 1 : -1, top ? 1 : -1, 1),
        child: CustomPaint(
          size: const Size(58, 58),
          painter: _CornerPainter(color),
        ),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  const _CornerPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final main = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(0, 36)
      ..lineTo(0, 8)
      ..quadraticBezierTo(0, 0, 8, 0)
      ..lineTo(38, 0);
    canvas.drawPath(path, main);
    final bars = Paint()..color = color.withValues(alpha: .72);
    for (var i = 0; i < 4; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(11 + i * 7, 8, i.isEven ? 2 : 4, 10 + i * 3),
          const Radius.circular(2),
        ),
        bars,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CornerPainter oldDelegate) =>
      oldDelegate.color != color;
}

class BarcodeLockOverlayPainter extends CustomPainter {
  const BarcodeLockOverlayPainter({
    required this.focusRect,
    required this.state,
    required this.progress,
  });

  final Rect focusRect;
  final ScannerFlowState state;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final locked = const {
      ScannerFlowState.locked,
      ScannerFlowState.confirmed,
      ScannerFlowState.fetching,
      ScannerFlowState.success,
    }.contains(state);
    if (locked) {
      final shade = Path()
        ..addRect(Offset.zero & size)
        ..addRRect(
          RRect.fromRectAndRadius(focusRect, const Radius.circular(18)),
        )
        ..fillType = PathFillType.evenOdd;
      canvas.drawPath(
        shade,
        Paint()..color = Colors.black.withValues(alpha: .10),
      );
    }
    if (state == ScannerFlowState.confirmed ||
        state == ScannerFlowState.fetching) {
      final beamProgress = Curves.easeInOutCubic.transform(
        progress.clamp(0, 1),
      );
      final x = focusRect.left + focusRect.width * beamProgress;
      final beam = Paint()
        ..shader =
            LinearGradient(
              colors: [
                Colors.transparent,
                AppColors.apricot.withValues(alpha: .85),
                Colors.transparent,
              ],
            ).createShader(
              Rect.fromLTWH(x - 22, focusRect.top, 44, focusRect.height),
            )
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);
      canvas.drawRect(
        Rect.fromLTWH(x - 22, focusRect.top, 44, focusRect.height),
        beam,
      );
    }
  }

  @override
  bool shouldRepaint(covariant BarcodeLockOverlayPainter oldDelegate) =>
      oldDelegate.focusRect != focusRect ||
      oldDelegate.state != state ||
      oldDelegate.progress != progress;
}

class BarcodeTransformationPainter extends CustomPainter {
  const BarcodeTransformationPainter({
    required this.focusRect,
    required this.progress,
    required this.seed,
  });

  final Rect focusRect;
  final double progress;
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Curves.easeInOutCubic.transform(progress.clamp(0, 1));
    final random = math.Random(seed);
    final center = size.center(Offset.zero);
    for (var i = 0; i < 22; i++) {
      final t = i / 21;
      final start = Offset(
        focusRect.left + focusRect.width * (.08 + .84 * t),
        focusRect.center.dy,
      );
      final angle = math.pi * 2 * t + (i.isEven ? .2 : -.14);
      final radius = 54 + (i % 4) * 17.0;
      final end =
          center +
          Offset(math.cos(angle) * radius, math.sin(angle) * radius * .48);
      final point = Offset.lerp(start, end, p)!;
      final paint = Paint()
        ..color = Color.lerp(
          AppColors.apricot,
          AppColors.sage,
          t,
        )!.withValues(alpha: .24 + .62 * (1 - p * .32))
        ..strokeWidth = 1.2 + random.nextDouble() * 2.2
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        point - Offset(0, 7 + random.nextDouble() * 12),
        point + const Offset(0, 7),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant BarcodeTransformationPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.focusRect != focusRect ||
      oldDelegate.seed != seed;
}

class ScannerControlDock extends StatelessWidget {
  const ScannerControlDock({
    super.key,
    required this.onBack,
    required this.onTorch,
    required this.onSwitchCamera,
    required this.onManual,
    required this.onHelp,
    required this.torchOn,
    this.desktop = false,
  });

  final VoidCallback? onBack;
  final VoidCallback onTorch;
  final VoidCallback onSwitchCamera;
  final VoidCallback onManual;
  final VoidCallback onHelp;
  final bool torchOn;
  final bool desktop;

  @override
  Widget build(BuildContext context) {
    final controls = [
      _ScannerAction(
        icon: Icons.arrow_back_rounded,
        label: 'Voltar',
        onTap: onBack,
      ),
      _ScannerAction(
        icon: torchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
        label: torchOn ? 'Lanterna ligada' : 'Lanterna',
        onTap: onTorch,
        active: torchOn,
      ),
      _ScannerAction(
        icon: Icons.flip_camera_ios_outlined,
        label: 'Trocar câmera',
        onTap: onSwitchCamera,
      ),
      _ScannerAction(
        icon: Icons.keyboard_alt_outlined,
        label: 'Digitar código',
        onTap: onManual,
      ),
      _ScannerAction(
        icon: Icons.help_outline_rounded,
        label: 'Como escanear',
        onTap: onHelp,
      ),
    ];
    if (desktop) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final control in controls)
            Padding(padding: const EdgeInsets.only(bottom: 8), child: control),
        ],
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.petroleum.withValues(alpha: .88),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [for (final control in controls) Expanded(child: control)],
      ),
    );
  }
}

class _ScannerAction extends StatelessWidget {
  const _ScannerAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 900;
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: label,
      child: Tooltip(
        message: label,
        child: Material(
          color: active
              ? AppColors.warmYellow.withValues(alpha: .18)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            focusColor: AppColors.warmYellow.withValues(alpha: .22),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 52, minWidth: 48),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
                child: desktop
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            icon,
                            size: 21,
                            color: active
                                ? AppColors.warmYellow
                                : AppColors.mineral,
                          ),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            icon,
                            size: 20,
                            color: active
                                ? AppColors.warmYellow
                                : AppColors.mineral,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  fontSize: 9,
                                  height: 1,
                                  color: AppColors.mineral,
                                ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CameraPermissionState extends StatelessWidget {
  const CameraPermissionState({
    super.key,
    required this.permanentlyDenied,
    required this.onRequest,
    required this.onManual,
    required this.onBack,
    this.onSettings,
  });

  final bool permanentlyDenied;
  final VoidCallback onRequest;
  final VoidCallback onManual;
  final VoidCallback? onBack;
  final VoidCallback? onSettings;

  @override
  Widget build(BuildContext context) => _ScannerSurface(
    icon: Icons.camera_alt_outlined,
    accent: AppColors.sage,
    title: permanentlyDenied
        ? 'Precisamos da câmera para ler o código'
        : 'Use a câmera para encontrar o código',
    body: permanentlyDenied
        ? 'O acesso está bloqueado. Você pode abrir as configurações ou continuar digitando o código.'
        : 'A câmera identifica somente o código de barras. A alternativa manual está sempre disponível.',
    children: [
      FilledButton.icon(
        key: const Key('scanner-permission-primary'),
        onPressed: permanentlyDenied ? onSettings : onRequest,
        icon: Icon(
          permanentlyDenied
              ? Icons.settings_outlined
              : Icons.camera_alt_rounded,
        ),
        label: Text(
          permanentlyDenied ? 'Abrir configurações' : 'Permitir câmera',
        ),
      ),
      const SizedBox(height: 10),
      OutlinedButton.icon(
        key: const Key('scanner-permission-manual'),
        onPressed: onManual,
        icon: const Icon(Icons.keyboard_alt_outlined),
        label: const Text('Digitar código manualmente'),
      ),
      TextButton(onPressed: onBack, child: const Text('Voltar')),
    ],
  );
}

class ScannerPoster extends StatelessWidget {
  const ScannerPoster({super.key});

  @override
  Widget build(BuildContext context) => const ColoredBox(
    color: AppColors.petroleum,
    child: Center(
      child: _ScannerSurface(
        icon: Icons.center_focus_strong_rounded,
        accent: AppColors.apricot,
        title: 'Preparando a câmera',
        body: 'A lente estará disponível em instantes.',
        children: [],
      ),
    ),
  );
}

class ScannerLoadingNarrative extends StatelessWidget {
  const ScannerLoadingNarrative({
    super.key,
    required this.step,
    required this.barcode,
    required this.animation,
    required this.delayed,
    required this.onCancel,
    required this.onManual,
  });

  final int step;
  final String barcode;
  final Animation<double> animation;
  final bool delayed;
  final VoidCallback onCancel;
  final VoidCallback onManual;

  static const _steps = [
    'Encontrando o produto',
    'Lendo os dados disponíveis',
    'Preparando o resumo',
  ];

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    label: _steps[step.clamp(0, 2)],
    child: _ScannerSurface(
      icon: Icons.document_scanner_outlined,
      accent: AppColors.apricot,
      title: _steps[step.clamp(0, 2)],
      body: delayed
          ? 'A consulta está demorando mais que o normal.'
          : 'Código ${_groupBarcode(barcode)}',
      visual: SizedBox(
        width: 170,
        height: 112,
        child: AnimatedBuilder(
          animation: animation,
          builder: (_, _) =>
              CustomPaint(painter: _LoadingOrbitPainter(animation.value, step)),
        ),
      ),
      children: delayed
          ? [
              OutlinedButton(
                onPressed: onCancel,
                child: const Text('Cancelar consulta'),
              ),
              TextButton.icon(
                onPressed: onManual,
                icon: const Icon(Icons.keyboard_alt_outlined),
                label: const Text('Digitar outro código'),
              ),
            ]
          : const [],
    ),
  );
}

class ScannerErrorState extends StatelessWidget {
  const ScannerErrorState({
    super.key,
    required this.state,
    required this.onRetry,
    required this.onManual,
    required this.onBack,
    this.titleOverride,
    this.bodyOverride,
  });

  final ScannerFlowState state;
  final VoidCallback onRetry;
  final VoidCallback onManual;
  final VoidCallback? onBack;
  final String? titleOverride;
  final String? bodyOverride;

  @override
  Widget build(BuildContext context) {
    final notFound = state == ScannerFlowState.notFound;
    final offline = state == ScannerFlowState.offline;
    final unavailable = state == ScannerFlowState.unavailable;
    final defaultTitle = notFound
        ? 'Este produto ainda não apareceu na nossa fonte.'
        : offline
        ? 'Você está sem conexão.'
        : unavailable
        ? 'A câmera não está disponível.'
        : 'Não foi possível consultar o produto agora.';
    final defaultBody = notFound
        ? 'Confira o código e tente novamente ou digite os números manualmente.'
        : offline
        ? 'A câmera pode identificar o código, mas a consulta depende da internet.'
        : unavailable
        ? 'Use a entrada manual para continuar sem a câmera.'
        : 'Verifique sua conexão e tente novamente.';
    return _ScannerSurface(
      icon: notFound
          ? Icons.barcode_reader
          : unavailable
          ? Icons.no_photography_outlined
          : Icons.cloud_off_outlined,
      accent: AppColors.apricot,
      title: titleOverride ?? defaultTitle,
      body: bodyOverride ?? defaultBody,
      visual: const _BrokenBarcode(),
      children: [
        if (!unavailable)
          FilledButton.icon(
            key: const Key('scanner-error-retry'),
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Tentar novamente'),
          ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          key: const Key('scanner-error-manual'),
          onPressed: onManual,
          icon: const Icon(Icons.keyboard_alt_outlined),
          label: Text(notFound ? 'Digitar código' : 'Digitar outro código'),
        ),
        TextButton(onPressed: onBack, child: const Text('Voltar')),
      ],
    );
  }
}

class _ScannerSurface extends StatelessWidget {
  const _ScannerSurface({
    required this.icon,
    required this.accent,
    required this.title,
    required this.body,
    required this.children,
    this.visual,
  });
  final IconData icon;
  final Color accent;
  final String title;
  final String body;
  final List<Widget> children;
  final Widget? visual;

  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        padding: const EdgeInsets.all(26),
        decoration: BoxDecoration(
          color: AppColors.petroleumRaised.withValues(alpha: .96),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: .14),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: accent.withValues(alpha: .42)),
              ),
              child: Icon(icon, color: accent, size: 30),
            ),
            if (visual != null) ...[const SizedBox(height: 12), visual!],
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            Text(
              body,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.sand),
            ),
            if (children.isNotEmpty) ...[
              const SizedBox(height: 24),
              for (final child in children)
                SizedBox(width: double.infinity, child: child),
            ],
          ],
        ),
      ),
    ),
  );
}

class ManualBarcodeSheet extends StatefulWidget {
  const ManualBarcodeSheet({super.key});

  @override
  State<ManualBarcodeSheet> createState() => _ManualBarcodeSheetState();
}

class _ManualBarcodeSheetState extends State<ManualBarcodeSheet> {
  final _controller = TextEditingController();
  String? _error;

  String get _normalized => _controller.text.replaceAll(RegExp(r'\D'), '');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final code = _normalized;
    if (code.isEmpty) {
      setState(() => _error = 'Digite os números do código de barras.');
      return;
    }
    if (code.length < 8 || code.length > 14) {
      setState(() => _error = 'Use um código entre 8 e 14 números.');
      return;
    }
    Navigator.of(context).pop(code);
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (!mounted) return;
    _controller.text = data?.text ?? '';
    setState(() => _error = null);
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Padding(
      padding: EdgeInsets.fromLTRB(
        22,
        4,
        22,
        22 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Digitar código',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 7),
          const Text(
            'Aceita EAN-8, UPC-A, EAN-13 e códigos compatíveis de 8 a 14 números.',
          ),
          const SizedBox(height: 18),
          TextField(
            key: const Key('manual-barcode-field'),
            controller: _controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.search,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9\s-]')),
            ],
            decoration: InputDecoration(
              labelText: 'Código de barras',
              hintText: '7890 0000 0000 0',
              errorText: _error,
              prefixIcon: const Icon(Icons.barcode_reader),
              suffixIcon: IconButton(
                tooltip: 'Colar código',
                onPressed: _paste,
                icon: const Icon(Icons.content_paste_rounded),
              ),
            ),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            key: const Key('manual-barcode-submit'),
            onPressed: _submit,
            icon: const Icon(Icons.search_rounded),
            label: const Text('Buscar produto'),
          ),
          TextButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.camera_alt_outlined),
            label: const Text('Voltar à câmera'),
          ),
        ],
      ),
    ),
  );
}

class ScannerHelpSheet extends StatelessWidget {
  const ScannerHelpSheet({super.key});

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Como escanear',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: AppColors.mineral,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 104,
                          height: 128,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8DFD0),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.sand),
                          ),
                        ),
                        Positioned(
                          bottom: 25,
                          child: CustomPaint(
                            size: const Size(72, 30),
                            painter: _MiniBarcodePainter(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '• Procure o código no verso ou na lateral da embalagem.',
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• Evite reflexos e mantenha o produto firme por um instante.',
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• Aproxime até o código ocupar parte da moldura, sem preencher toda a câmera.',
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Entendi'),
            ),
          ),
        ],
      ),
    ),
  );
}

class _BrokenBarcode extends StatelessWidget {
  const _BrokenBarcode();
  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: const Size(170, 54), painter: _BrokenBarcodePainter());
}

class _BrokenBarcodePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.muted.withValues(alpha: .58);
    for (var i = 0; i < 21; i++) {
      if (i == 9 || i == 10 || i == 14) continue;
      final width = i.isEven ? 3.0 : 6.0;
      canvas.drawRect(
        Rect.fromLTWH(i * 7.5, i > 12 ? 12 : 4, width, i > 12 ? 30 : 42),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LoadingOrbitPainter extends CustomPainter {
  const _LoadingOrbitPainter(this.progress, this.step);
  final double progress;
  final int step;
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final colors = [AppColors.apricot, const Color(0xFF58A6FF), AppColors.sage];
    for (var i = 0; i < 3; i++) {
      final rect = Rect.fromCenter(
        center: center,
        width: 60 + i * 30,
        height: 28 + i * 15,
      );
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate((progress + i * .21) * math.pi * .28);
      canvas.translate(-center.dx, -center.dy);
      canvas.drawArc(
        rect,
        -math.pi * .72,
        math.pi * (1.05 + .16 * step),
        false,
        Paint()
          ..color = colors[i].withValues(alpha: .82)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _LoadingOrbitPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.step != step;
}

class _MiniBarcodePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.petroleum;
    for (var i = 0; i < 16; i++) {
      final width = i % 3 == 0 ? 3.0 : 1.5;
      canvas.drawRect(Rect.fromLTWH(i * 4.4, 0, width, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

String _groupBarcode(String code) {
  if (code.length <= 4) return code;
  final buffer = StringBuffer();
  for (var i = 0; i < code.length; i++) {
    if (i > 0 && i % 4 == 0) buffer.write(' ');
    buffer.write(code[i]);
  }
  return buffer.toString();
}
