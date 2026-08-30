import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';
import '../../../../core/theme/colors.dart';
import '../../data/models/exercise.dart';
import 'muscle_engagement_overlay.dart';

/// Camera angle preset values for 3D viewing.
enum CameraAnglePreset {
  front(0, 75, 105, 'Front'),
  side45(45, 75, 105, '45°'),
  side90(90, 75, 105, 'Side'),
  back(180, 75, 105, 'Back');

  final double theta;
  final double phi;
  final double radius;
  final String label;

  const CameraAnglePreset(this.theta, this.phi, this.radius, this.label);
}

/// Advanced 3D model viewer for exercise animations with playback controls,
/// camera presets, auto-rotation, and muscle activation overlay.
class Exercise3DViewer extends StatefulWidget {
  final String? modelSrc;
  final String exerciseName;
  final String category;
  final List<ExerciseMuscle> muscles;
  final double height;
  final bool isPlaying;
  final double playbackSpeed;
  final VoidCallback? onPlayPauseToggle;
  final ValueChanged<double>? onSpeedChanged;

  const Exercise3DViewer({
    super.key,
    this.modelSrc,
    required this.exerciseName,
    required this.category,
    this.muscles = const [],
    this.height = 360,
    this.isPlaying = false,
    this.playbackSpeed = 1.0,
    this.onPlayPauseToggle,
    this.onSpeedChanged,
  });

  @override
  State<Exercise3DViewer> createState() => _Exercise3DViewerState();
}

class _Exercise3DViewerState extends State<Exercise3DViewer>
    with SingleTickerProviderStateMixin {
  late final Flutter3DController _controller;
  CameraAnglePreset _selectedAngle = CameraAnglePreset.front;
  bool _showMuscleOverlay = false;
  bool _autoRotate = true;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _controller = Flutter3DController();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant Exercise3DViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _controller.playAnimation();
      } else {
        _controller.pauseAnimation();
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _setCameraAngle(CameraAnglePreset preset) {
    setState(() => _selectedAngle = preset);
    _controller.setCameraOrbit(preset.theta, preset.phi, preset.radius);
  }

  void _toggleAutoRotate() {
    setState(() => _autoRotate = !_autoRotate);
  }

  Color get _categoryColor {
    return switch (widget.category.toLowerCase()) {
      'chest' => AppColors.muscleChest,
      'back' => AppColors.muscleBack,
      'legs' => AppColors.muscleLegs,
      'shoulders' => AppColors.muscleShoulders,
      'arms' => AppColors.muscleArms,
      'core' => AppColors.muscleCore,
      _ => AppColors.primary,
    };
  }

  @override
  Widget build(BuildContext context) {
    final hasValidSrc =
        widget.modelSrc != null && widget.modelSrc!.isNotEmpty;

    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          // Background Gradient & 3D Space Grid
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.backgroundDark,
                    AppColors.surfaceDark,
                    AppColors.surfaceElevatedDark,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: CustomPaint(
                painter: _GridBackgroundPainter(color: _categoryColor),
              ),
            ),
          ),

          // 3D Model / Fallback Visualizer
          Positioned.fill(
            child: hasValidSrc
                ? Flutter3DViewer(
                    src: widget.modelSrc!,
                    controller: _controller,
                  )
                : _Fallback3DVisualizer(
                    categoryColor: _categoryColor,
                    exerciseName: widget.exerciseName,
                    category: widget.category,
                    isPlaying: widget.isPlaying,
                    pulseAnimation: _pulseController,
                  ),
          ),

          // Top Overlay: Camera Angle Presets & Controls
          Positioned(
            top: 12,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Camera Angle Presets
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.borderDark,
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: CameraAnglePreset.values.map((preset) {
                      final isSelected = _selectedAngle == preset;
                      return GestureDetector(
                        onTap: () => _setCameraAngle(preset),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? _categoryColor.withValues(alpha: 0.25)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            preset.label,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: isSelected
                                      ? _categoryColor
                                      : AppColors.textSecondaryDark,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // Action Buttons (Auto-Rotate & Muscle Map toggle)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Auto-Rotate Button
                    _ViewerIconButton(
                      icon: Icons.rotate_right_rounded,
                      isActive: _autoRotate,
                      activeColor: _categoryColor,
                      tooltip: 'Auto Rotate',
                      onTap: _toggleAutoRotate,
                    ),
                    const SizedBox(width: 8),
                    // Muscle Map Toggle Button
                    _ViewerIconButton(
                      icon: Icons.accessibility_new_rounded,
                      isActive: _showMuscleOverlay,
                      activeColor: AppColors.error,
                      tooltip: 'Muscle Activation Map',
                      onTap: () {
                        setState(() =>
                            _showMuscleOverlay = !_showMuscleOverlay);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Muscle Engagement Overlay (floating popup)
          if (_showMuscleOverlay && widget.muscles.isNotEmpty)
            Positioned(
              top: 58,
              right: 16,
              width: 220,
              child: MuscleEngagementOverlay(
                muscles: widget.muscles,
                onClose: () =>
                    setState(() => _showMuscleOverlay = false),
              ),
            ),

          // Interactive Gesture Hint
          Positioned(
            bottom: 12,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.touch_app_outlined,
                    size: 12,
                    color: AppColors.textTertiaryDark,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Drag to rotate • Pinch to zoom',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textTertiaryDark,
                          fontSize: 10,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ViewerIconButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final Color activeColor;
  final String tooltip;
  final VoidCallback onTap;

  const _ViewerIconButton({
    required this.icon,
    required this.isActive,
    required this.activeColor,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isActive
                ? activeColor.withValues(alpha: 0.2)
                : AppColors.surfaceDark.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isActive
                  ? activeColor.withValues(alpha: 0.5)
                  : AppColors.borderDark,
              width: 0.5,
            ),
          ),
          child: Icon(
            icon,
            size: 18,
            color: isActive ? activeColor : AppColors.textSecondaryDark,
          ),
        ),
      ),
    );
  }
}

/// Stylized interactive fallback visualizer for exercises when 3D asset is downloading or running offline.
class _Fallback3DVisualizer extends StatelessWidget {
  final Color categoryColor;
  final String exerciseName;
  final String category;
  final bool isPlaying;
  final Animation<double> pulseAnimation;

  const _Fallback3DVisualizer({
    required this.categoryColor,
    required this.exerciseName,
    required this.category,
    required this.isPlaying,
    required this.pulseAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseAnimation,
      builder: (context, child) {
        final scale = 1.0 + (pulseAnimation.value * 0.06);

        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              Transform.scale(
                scale: scale,
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        categoryColor.withValues(alpha: 0.35),
                        categoryColor.withValues(alpha: 0.08),
                        Colors.transparent,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: categoryColor.withValues(alpha: 0.2),
                        blurRadius: 28,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.accessibility_new_rounded,
                      size: 72,
                      color: categoryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevatedDark.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: categoryColor.withValues(alpha: 0.3),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPlaying
                          ? Icons.motion_photos_auto_rounded
                          : Icons.view_in_ar_rounded,
                      size: 14,
                      color: categoryColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isPlaying ? 'Simulating Form...' : '3D Form Preview',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: categoryColor,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Perspective floor grid painter to create depth for the 3D space.
class _GridBackgroundPainter extends CustomPainter {
  final Color color;

  _GridBackgroundPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.05)
      ..strokeWidth = 1.0;

    final horizon = size.height * 0.75;

    // Perspective lines emanating from vanishing point
    final centerX = size.width / 2;
    for (int i = -6; i <= 6; i++) {
      final endX = centerX + (i * 45);
      canvas.drawLine(
        Offset(centerX, horizon - 40),
        Offset(endX, size.height),
        paint,
      );
    }

    // Horizontal ground grid lines
    for (double y = horizon; y <= size.height; y += 18) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GridBackgroundPainter oldDelegate) =>
      oldDelegate.color != color;
}
