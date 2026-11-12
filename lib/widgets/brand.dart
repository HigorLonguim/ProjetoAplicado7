import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_theme.dart';

class OrigemMark extends StatelessWidget {
  const OrigemMark({super.key, this.size = 64});
  final double size;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(size * .24),
    child: Image.asset(
      'assets/brand/origem_barcode_logo_transparent.png',
      width: size,
      height: size,
      fit: BoxFit.cover,
      semanticLabel: 'Símbolo do Origem',
    ),
  );
}

class OrigemSecondaryWordmark extends StatelessWidget {
  const OrigemSecondaryWordmark({super.key, this.width, this.height = 48});

  final double? width;
  final double height;

  @override
  Widget build(BuildContext context) => Semantics(
    image: true,
    label: 'Origem',
    child: SizedBox(
      width: width ?? height * 3.25,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            top: 0,
            width: height * .62,
            height: height * .62,
            child: SvgPicture.asset(
              'assets/brand/origem_leaf.svg',
              excludeFromSemantics: true,
            ),
          ),
          Positioned(
            left: height * .28,
            bottom: -height * .08,
            child: Text(
              'Origem',
              style: TextStyle(
                color: const Color(0xFFE89060),
                fontFamily: 'Georgia',
                fontFamilyFallback: const ['Times New Roman', 'serif'],
                fontSize: height * .8,
                height: 1,
                fontWeight: FontWeight.w600,
                letterSpacing: -height * .045,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.compact = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.orange, AppColors.peach],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: .2),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FilledButton.icon(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 18 : 22,
            vertical: compact ? 13 : 17,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        icon: Icon(icon, size: 20),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
    );
  }
}
