library persistent_top_sheet;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'persistent_top_sheet_controller.dart';

/// A widget that displays a persistent top sheet.
class PersistentTopSheet extends StatefulWidget {
  /// A widget that displays a persistent top sheet.
  const PersistentTopSheet({
    super.key,
    required this.maxHeight,
    required this.minHeight,
    required this.childBuilder,
    this.handleBuilder,
    this.controller,
    this.animationSpeed = 2000,
    this.initialHeight,
    this.isDraggable = true,
    this.onStateChanged,
    this.onHeightChanged,
  });

  /// The controller that can be used to open, close, or toggle the top sheet.
  final PersistentTopSheetController? controller;

  /// The speed of the animation when opening or closing the top sheet.
  final double animationSpeed;

  /// The maximum height of the top sheet.
  final double maxHeight;

  /// The minimum height of the top sheet.
  final double minHeight;

  /// The initial height of the top sheet (if not provided, it will be equal to [minHeight]).
  final double? initialHeight;

  /// The builder for the handle widget that is used to drag the top sheet.
  ///
  ///  (current height is passed as an argument)
  final Widget Function(double)? handleBuilder;

  /// The builder for the child widget that is displayed when the top sheet is open.
  ///
  /// (current height is passed as an argument)
  final Widget Function(double) childBuilder;

  /// Whether the top sheet is draggable with a handle.
  final bool isDraggable;

  /// Called on open (true) or close (false).
  final void Function(bool)? onStateChanged;

  /// Called when the height of the top sheet changes.
  final void Function(double)? onHeightChanged;

  @override
  State<PersistentTopSheet> createState() => _PersistentTopSheetState();
}

class _PersistentTopSheetState extends State<PersistentTopSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _anim;
  late PersistentTopSheetController _controller;

  late double _crtHeight;

  @override
  void initState() {
    super.initState();

    _crtHeight = widget.initialHeight ?? widget.minHeight;

    _controller = widget.controller ?? PersistentTopSheetController();
    _animController = AnimationController(vsync: this);

    _animController.addListener(() => _setHeight(_anim.value));

    _controller.addListener(_onControllerChanged);

    // Sync the initial controller height if provided
    if (_controller.currentHeight != _crtHeight) {
      _controller.setHeight(_crtHeight);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _animController.dispose();

    super.dispose();
  }

  void _setHeight(double newHeight) {
    setState(() {
      _crtHeight = newHeight.clamp(widget.minHeight, widget.maxHeight);
    });
    _controller
        .setHeight(_crtHeight); // Update the controller with the new height
    widget.onHeightChanged?.call(_crtHeight);
  }

  void _onControllerChanged() {
    if (_controller.isOpen) {
      _open();
    } else {
      _close();
    }

    // Update the height if it was explicitly set through the controller
    if (_controller.currentHeight != _crtHeight) {
      _setHeight(_controller.currentHeight);
    }

    widget.onStateChanged?.call(_controller.isOpen);
  }

  Future<void> _runAnimation(
      double targetHeight, Offset pixelsPerSecond) async {
    _anim = _animController.drive(
      Tween<double>(
        begin: _crtHeight,
        end: targetHeight,
      ),
    );

    final unitVelocity = pixelsPerSecond.dy / widget.maxHeight;

    const spring = SpringDescription(
      mass: 40,
      stiffness: 1,
      damping: 1,
    );

    final simulation = SpringSimulation(spring, 0, 1, -unitVelocity);

    await _animController.animateWith(simulation);
  }

  Future<void> _open({Offset? pixelsPerSecond}) async {
    await _runAnimation(
        widget.maxHeight, pixelsPerSecond ?? Offset(0, widget.animationSpeed));
    _controller.open();
  }

  Future<void> _close({Offset? pixelsPerSecond}) async {
    await _runAnimation(
        widget.minHeight, pixelsPerSecond ?? Offset(0, -widget.animationSpeed));
    _controller.close();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: _crtHeight,
          child: widget.childBuilder(_crtHeight),
        ),
        if (widget.isDraggable)
          GestureDetector(
            onVerticalDragStart: (details) => _animController.stop(),
            onVerticalDragEnd: (details) {
              final velocity = details.velocity.pixelsPerSecond.dy;

              if (velocity.abs() > widget.animationSpeed / 2) {
                // If the drag velocity is fast enough, decide based on the direction
                velocity > 0
                    ? _open(pixelsPerSecond: details.velocity.pixelsPerSecond)
                    : _close(pixelsPerSecond: details.velocity.pixelsPerSecond);
              } else {
                // If the velocity is slow, decide based on the current height
                _crtHeight > widget.maxHeight / 2 ? _open() : _close();
              }
            },
            onVerticalDragUpdate: (details) =>
                _setHeight(_crtHeight + details.delta.dy),
            child: widget.handleBuilder?.call(_crtHeight) ?? const SizedBox(),
          )
        else
          widget.handleBuilder?.call(_crtHeight) ?? const SizedBox(),
      ],
    );
  }
}
