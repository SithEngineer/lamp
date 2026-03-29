import 'dart:async';
import 'package:flutter/material.dart';

import '../colors/color_controller.dart';
import '../models/color_palette.dart';
import '../theme/spacing.dart';

/// Main color lamp screen widget
/// Displays full-screen color with swipe navigation and color chip selection
class ColorLampScreen extends StatefulWidget {
  const ColorLampScreen({super.key});

  @override
  State<ColorLampScreen> createState() => _ColorLampScreenState();
}

class _ColorLampScreenState extends State<ColorLampScreen>
    with SingleTickerProviderStateMixin {
  late ColorController colorController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  late Timer _animationTimer;

  @override
  void initState() {
    super.initState();
    colorController = ColorController();
    colorController.addListener(() => setState(() {}));

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, 0.5),
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    colorController.dispose();
    _animationController.dispose();
    _animationTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          final swipeRight = details.primaryVelocity! > 0;
          if (swipeRight) {
            colorController.previousColor();
          } else {
            colorController.nextColor();
          }
        },
        onVerticalDragEnd: (details) {
          final swipeUp = details.primaryVelocity! <
              0; // Negative velocity means upward swipe
          if (swipeUp) {
            colorController.increaseBrightness();
          } else {
            colorController.decreaseBrightness();
          }
        },
        child: Stack(
          children: [
            // Full-screen color display
            _ColorDisplay(colorController: colorController),

            // Color chip selection bar
            _ColorChipBar(
              currentIndex: colorController.colorIndex,
              onColorSelected: colorController.selectColor,
              fadeAnimation: _fadeAnimation,
              slideAnimation: _slideAnimation,
            ),

            // Helper text at bottom
            _HelperText(
              fadeAnimation: _fadeAnimation,
              slideAnimation: _slideAnimation,
            ),
          ],
        ),
      ),
    );
  }
}

/// Displays the full-screen color
/// Uses AnimatedContainer for smooth color transitions
class _ColorDisplay extends StatelessWidget {
  final ColorController colorController;

  const _ColorDisplay({required this.colorController});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppSpacing.colorTransitionDuration,
      color: colorController.adjustedColor,
    );
  }
}

/// Color chip selection bar at bottom of screen
/// Shows all 12 colors as circular chips with selection indicator
class _ColorChipBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onColorSelected;
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;

  const _ColorChipBar({
    required this.currentIndex,
    required this.onColorSelected,
    required this.fadeAnimation,
    required this.slideAnimation,
  });

  @override
  State<_ColorChipBar> createState() => _ColorChipBarState();
}

class _ColorChipBarState extends State<_ColorChipBar> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelected();
    });
  }

  @override
  void didUpdateWidget(_ColorChipBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _scrollToSelected();
    }
  }

  void _scrollToSelected() {
    const chipWidth = AppSpacing.colorChipSize + 2 * AppSpacing.colorChipMargin;
    final scrollPosition = widget.currentIndex * chipWidth;
    _scrollController.animateTo(
      scrollPosition,
      duration: AppSpacing.colorTransitionDuration,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: AppSpacing.bottomBarHeight + 8,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: widget.slideAnimation,
        child: Container(
          height: AppSpacing.bottomBarHeight,
          color: Colors.black45,
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            itemCount: ColorPalette.length,
            itemBuilder: (context, index) {
              return _ColorChip(
                color: ColorPalette.colors[index],
                isSelected: index == widget.currentIndex,
                onTap: () => widget.onColorSelected(index),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Individual color chip widget
/// Displays as circular chip with optional white border when selected
class _ColorChip extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorChip({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: AppSpacing.colorChipSize,
        height: AppSpacing.colorChipSize,
        margin: const EdgeInsets.all(AppSpacing.colorChipMargin),
        decoration: BoxDecoration(
          color: color,
          border: isSelected
              ? Border.all(
                  color: Colors.white,
                  width: 2.0,
                )
              : null,
          borderRadius: const BorderRadius.all(
            Radius.circular(10),
          ),
        ),
      ),
    );
  }
}

/// Helper text displayed at bottom of screen
/// Shows instructions for swiping, fades down after 2 seconds
class _HelperText extends StatelessWidget {
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;

  const _HelperText({
    required this.fadeAnimation,
    required this.slideAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 8,
      left: 0,
      right: 0,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: SlideTransition(
          position: slideAnimation,
          child: Container(
            height: AppSpacing.bottomBarHeight,
            color: Colors.black,
            child: const Center(
              child: Text(
                'Swipe left/right to change color, up/down to adjust brightness',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: AppSpacing.helpTextSize,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
