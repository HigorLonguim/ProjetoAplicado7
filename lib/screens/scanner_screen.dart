import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import 'loading_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> with WidgetsBindingObserver {
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
    setState(() {
      _hasPermission = status.isGranted;
      _isLoading = false;
    });
    if (status.isGranted) {
      _controller.start();
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
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => LoadingScreen(barcode: code),
          ),
        );

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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Escaneie o código de barras'),
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
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt_outlined, size: 64, color: colorScheme.error),
            const SizedBox(height: 16),
            const Text(
              'Permissão da câmera é necessária para escanear os produtos.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _checkPermission,
              child: const Text('Dar permissão'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanner(BuildContext context, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            'Centralize o código na moldura',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: AspectRatio(
              aspectRatio: 0.72,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: Stack(
                    children: [
                      MobileScanner(
                        controller: _controller,
                        onDetect: _onDetect,
                      ),
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _ScannerFramePainter(color: colorScheme.primary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton.filledTonal(
                onPressed: () => _controller.toggleTorch(),
                icon: const Icon(Icons.flash_on),
              ),
              IconButton.filledTonal(
                onPressed: () => _controller.switchCamera(),
                icon: const Icon(Icons.flip_camera_ios),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScannerFramePainter extends CustomPainter {
  _ScannerFramePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
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

    drawCorner(rect.topLeft, rect.topLeft + const Offset(cornerLength, 0),
        rect.topLeft + const Offset(0, cornerLength));
    drawCorner(rect.topRight, rect.topRight + const Offset(-cornerLength, 0),
        rect.topRight + const Offset(0, cornerLength));
    drawCorner(rect.bottomLeft, rect.bottomLeft + const Offset(cornerLength, 0),
        rect.bottomLeft + const Offset(0, -cornerLength));
    drawCorner(rect.bottomRight, rect.bottomRight + const Offset(-cornerLength, 0),
        rect.bottomRight + const Offset(0, -cornerLength));
    
    // Linha de scan animada (estática por enquanto)
    final scanLinePaint = Paint()
      ..color = color.withValues(alpha: 0.5)
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
