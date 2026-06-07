import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';
import 'product_result_screen.dart';

class LoadingScreen extends StatefulWidget {
  final String barcode;
  const LoadingScreen({super.key, required this.barcode});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    _fetchProductData();
  }

  Future<void> _fetchProductData() async {
    try {
      final url = Uri.parse(
        'https://world.openfoodfacts.org/api/v2/product/${widget.barcode}.json',
      );
      
      // Adicionar timeout de 15 segundos
      final response = await http.get(url).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception(
          'Timeout ao consultar servidor. Tente novamente.',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 1) {
          final product = ProductModel.fromJson(data);
          
          if (!mounted) return;
          
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => ProductResultScreen(product: product),
            ),
          );
        } else {
          _showError(
            'Produto não encontrado na base de dados.\n\nVerifique se o código de barras está correto.',
          );
        }
      } else {
        _showError(
          'Erro ao consultar servidor (${response.statusCode}).\nTente novamente mais tarde.',
        );
      }
    } on Exception catch (e) {
      _showError(
        'Erro de conexão: ${e.toString().replaceAll('Exception: ', '')}\n\nVerifique sua internet.',
      );
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Ops!'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Fecha o diálogo
              Navigator.of(context).pop(); // Volta para o scanner
            },
            child: const Text('Voltar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Buscando'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 74,
                height: 74,
                child: CircularProgressIndicator(
                  strokeWidth: 5,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Buscando informações...',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'Código: ${widget.barcode}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 28),
              const Text('Isso pode levar alguns segundos...'),
            ],
          ),
        ),
      ),
    );
  }
}
