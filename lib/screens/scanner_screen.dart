import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'loading_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> with WidgetsBindingObserver {
  CameraController? _cameraController;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Se o controller não estiver inicializado, não faz nada
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _cameraController?.dispose();
      _cameraController = null;
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    // Se já existir um controller, vamos dar dispose antes de criar um novo
    if (_cameraController != null) {
      await _cameraController!.dispose();
      _cameraController = null;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final cameraPermission = await Permission.camera.request();

    if (!mounted) {
      return;
    }

    if (cameraPermission.isDenied || cameraPermission.isPermanentlyDenied) {
      setState(() {
        _isLoading = false;
        _errorMessage =
            'Permissão da câmera negada. Ative a câmera nas configurações do app.';
      });
      return;
    }

    try {
      final cameras = await availableCameras();
      final backCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await controller.initialize();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _cameraController = controller;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage = 'Não foi possível abrir a câmera: $error';
      });
    }
  }

  Future<void> _toggleFlash() async {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    try {
      await controller.setFlashMode(
        controller.value.flashMode == FlashMode.torch
            ? FlashMode.off
            : FlashMode.torch,
      );
      setState(() {});
    } catch (_) {}
  }

  Widget _buildPreview(BuildContext context, ColorScheme colorScheme) {
    final controller = _cameraController;

    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Abrindo câmera...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: colorScheme.error),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _initializeCamera,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    if (controller == null || !controller.value.isInitialized) {
      return Center(
        child: Text(
          'Câmera indisponível.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: CameraPreview(controller),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _ScannerFramePainter(color: colorScheme.primary),
            ),
          ),
        ),
      ],
    );
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
        child: Padding(
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
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: _buildPreview(context, colorScheme),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: _toggleFlash,
                    icon: const Icon(Icons.flash_on_outlined),
                  ),
                  FilledButton(
                    onPressed: () async {
                      // Ao navegar, esperamos o retorno para re-inicializar a câmera
                      // Isso garante que ela "destrave" caso o sistema tenha suspendido o recurso
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const LoadingScreen(),
                        ),
                      );

                      if (mounted) {
                        _initializeCamera();
                      }
                    },
                    child: const Text('Simular leitura'),
                  ),
                  IconButton(
                    onPressed: _initializeCamera,
                    icon: const Icon(Icons.refresh_outlined),
                  ),
                ],
              ),
            ],
          ),
        ),
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
      ..strokeWidth = 2.5;

    final rect = Rect.fromLTWH(
      size.width * 0.18,
      size.height * 0.24,
      size.width * 0.64,
      size.height * 0.34,
    );
    const cornerLength = 28.0;

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
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
