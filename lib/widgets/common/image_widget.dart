import 'package:flutter/material.dart';

class ImageWidget extends StatelessWidget {
  final String? imageUrl;

  final double? width;
  final double? height;

  const ImageWidget({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return imageUrl?.isNotEmpty == true
        ? Image.network(
            imageUrl!,
            fit: BoxFit.cover,
            width: width,
            height: height,
            errorBuilder: (context, error, stackTrace) {
              // Fallback to icon if image fails to load
              return Container(
                color: Colors.grey[300],
                child: Icon(Icons.local_bar, size: 80, color: Colors.grey[600]),
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: Colors.grey[300],
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                ),
              );
            },
          )
        : Container(
            color: Colors.grey[300],
            width: width,
            height: height,
            child: Icon(
              Icons.local_bar,
              size: width ?? 80,
              color: Colors.grey[600],
            ),
          );
  }
}
