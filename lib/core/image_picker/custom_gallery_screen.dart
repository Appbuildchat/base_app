import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import 'dart:typed_data';
import '../../../core/themes/color_theme.dart';
import '../themes/app_font_weights.dart';
import '../themes/app_theme.dart';

class CustomGalleryScreen extends StatefulWidget {
  final List<File> selectedFiles;
  final bool allowVideo;
  final int maxFiles;

  const CustomGalleryScreen({
    super.key,
    required this.selectedFiles,
    this.allowVideo = true,
    this.maxFiles = 10,
  });

  @override
  State<CustomGalleryScreen> createState() => _CustomGalleryScreenState();
}

class _CustomGalleryScreenState extends State<CustomGalleryScreen> {
  List<AssetEntity> _assets = [];
  final List<AssetEntity> _selectedAssets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAssets();
  }

  Future<void> _loadAssets() async {
    final PermissionState permission =
        await PhotoManager.requestPermissionExtend();
    if (permission.isAuth) {
      final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: widget.allowVideo ? RequestType.common : RequestType.image,
        onlyAll: true,
      );

      if (albums.isNotEmpty) {
        final List<AssetEntity> assets = await albums.first.getAssetListPaged(
          page: 0,
          size: 1000,
        );

        // 날짜순으로 정렬 (최신순)
        assets.sort((a, b) => b.createDateTime.compareTo(a.createDateTime));

        setState(() {
          _assets = assets;
          _isLoading = false;
        });
      }
    } else {
      PhotoManager.openSetting();
    }
  }

  bool _isFileSelected(AssetEntity asset) {
    return widget.selectedFiles.any((file) {
      final fileName = file.path.split('/').last;
      return asset.title == fileName;
    });
  }

  bool _isAssetSelected(AssetEntity asset) {
    return _selectedAssets.contains(asset);
  }

  void _toggleSelection(AssetEntity asset) {
    setState(() {
      if (_isAssetSelected(asset)) {
        _selectedAssets.remove(asset);
      } else {
        if (_selectedAssets.length + widget.selectedFiles.length <
            widget.maxFiles) {
          _selectedAssets.add(asset);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Maximum ${widget.maxFiles} files allowed')),
          );
        }
      }
    });
  }

  Future<void> _confirmSelection() async {
    final List<File> newFiles = [];

    for (AssetEntity asset in _selectedAssets) {
      final File? file = await asset.file;
      if (file != null) {
        newFiles.add(file);
      }
    }

    if (mounted) {
      context.pop(newFiles);
    }
  }

  String _formatDuration(int duration) {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Widget _buildAssetThumbnail(AssetEntity asset, int index) {
    final bool isSelected = _isAssetSelected(asset);
    final bool isAlreadySelected = _isFileSelected(asset);

    return GestureDetector(
      onTap: isAlreadySelected ? null : () => _toggleSelection(asset),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 3,
          ),
        ),
        child: Stack(
          children: [
            // 썸네일 이미지
            FutureBuilder<Uint8List?>(
              future: asset.thumbnailDataWithSize(
                const ThumbnailSize.square(200),
              ),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  return Image.memory(
                    snapshot.data!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  );
                } else {
                  return Container(
                    color: AppCommonColors.grey300,
                    child: const Center(child: CircularProgressIndicator()),
                  );
                }
              },
            ),

            // 이미 선택된 파일 오버레이
            if (isAlreadySelected)
              Container(
                color: AppCommonColors.black.withValues(alpha: 0.54),
                child: const Center(
                  child: Icon(
                    Icons.check_circle,
                    color: AppCommonColors.white,
                    size: 30,
                  ),
                ),
              ),

            // 비디오 아이콘과 길이
            if (asset.type == AssetType.video) ...[
              const Positioned(
                top: 8,
                right: 8,
                child: Icon(
                  Icons.videocam,
                  color: AppCommonColors.white,
                  size: 20,
                ),
              ),
              Positioned(
                bottom: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppCommonColors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _formatDuration(asset.duration),
                    style: const TextStyle(
                      color: AppCommonColors.white,
                      fontSize: 11,
                      fontWeight: AppFontWeights.medium,
                    ),
                  ),
                ),
              ),
            ],

            // 선택 체크박스
            if (!isAlreadySelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : AppCommonColors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppCommonColors.grey500,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          color: AppCommonColors.white,
                          size: 16,
                        )
                      : null,
                ),
              ),

            // 선택 번호 표시
            if (isSelected)
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${_selectedAssets.indexOf(asset) + 1}',
                      style: const TextStyle(
                        color: AppCommonColors.white,
                        fontSize: 12,
                        fontWeight: AppFontWeights.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Select Media',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: AppFontWeights.semiBold,
          ),
        ),
        backgroundColor: AppCommonColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppCommonColors.black),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (_selectedAssets.isNotEmpty)
            TextButton(
              onPressed: _confirmSelection,
              child: Text(
                'Add (${_selectedAssets.length})',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: AppFontWeights.semiBold,
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _assets.isEmpty
          ? const Center(child: Text('No media found'))
          : GridView.builder(
              padding: const EdgeInsets.all(4),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
              ),
              itemCount: _assets.length,
              itemBuilder: (context, index) {
                final asset = _assets[index];
                return _buildAssetThumbnail(asset, index);
              },
            ),
    );
  }
}
