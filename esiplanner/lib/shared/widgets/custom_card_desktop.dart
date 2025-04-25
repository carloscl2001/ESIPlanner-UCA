import 'package:flutter/material.dart';

class CustomCardDesktop extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final bool withShadow;
  final Color? color;
  final Border? border;
  final double? width;
  final double? height;

  const CustomCardDesktop({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(40.0),
    this.borderRadius = 24.0,
    this.withShadow = true,
    this.color,
    this.border,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor = color ?? (isDarkMode ? Colors.grey.shade900 : Colors.white);
    final defaultBorder = border ?? Border.all(
      color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
      width: 1.5,
    );

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: defaultBorder,
        boxShadow: withShadow ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          )
        ] : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

// Ejemplo de uso:
class ExampleCardUsage extends StatelessWidget {
  const ExampleCardUsage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CustomCardDesktop(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.event, size: 80),
            const SizedBox(height: 20),
            Text(
              'Card Title',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'This is an example of the custom card with the style from your code',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Action Button'),
            ),
          ],
        ),
      ),
    );
  }
}