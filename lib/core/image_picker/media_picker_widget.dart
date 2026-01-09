import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart' as picker;
import 'dart:io';
import 'custom_gallery_screen.dart';
import 'media_picker_utils.dart';
import '../themes/app_font_weights.dart';
import '../themes/app_dimensions.dart';

// PickedMedia 클래스 정의
class PickedMedia {
  final File file;
  final String type;

  PickedMedia({required this.file, required this.type});
}

// 콜백에 전달할 결과 타입 정의
class MediaPickerResult {
  final List<PickedMedia> pickedMedia;
  final List<String> networkImageUrls;
  MediaPickerResult({
    required this.pickedMedia,
    required this.networkImageUrls,
  });
}

typedef MediaPickedCallback = void Function(MediaPickerResult result);

class MediaPickerWidget extends StatefulWidget {
  final MediaPickedCallback? onMediaSelected;
  final double size;
  final Color? backgroundColor;
  final Color? iconColor;
  final double iconSize;
  final bool allowVideo;
  final List<String> initialImageUrls;

  const MediaPickerWidget({
    super.key,
    this.onMediaSelected,
    this.size = 60.0,
    this.backgroundColor,
    this.iconColor,
    this.iconSize = 24.0,
    this.allowVideo = false,
    this.initialImageUrls = const [],
  });

  @override
  State<MediaPickerWidget> createState() => _MediaPickerWidgetState();
}

class _MediaPickerWidgetState extends State<MediaPickerWidget> {
  final picker.ImagePicker _picker = picker.ImagePicker();
  final List<PickedMedia> _selectedMedia = [];
  List<String> _networkImageUrls = [];

  @override
  void initState() {
    super.initState();
    _networkImageUrls = List<String>.from(widget.initialImageUrls);
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _notifyCallbacks() {
    widget.onMediaSelected?.call(
      MediaPickerResult(
        pickedMedia: _selectedMedia,
        networkImageUrls: _networkImageUrls,
      ),
    );
  }

  void _updateFiles(List<File> newFiles) {
    final uniqueFiles = <PickedMedia>[];
    final duplicateFiles = <String>[];

    for (File newFile in newFiles) {
      bool isDuplicate =
          _selectedMedia.any(
            (pm) => FileTypeHelper.isSameFile(newFile, pm.file),
          ) ||
          uniqueFiles.any((pm) => FileTypeHelper.isSameFile(newFile, pm.file));
      if (isDuplicate) {
        duplicateFiles.add(newFile.path.split('/').last);
      } else {
        final type = FileTypeHelper.isImageFile(newFile) ? 'image' : 'video';
        uniqueFiles.add(PickedMedia(file: newFile, type: type));
      }
    }

    if (duplicateFiles.isNotEmpty) {
      final message = duplicateFiles.length == 1
          ? 'File "${duplicateFiles.first}" is already selected.'
          : '${duplicateFiles.length} duplicate files were skipped.';
      _showError(message);
    }

    if (uniqueFiles.isNotEmpty) {
      setState(() => _selectedMedia.addAll(uniqueFiles));
    }
    _notifyCallbacks();
  }

  void _handleAddButtonTap() {
    if (_selectedMedia.length >= ImagePickerConstants.maxFiles) {
      _showError(
        'Maximum ${ImagePickerConstants.maxFiles} files already selected. Please remove some files first.',
      );
      return;
    }
    _showMediaSourceDialog();
  }

  void _showMediaSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.allowVideo ? 'Select Media' : 'Select Image'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogOption(
              Icons.perm_media,
              'Select from Gallery',
              _pickMediaFromGallery,
            ),
            _buildDialogOption(
              Icons.camera_alt,
              'Take Photo',
              _pickImageFromCamera,
            ),
            if (widget.allowVideo)
              _buildDialogOption(
                Icons.videocam,
                'Record Video',
                _pickVideoFromCamera,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogOption(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.of(context).pop();
        onTap();
      },
    );
  }

  Future<void> _pickMediaFromGallery() async {
    try {
      final result = await Navigator.of(context, rootNavigator: true)
          .push<List<File>>(
            MaterialPageRoute(
              builder: (context) => CustomGalleryScreen(
                selectedFiles: _selectedMedia.map((pm) => pm.file).toList(),
                allowVideo: widget.allowVideo,
                maxFiles: ImagePickerConstants.maxFiles,
              ),
            ),
          );

      if (result == null || result.isEmpty) return;

      final availableSlots =
          ImagePickerConstants.maxFiles - _selectedMedia.length;
      List<File> mediaFiles = result;

      if (mediaFiles.length > availableSlots) {
        mediaFiles = mediaFiles.take(availableSlots).toList();
        _showError(
          'Maximum ${ImagePickerConstants.maxFiles} files allowed. Only ${mediaFiles.length} files were added.',
        );
      }

      final processedFiles = await Future.wait(
        mediaFiles.map(
          (file) => FileTypeHelper.isImageFile(file)
              ? ImageProcessor.processImageFile(file)
              : Future.value(file),
        ),
      );

      _updateFiles(processedFiles.whereType<File>().toList());
    } catch (e) {
      _showError('An error occurred while selecting media from gallery: $e');
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final image = await _picker.pickImage(
        source: picker.ImageSource.camera,
        maxWidth: ImagePickerConstants.maxWidth.toDouble(),
        maxHeight: ImagePickerConstants.maxHeight.toDouble(),
        imageQuality: ImagePickerConstants.imageQuality,
      );

      if (image != null) _updateFiles([File(image.path)]);
    } catch (e) {
      _showError('An error occurred while taking photo: $e');
    }
  }

  Future<void> _pickVideoFromCamera() async {
    try {
      final video = await _picker.pickVideo(
        source: picker.ImageSource.camera,
        maxDuration: ImagePickerConstants.maxVideoDuration,
      );

      if (video != null) _updateFiles([File(video.path)]);
    } catch (e) {
      _showError('An error occurred while recording video: $e');
    }
  }

  void _removeImage(int index) {
    if (index < _networkImageUrls.length) {
      setState(() {
        _networkImageUrls.removeAt(index);
      });
    } else {
      final localIndex = index - _networkImageUrls.length;
      final removedMedia = _selectedMedia[localIndex];
      if (removedMedia.type == 'video') {
        VideoThumbnailHelper.removeThumbnail(removedMedia.file.path);
      }
      setState(() => _selectedMedia.removeAt(localIndex));
      _notifyCallbacks();
    }
    _notifyCallbacks();
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: _handleAddButtonTap,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? Colors.grey[300],
          borderRadius: AppDimensions.borderRadiusS,
          border: Border.all(color: Colors.grey[400]!, width: 1.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt,
              size: widget.iconSize,
              color: widget.iconColor ?? Colors.grey[600],
            ),
            const SizedBox(height: 4),
            Text(
              '${_selectedMedia.length}/${ImagePickerConstants.maxFiles}',
              style: TextStyle(
                fontSize: 10,
                color: widget.iconColor ?? Colors.grey[600],
                fontWeight: AppFontWeights.medium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    VideoThumbnailHelper.clearCache();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: [
        ..._networkImageUrls.asMap().entries.map(
          (entry) => MediaThumbnailHelper.buildNetworkImageThumbnail(
            url: entry.value,
            size: widget.size,
            onRemove: () => _removeImage(entry.key),
          ),
        ),
        ..._selectedMedia.asMap().entries.map(
          (entry) => MediaThumbnailHelper.buildMediaThumbnail(
            file: entry.value.file,
            size: widget.size,
            onRemove: () => _removeImage(entry.key + _networkImageUrls.length),
          ),
        ),
        _buildAddButton(),
      ],
    );
  }
}
