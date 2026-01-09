import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/themes/app_font_weights.dart';

class OnboardingContent extends StatelessWidget {
  const OnboardingContent({
    super.key,
    this.isTextOnTop = false,
    required this.title,
    required this.description,
    required this.image,
    this.category,
  });

  final bool isTextOnTop;
  final String title, description, image;
  final String? category;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            // 항상 이미지 먼저 표시
            ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.4,
                  ),
                  child: image.startsWith('http')
                      ? Image.network(
                          image,
                          height: MediaQuery.of(context).size.height * 0.36,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: MediaQuery.of(context).size.height * 0.36,
                              width: 300,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: MediaQuery.of(context).size.height * 0.36,
                              width: 300,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.image_not_supported,
                                size: 48,
                                color: Colors.grey,
                              ),
                            );
                          },
                        )
                      : Image.asset(
                          image,
                          height: MediaQuery.of(context).size.height * 0.36,
                        ),
                )
                .animate()
                .fadeIn(duration: 400.ms, delay: 100.ms)
                .scaleXY(begin: 0.8, end: 1.0, duration: 400.ms, delay: 100.ms),
            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            // 그 다음 텍스트 표시
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child:
                  OnboardTitleDescription(
                        title: title,
                        description: description,
                        category: category,
                      )
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 300.ms)
                      .slideY(
                        begin: 0.3,
                        end: 0,
                        duration: 500.ms,
                        delay: 300.ms,
                      ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.1),
          ],
        ),
      ),
    );
  }
}

class OnboardTitleDescription extends StatelessWidget {
  const OnboardTitleDescription({
    super.key,
    required this.title,
    required this.description,
    this.category,
  });

  final String title, description;
  final String? category;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬로 변경
      children: [
        if (category != null)
          Text(
                category!,
                style: TextStyle(
                  color: Color(0xff03CF5D),
                  fontSize: 16,
                  fontWeight: AppFontWeights.semiBold,
                ),
              )
              .animate()
              .fadeIn(duration: 300.ms, delay: 100.ms)
              .slideX(begin: -0.2, end: 0, duration: 300.ms, delay: 100.ms),
        SizedBox(height: 12),
        Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: AppFontWeights.semiBold,
                height: 1.3,
              ),
            )
            .animate()
            .fadeIn(duration: 400.ms, delay: 200.ms)
            .slideX(begin: -0.3, end: 0, duration: 400.ms, delay: 200.ms),
        SizedBox(height: 12),
        Text(
              description,
              style: TextStyle(
                fontSize: 14,
                fontWeight: AppFontWeights.regular,
                color: Color(0xff8e8e8e),
                height: 1.5,
              ),
            )
            .animate()
            .fadeIn(duration: 500.ms, delay: 300.ms)
            .slideX(begin: -0.2, end: 0, duration: 500.ms, delay: 300.ms),
        SizedBox(width: double.infinity),
      ],
    );
  }
}
