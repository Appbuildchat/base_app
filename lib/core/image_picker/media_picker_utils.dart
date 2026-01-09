import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:file_picker/file_picker.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../../../core/themes/color_theme.dart';
import '../themes/app_font_weights.dart';
import '../themes/app_theme.dart';
import '../themes/app_shadows.dart';

class ImagePickerConstants {
  static const int maxFiles = 10;
  static const int maxWidth = 1920;
  static const int maxHeight = 1080;
  static const int imageQuality = 85;
  static const Duration maxVideoDuration = Duration(minutes: 5);

  static const List<String> videoExtensions = [
    'mp4',
    'mov',
    'avi',
    'mkv',
    'wmv',
    'flv',
    '3gp',
  ];

  static const List<String> imageExtensions = [
    'jpg',
    'jpeg',
    'png',
    'gif',
    'bmp',
    'webp',
  ];
}

class FileTypeHelper {
  static FileType getFileType(File file) {
    final extension = file.path.toLowerCase().split('.').last;
    if (ImagePickerConstants.imageExtensions.contains(extension)) {
      return FileType.image;
    }
    if (ImagePickerConstants.videoExtensions.contains(extension)) {
      return FileType.video;
    }
    return FileType.any;
  }

  static bool isVideoFile(File file) => getFileType(file) == FileType.video;
  static bool isImageFile(File file) => getFileType(file) == FileType.image;

  static bool isSameFile(File file1, File file2) {
    if (file1.path == file2.path) return true;

    try {
      final file1Name = file1.path.split('/').last;
      final file2Name = file2.path.split('/').last;
      final file1Size = file1.lengthSync();
      final file2Size = file2.lengthSync();
      return file1Name == file2Name && file1Size == file2Size;
    } catch (e) {
      return false;
    }
  }
}

class ImageProcessor {
  static final Logger _logger = Logger();

  static Future<File?> processImageFile(File originalFile) async {
    try {
      final imageBytes = await originalFile.readAsBytes();
      final originalImage = img.decodeImage(imageBytes);
      if (originalImage == null) return originalFile;

      // Resize if needed
      final needsResize =
          originalImage.width > ImagePickerConstants.maxWidth ||
          originalImage.height > ImagePickerConstants.maxHeight;

      final resizedImage = needsResize
          ? img.copyResize(
              originalImage,
              width: originalImage.width > ImagePickerConstants.maxWidth
                  ? ImagePickerConstants.maxWidth
                  : null,
              height: originalImage.height > ImagePickerConstants.maxHeight
                  ? ImagePickerConstants.maxHeight
                  : null,
              maintainAspect: true,
            )
          : originalImage;

      // Compress and save
      final compressedBytes = Uint8List.fromList(
        img.encodeJpg(resizedImage, quality: ImagePickerConstants.imageQuality),
      );

      final fileName = originalFile.path.split('/').last;
      final processedFile = File(
        '${Directory.systemTemp.path}/processed_$fileName',
      );
      await processedFile.writeAsBytes(compressedBytes);

      return processedFile;
    } catch (e) {
      _logger.e('Error processing image: $e');
      return originalFile;
    }
  }
}

class VideoThumbnailHelper {
  static final Map<String, Uint8List?> _cache = {};
  static final Logger _logger = Logger();

  static Future<Uint8List?> generateThumbnail(File videoFile) async {
    try {
      final filePath = videoFile.path;
      if (_cache.containsKey(filePath)) {
        return _cache[filePath];
      }

      final thumbnail = await VideoThumbnail.thumbnailData(
        video: filePath,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 300,
        quality: 75,
      );

      _cache[filePath] = thumbnail;
      return thumbnail;
    } catch (e) {
      _logger.e('Error generating video thumbnail: $e');
      return null;
    }
  }

  static void removeThumbnail(String filePath) {
    _cache.remove(filePath);
  }

  static void clearCache() {
    _cache.clear();
  }

  static Widget buildVideoThumbnail(File file, double size) {
    return FutureBuilder<Uint8List?>(
      future: generateThumbnail(file),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return _buildThumbnailWithOverlay(snapshot.data!, size);
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingContainer(size);
        } else {
          return _buildErrorContainer(size);
        }
      },
    );
  }

  static Widget _buildThumbnailWithOverlay(
    Uint8List thumbnailData,
    double size,
  ) {
    return Stack(
      children: [
        Image.memory(
          thumbnailData,
          fit: BoxFit.cover,
          width: size,
          height: size,
        ),
        _buildPlayIcon(size),
        _buildVideoLabel(),
      ],
    );
  }

  static Widget _buildPlayIcon(double size) {
    return Positioned(
      top: (size - 30) / 2,
      left: (size - 30) / 2,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: AppCommonColors.black.withValues(alpha: 0.5),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.play_arrow,
          color: AppCommonColors.white,
          size: 20,
        ),
      ),
    );
  }

  static Widget _buildVideoLabel() {
    return Positioned(
      bottom: 4,
      left: 4,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          color: AppCommonColors.black.withValues(alpha: 0.54),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Text(
          'VIDEO',
          style: TextStyle(
            color: AppCommonColors.white,
            fontSize: 8,
            fontWeight: AppFontWeights.bold,
          ),
        ),
      ),
    );
  }

  static Widget _buildLoadingContainer(double size) {
    return Container(
      width: size,
      height: size,
      color: AppCommonColors.grey300,
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  static Widget _buildErrorContainer(double size) {
    return Container(
      width: size,
      height: size,
      color: AppCommonColors.black.withValues(alpha: 0.87),
      child: const Icon(Icons.videocam, color: AppCommonColors.white, size: 30),
    );
  }
}

class MediaThumbnailHelper {
  static Widget buildMediaThumbnail({
    required File file,
    required double size,
    required VoidCallback onRemove,
  }) {
    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: AppCommonColors.grey400, width: 1.0),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(7.0),
            child: FileTypeHelper.isVideoFile(file)
                ? VideoThumbnailHelper.buildVideoThumbnail(file, size)
                : Image.file(file, fit: BoxFit.cover),
          ),
        ),
        _buildRemoveButton(onRemove),
      ],
    );
  }

  static Widget buildNetworkImageThumbnail({
    required String url,
    required double size,
    required VoidCallback onRemove,
  }) {
    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: AppCommonColors.grey400, width: 1.0),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(7.0),
            child: Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: AppCommonColors.grey300,
                child: const Icon(
                  Icons.broken_image,
                  color: AppCommonColors.grey500,
                ),
              ),
            ),
          ),
        ),
        _buildRemoveButton(onRemove),
      ],
    );
  }

  static Widget _buildRemoveButton(VoidCallback onRemove) {
    return Positioned(
      top: 0,
      right: 0,
      child: GestureDetector(
        onTap: onRemove,
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.accent,
            shape: BoxShape.circle,
            border: Border.all(color: AppCommonColors.white, width: 2),
            boxShadow: AppShadows.button,
          ),
          child: const Icon(
            Icons.close,
            color: AppCommonColors.white,
            size: 16,
          ),
        ),
      ),
    );
  }
}
