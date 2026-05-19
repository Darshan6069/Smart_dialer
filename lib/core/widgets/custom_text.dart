import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  final String text;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final double? height;
  final bool isGradient;
  final Gradient? gradient;

  const CustomText(
    this.text, {
    super.key,
    this.fontSize,
    this.fontWeight,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.height,
    this.isGradient = false,
    this.gradient,
  });

  // Factory methods for quick semantic typography
  factory CustomText.heading1(
    String text, {
    Color? color,
    TextAlign? textAlign,
  }) {
    return CustomText(
      text,
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: color,
      textAlign: textAlign,
    );
  }

  factory CustomText.heading2(
    String text, {
    Color? color,
    TextAlign? textAlign,
  }) {
    return CustomText(
      text,
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: color,
      textAlign: textAlign,
    );
  }

  factory CustomText.title(
    String text, {
    Color? color,
    TextAlign? textAlign,
    FontWeight? fontWeight,
    double? fontSize,
  }) {
    return CustomText(
      text,
      fontSize: fontSize ?? 18,
      fontWeight: fontWeight ?? FontWeight.w600,
      color: color,
      textAlign: textAlign,
    );
  }

  factory CustomText.body(
    String text, {
    Color? color,
    TextAlign? textAlign,
    int? maxLines,
    double? fontSize,
    FontWeight? fontWeight,
  }) {
    return CustomText(
      text,
      fontSize: fontSize ?? 14,
      fontWeight: fontWeight,
      color: color,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: maxLines != null ? TextOverflow.ellipsis : null,
    );
  }

  factory CustomText.muted(
    String text, {
    Color? color,
    TextAlign? textAlign,
    int? maxLines,
    double? fontSize,
    FontWeight? fontWeight,
  }) {
    return CustomText(
      text,
      fontSize: fontSize ?? 12,
      fontWeight: fontWeight ?? FontWeight.w400,
      color: color ?? const Color(0xFF8F9BB3),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: maxLines != null ? TextOverflow.ellipsis : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: isGradient ? Colors.white : color,
      // textAlign: textAlign,
      height: height,
    );

    if (isGradient) {
      final baseGradient =
          gradient ??
          const LinearGradient(colors: [Color(0xFF2962FF), Color(0xFF00B0FF)]);
      return ShaderMask(
        shaderCallback: (bounds) => baseGradient.createShader(
          Rect.fromLTWH(0, 0, bounds.width, bounds.height),
        ),
        child: Text(
          text,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
          style: style,
        ),
      );
    }

    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: Theme.of(context).textTheme.bodyMedium?.merge(style),
    );
  }
}
