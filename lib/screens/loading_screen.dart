import 'package:flutter/material.dart';
import '../services/history_service.dart';
import '../services/product_service.dart';
import '../theme/app_theme.dart';
import '../widgets/brand.dart';
import 'product_result_screen.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key, required this.barcode});
  final String barcode;
  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  String? _error;
  @override
  void initState() { super.initState(); _fetch(); }

  Future<void> _fetch() async {
    setState(() => _error = null);
    try {
      final product = await const ProductService().findByBarcode(widget.barcode);
      await HistoryService().add(product);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => ProductResultScreen(product: product)));
    } on ProductLookupException catch (error) {
      if (mounted) setState(() => _error = error.message);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(leading: const BackButton(), title: const Text('Consultar produto')),
    body: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 430), child: Padding(
      padding: const EdgeInsets.all(28),
      child: _error == null
        ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const OrigemMark(size: 88), const SizedBox(height: 28),
            const CircularProgressIndicator(color: AppColors.terracotta), const SizedBox(height: 24),
            Text('Lendo o rótulo', style: Theme.of(context).textTheme.headlineSmall), const SizedBox(height: 8),
            Text('Código ${widget.barcode}', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ])
        : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.cloud_off_rounded, size: 66, color: AppColors.terracotta), const SizedBox(height: 20),
            Text('Não conseguimos concluir', style: Theme.of(context).textTheme.headlineSmall), const SizedBox(height: 12),
            Text(_error!, textAlign: TextAlign.center), const SizedBox(height: 24),
            GradientButton(label: 'Tentar novamente', icon: Icons.refresh_rounded, onPressed: _fetch),
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Voltar ao scanner')),
          ]),
    ))),
  );
}
