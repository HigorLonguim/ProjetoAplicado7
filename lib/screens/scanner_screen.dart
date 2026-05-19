import 'package:flutter/material.dart';

import 'loading_screen.dart';

class ScannerScreen extends StatelessWidget {
  const ScannerScreen({super.key});

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
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 0.72,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(color: colorScheme.outlineVariant),
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Container(
                              height: 180,
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(28),
                              ),
                              padding: const EdgeInsets.all(18),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    height: 90,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: colorScheme.surface,
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: colorScheme.outlineVariant,
                                      ),
                                    ),
                                    child: const Icon(Icons.barcode_reader, size: 44),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _ScannerFramePainter(color: colorScheme.outlineVariant),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.flash_on_outlined),
                  ),
                  FilledButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const LoadingScreen(),
                        ),
                      );
                    },
                    child: const Text('Simular leitura'),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.image_outlined),
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

    final rect = Rect.fromLTWH(size.width * 0.18, size.height * 0.24, size.width * 0.64, size.height * 0.34);
    const cornerLength = 28.0;

    void drawCorner(Offset start, Offset horizontalEnd, Offset verticalEnd) {
      canvas.drawLine(start, horizontalEnd, paint);
      canvas.drawLine(start, verticalEnd, paint);
    }

    drawCorner(rect.topLeft, rect.topLeft + const Offset(cornerLength, 0), rect.topLeft + const Offset(0, cornerLength));
    drawCorner(rect.topRight, rect.topRight + const Offset(-cornerLength, 0), rect.topRight + const Offset(0, cornerLength));
    drawCorner(rect.bottomLeft, rect.bottomLeft + const Offset(cornerLength, 0), rect.bottomLeft + const Offset(0, -cornerLength));
    drawCorner(rect.bottomRight, rect.bottomRight + const Offset(-cornerLength, 0), rect.bottomRight + const Offset(0, -cornerLength));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}