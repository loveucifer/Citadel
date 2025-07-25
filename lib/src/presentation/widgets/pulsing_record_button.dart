// File: lib/src/presentation/widgets/pulsing_record_button.dart

import 'package:flutter/material.dart';
import 'package:citadel/src/utils/app_theme.dart';

class PulsingRecordButton extends StatefulWidget {
  final bool isRecording;
  final VoidCallback onTap;

  const PulsingRecordButton({
    super.key,
    required this.isRecording,
    required this.onTap,
  });

  @override
  State<PulsingRecordButton> createState() => _PulsingRecordButtonState();
}

class _PulsingRecordButtonState extends State<PulsingRecordButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    )..addListener(() {
        setState(() {});
      });

    // We only want the animation to repeat when recording
    if (widget.isRecording) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant PulsingRecordButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRecording != oldWidget.isRecording) {
      if (widget.isRecording) {
        _animationController.repeat(reverse: true);
      } else {
        _animationController.stop();
        _animationController.reset();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double size = 100.0;
    return GestureDetector(
      onTap: widget.onTap,
      child: SizedBox(
        width: size * 1.5,
        height: size * 1.5,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // The pulsing outer circle
            if (widget.isRecording)
              Container(
                width: size * (1 + _animation.value * 0.5),
                height: size * (1 + _animation.value * 0.5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.recordButtonColor.withOpacity(1 - _animation.value),
                ),
              ),
            // The main button
            Container(
              width: size,
              height: size,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.recordButtonColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                widget.isRecording ? Icons.stop : Icons.mic,
                color: Colors.white,
                size: 50,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
