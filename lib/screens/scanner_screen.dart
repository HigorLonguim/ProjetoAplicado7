import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import '../theme/app_theme.dart';
import '../widgets/brand.dart';
import 'loading_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key, this.showBackButton = true});

  final bool showBackButton;

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with WidgetsBindingObserver {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  bool _isScanning = true;
  bool _hasPermission = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _controller.start();
    } else if (state == AppLifecycleState.inactive) {
      _controller.stop();
    }
  }

  Future<void> _checkPermission() async {
    final status = await Permission.camera.request();
    if (mounted) {
      setState(() {
        _hasPermission = status.isGranted;
        _isLoading = false;
      });
    }
  }

  void _onDetect(BarcodeCapture capture) async {
    if (!_isScanning) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String? code = barcodes.first.rawValue;
      if (code != null) {
        setState(() {
          _isScanning = false;
        });

        // Pausa o scanner antes de navegar
        await _controller.stop();

        if (!mounted) return;

        // Navega para a LoadingScreen com o código capturado
        await Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => LoadingScreen(barcode: code)));

        // Ao voltar, reinicia o scanner
        if (mounted) {
          setState(() {
            _isScanning = true;
          });
          _controller.start();
        }
      }
    }
  }

  Future<void> _enterBarcode() async {
    final controller = TextEditingController();
    final code = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          6,
          20,
          20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Digitar código',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text('Use os números impressos abaixo do código de barras.'),
            const SizedBox(height: 18),
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Código de barras',
                prefixIcon: Icon(Icons.numbers_rounded),
              ),
              onSubmitted: (value) => Navigator.pop(context, value),
            ),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('Consultar produto'),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    final normalized = code?.replaceAll(RegExp(r'\D'), '') ?? '';
    if (!mounted || normalized.length < 8) {
      if (mounted && code != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Digite um código com pelo menos 8 números.'),
          ),
        );
      }
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => LoadingScreen(barcode: normalized)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: widget.showBackButton,
        title: const Text('Escanear produto'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : !_hasPermission
            ? _buildPermissionError(colorScheme)
            : _buildScanner(context, colorScheme),
      ),
    );
  }

  Widget _buildPermissionError(ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 460),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.darkSurface, AppColors.border],
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withValues(alpha: .08)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 82,
                height: 82,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.olive, AppColors.forest],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt_outlined,
                  size: 38,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'A câmera precisa de acesso',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Ela será usada somente para ler o código de barras do produto.',
                textAlign: TextAlign.center,
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: GradientButton(
                  label: 'Permitir acesso',
                  icon: Icons.camera_alt_rounded,
                  onPressed: _checkPermission,
                ),
              ),
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: _enterBarcode,
                icon: const Icon(Icons.keyboard_alt_outlined),
                label: const Text('Digitar código manualmente'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScanner(BuildContext context, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 18),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Enquadre e descubra',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Posicione as barras dentro da moldura para consultar o produto.',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: AppColors.olive.withValues(alpha: .7),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .35),
                      blurRadius: 28,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(29),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: MobileScanner(
                          controller: _controller,
                          onDetect: _onDetect,
                        ),
                      ),
                      Positioned.fill(
                        child: ColoredBox(
                          color: AppColors.navy.withValues(alpha: .16),
                        ),
                      ),
                      Positioned.fill(
                        child: CustomPaint(
                          painter: const _ScannerFramePainter(
                            frameColor: AppColors.olive,
                            lineColor: AppColors.peach,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 18,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 13,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.navy.withValues(alpha: .76),
                              borderRadius: BorderRadius.circular(99),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.qr_code_scanner_rounded,
                                  color: AppColors.peach,
                                  size: 17,
                                ),
                                SizedBox(width: 7),
                                Text(
                                  'LEITURA AUTOMÁTICA',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    letterSpacing: .8,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 18,
                        right: 18,
                        bottom: 18,
                        child: Container(
                          padding: const EdgeInsets.all(13),
                          decoration: BoxDecoration(
                            color: AppColors.navy.withValues(alpha: .78),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text(
                            'Mantenha o celular firme e evite reflexos sobre a embalagem.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ScannerControl(
                label: 'Lanterna',
                icon: Icons.flash_on_rounded,
                color: AppColors.olive,
                onTap: () => _controller.toggleTorch(),
              ),
              const SizedBox(width: 12),
              _ScannerControl(
                label: 'Virar câmera',
                icon: Icons.flip_camera_ios_rounded,
                color: AppColors.terracotta,
                onTap: () => _controller.switchCamera(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _enterBarcode,
              icon: const Icon(Icons.keyboard_alt_outlined),
              label: const Text('Digitar código de barras'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.peach,
                side: const BorderSide(color: AppColors.terracotta),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScannerFramePainter extends CustomPainter {
  const _ScannerFramePainter({
    required this.frameColor,
    required this.lineColor,
  });

  final Color frameColor;
  final Color lineColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = frameColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final rect = Rect.fromLTWH(
      size.width * 0.15,
      size.height * 0.3,
      size.width * 0.7,
      size.height * 0.2,
    );
    const cornerLength = 30.0;

    void drawCorner(Offset start, Offset horizontalEnd, Offset verticalEnd) {
      canvas.drawLine(start, horizontalEnd, paint);
      canvas.drawLine(start, verticalEnd, paint);
    }

    drawCorner(
      rect.topLeft,
      rect.topLeft + const Offset(cornerLength, 0),
      rect.topLeft + const Offset(0, cornerLength),
    );
    drawCorner(
      rect.topRight,
      rect.topRight + const Offset(-cornerLength, 0),
      rect.topRight + const Offset(0, cornerLength),
    );
    drawCorner(
      rect.bottomLeft,
      rect.bottomLeft + const Offset(cornerLength, 0),
      rect.bottomLeft + const Offset(0, -cornerLength),
    );
    drawCorner(
      rect.bottomRight,
      rect.bottomRight + const Offset(-cornerLength, 0),
      rect.bottomRight + const Offset(0, -cornerLength),
    );

    // Linha de scan animada (estática por enquanto)
    final scanLinePaint = Paint()
      ..color = lineColor.withValues(alpha: 0.9)
      ..strokeWidth = 2.0;
    canvas.drawLine(
      Offset(rect.left, rect.center.dy),
      Offset(rect.right, rect.center.dy),
      scanLinePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ScannerControl extends StatelessWidget {
  const _ScannerControl({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Expanded(
    child: Material(
      color: color.withValues(alpha: .16),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
