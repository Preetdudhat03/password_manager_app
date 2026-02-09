import 'package:flutter/material.dart';

class BrandLogo extends StatelessWidget {
  final double width;
  final double? height;

  const BrandLogo({
    super.key,
    this.width = 120,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // light theme -> logo4.png
    // dark theme -> logo3.png (Monochrome/White for Dark Mode)
    final assetName = isDark 
        ? 'assets/branding/logo3.png' 
        : 'assets/branding/logo5.png';

    return Image.asset(
      assetName,
      width: width,
      height: height,
      fit: BoxFit.contain,
    );
  }
}
