import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class GiveawayImage extends StatelessWidget {
  const GiveawayImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.contain,
    this.width,
    this.height,
    this.placeholder = const Center(
      child: CircularProgressIndicator(strokeWidth: 2),
    ),
    this.errorWidget = const Center(
      child: Icon(Icons.broken_image, size: 40),
    ),
  });

  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget placeholder;
  final Widget errorWidget;

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Image.network(
        imageUrl,
        fit: fit,
        width: width,
        height: height,
        webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
        loadingBuilder: (_, child, progress) =>
            progress == null ? child : placeholder,
        errorBuilder: (_, _, _) => errorWidget,
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      width: width,
      height: height,
      placeholder: (_, _) => placeholder,
      errorWidget: (_, _, _) => errorWidget,
    );
  }
}
