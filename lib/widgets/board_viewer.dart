import 'dart:math';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:vector_math/vector_math_64.dart';

import '../config.dart';

/// Wraps an [InteractiveViewer] to support panning when the user drags a
/// [Draggable] child object to edge of the viewer.
///
/// Use a [LongPressDraggable] widget instead of Draggable to avoid competing
/// with the viewer for the drag gesture.
///
/// A onDragUpdate handler is provided to child widgets to trigger the panning.
/// Use [BoardViewer.of] to get the instance of [BoardViewerState]:
/// ```dart
///   LongPressDraggable(
///     // ...
///     onDragUpdate: KBoardPanner.of(context).onDragUpdate,
///     // ...
///   );
/// ```
///
/// Other methods that can be used to control the panning:
/// - [BoardViewerState.panLeft] -- pans the viewport all the way to the left
/// - [BoardViewerState.panUp] -- pans the viewport all the way to the top
/// - [BoardViewerState.panRight] -- pans the viewport all the way to the right
/// - [BoardViewerState.panDown] -- pans the viewport all the way to the bottom
/// - [BoardViewerState.zoomIn] -- zooms in to the content
/// - [BoardViewerState.zoomOut] -- zooms out of the content
/// - [BoardViewerState.resetZoom] -- sets the zoom level to 1:1
/// - [BoardViewerState.stop] -- stops any panning or zooming in progress
/// - [BoardViewerState.reset] -- resets any pan or zoom to the initial state
class BoardViewer extends StatefulWidget {
  /// The size of the child widget tree.
  final Size childSize;

  /// The child widget tree.
  final Widget child;

  /// The margin inside the viewport within which the pointer will trigger
  /// panning.
  final EdgeInsets activationMargin;

  /// The resistance of the panning.
  ///
  /// The higher the value, the slower the movement. Must be >= 1.
  final int inertia;

  /// Creates an instance of [BoardViewer].
  BoardViewer({
    required this.childSize,
    required this.child,
    this.activationMargin = viewerActivationMargin,
    this.inertia = viewerInertia,
    Key? key,
  })  : assert(inertia > 0),
        super(key: key);

  @override
  BoardViewerState createState() => BoardViewerState();

  /// Finds the closest ancestor instance of [BoardViewer] that encloses the
  /// given context.
  static BoardViewerState of(BuildContext context) {
    final BoardViewerState? result =
        context.findAncestorStateOfType<BoardViewerState>();

    assert(result != null, 'No BoardViewer found in context');

    return result!;
  }
}

class BoardViewerState extends State<BoardViewer>
    with SingleTickerProviderStateMixin {
  /// The transformation controller that is passed to [InteractiveViewer].
  final TransformationController _transformationController =
      TransformationController();

  /// The animation controller for panning.
  late final AnimationController _animationController;

  /// The animated panning transformation.
  late Animation<Matrix4> _animation;

  /// The global position of the viewport.
  late Offset _viewportPosition;

  /// The size of the viewport.
  late Size _viewportSize;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _animationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Stack(
        children: [
          InteractiveViewer(
            constrained: false,
            transformationController: _transformationController,
            onInteractionStart: (_) => stop(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: max(constraints.maxWidth, widget.childSize.width),
                maxHeight: max(constraints.maxHeight, widget.childSize.height),
              ),
              child: widget.child,
            ),
          ),
          Positioned(
            right: 24.0,
            bottom: 24.0,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.zoom_in),
                  onPressed: zoomIn,
                ),
                IconButton(
                  icon: Icon(Icons.zoom_out),
                  onPressed: zoomOut,
                ),
                IconButton(
                  icon: Icon(Icons.crop_free),
                  onPressed: resetZoom,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// The onDragUpdate handler that can be used by child widgets to trigger
  /// panning.
  ///
  /// Set `onDragUpdate` handler to `KBoardViewer.of(context).onDragUpdate`.
  void onDragUpdate(DragUpdateDetails details) {
    // Get the viewport details.
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    _viewportPosition = renderBox.localToGlobal(Offset.zero);
    _viewportSize = renderBox.size;

    assert(_viewportSize.width >
        widget.activationMargin.left + widget.activationMargin.right);
    assert(_viewportSize.height >
        widget.activationMargin.top + widget.activationMargin.bottom);

    // Calculate the local position of the pointer.
    final Offset pointerPosition = details.globalPosition - _viewportPosition;

    // Create a short-circuit for the main bulk (center) of the viewport.
    if (Rect.fromLTRB(
      widget.activationMargin.left,
      widget.activationMargin.top,
      _viewportSize.width - widget.activationMargin.right,
      _viewportSize.height - widget.activationMargin.bottom,
    ).contains(pointerPosition)) return stop();

    // Check the left margin.
    if (Rect.fromLTRB(
      0.0,
      widget.activationMargin.top,
      widget.activationMargin.left,
      _viewportSize.height - widget.activationMargin.bottom,
    ).contains(pointerPosition)) return panLeft();

    // Check the top margin.
    if (Rect.fromLTRB(
      widget.activationMargin.left,
      0.0,
      _viewportSize.width - widget.activationMargin.right,
      widget.activationMargin.top,
    ).contains(pointerPosition)) return panUp();

    // Check the right margin.
    if (Rect.fromLTRB(
      _viewportSize.width - widget.activationMargin.right,
      widget.activationMargin.top,
      _viewportSize.width,
      _viewportSize.height - widget.activationMargin.bottom,
    ).contains(pointerPosition)) return panRight();

    // Check the bottom margin.
    if (Rect.fromLTRB(
      widget.activationMargin.left,
      _viewportSize.height - widget.activationMargin.bottom,
      _viewportSize.width - widget.activationMargin.right,
      _viewportSize.height,
    ).contains(pointerPosition)) return panDown();

    // If we reach here, we should be in the corners. For now, they do nothing.
    stop();
  }

  /// Pans the viewport all the way to the left.
  void panLeft() {
    // Don't proceed if an animation is already in progress.
    if (_animationController.isAnimating) return;

    final Matrix4 value = _transformationController.value.clone();
    final Vector3 translation = value.getTranslation();
    final double currentX = translation.x;
    final double targetX = 0.0;

    // Don't proceed if we are at the edge already.
    if (currentX >= targetX) return;

    translation.x = targetX;
    value.setTranslation(translation);
    _animation = Matrix4Tween(
      begin: _transformationController.value,
      end: value,
    ).animate(_animationController)
      ..addListener(_updateTransformationController);
    _animationController
      ..duration = Duration(milliseconds: -currentX.round() * widget.inertia)
      ..forward();
  }

  /// Pans the viewport all the way to the top.
  void panUp() {
    // Don't proceed if an animation is already in progress.
    if (_animationController.isAnimating) return;

    final Matrix4 value = _transformationController.value.clone();
    final Vector3 translation = value.getTranslation();
    final double currentY = translation.y;
    final double targetY = 0.0;

    // Don't proceed if we are at the edge already.
    if (currentY >= targetY) return;

    translation.y = targetY;
    value.setTranslation(translation);
    _animation = Matrix4Tween(
      begin: _transformationController.value,
      end: value,
    ).animate(_animationController)
      ..addListener(_updateTransformationController);
    _animationController
      ..duration = Duration(milliseconds: -currentY.round() * widget.inertia)
      ..forward();
  }

  /// Pans the viewport all the way to the right.
  void panRight() {
    // Don't proceed if an animation is already in progress.
    if (_animationController.isAnimating) return;

    final Matrix4 value = _transformationController.value.clone();
    final double scale = value.getMaxScaleOnAxis();
    final Vector3 translation = value.getTranslation();
    final double currentX = translation.x;
    final double targetX = _viewportSize.width - widget.childSize.width * scale;

    // Don't proceed if we are at the edge already.
    if (currentX <= targetX) return;

    translation.x = targetX;
    value.setTranslation(translation);
    _animation = Matrix4Tween(
      begin: _transformationController.value,
      end: value,
    ).animate(_animationController)
      ..addListener(_updateTransformationController);
    _animationController
      ..duration =
          Duration(milliseconds: (currentX - targetX).round() * widget.inertia)
      ..forward();
  }

  /// Pans the viewport all the way to the bottom.
  void panDown() {
    // Don't proceed if an animation is already in progress.
    if (_animationController.isAnimating) return;

    final Matrix4 value = _transformationController.value.clone();
    final double scale = value.getMaxScaleOnAxis();
    final Vector3 translation = value.getTranslation();
    final double currentY = translation.y;
    final double targetY =
        _viewportSize.height - widget.childSize.height * scale;

    // Don't proceed if we are at the edge already.
    if (currentY <= targetY) return;

    translation.y = currentY;
    value.setTranslation(translation);
    _animation = Matrix4Tween(
      begin: _transformationController.value,
      end: value,
    ).animate(_animationController)
      ..addListener(_updateTransformationController);
    _animationController
      ..duration =
          Duration(milliseconds: (currentY - targetY).round() * widget.inertia)
      ..forward();
  }

  /// Updates [_tranformationController] as part of the animation.
  void _updateTransformationController() {
    _transformationController.value = _animation.value;

    if (!_animationController.isAnimating) {
      _animation.removeListener(_updateTransformationController);
      _animationController.reset();
    }
  }

  /// Stops any panning or zooming animation that is currently in progress.
  ///
  /// Does nothing if the viewer is not currently animating.
  void stop() {
    if (_animationController.isAnimating) {
      _animationController.stop();
      _animation.removeListener(_updateTransformationController);
      _animationController.reset();
    }
  }

  /// Zooms in to the child content.
  void zoomIn() {
    // Don't proceed if an animation is already in progress.
    if (_animationController.isAnimating) return;

    // Get the viewport details.
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    _viewportPosition = renderBox.localToGlobal(Offset.zero);
    _viewportSize = renderBox.size;

    // Don't proceed if we are already at maximum scale.
    final double maxScale = 2.5;
    final Matrix4 value = _transformationController.value.clone();
    final double scale = value.getMaxScaleOnAxis();
    if (scale >= maxScale) return;

    final double scaleFactor = exp(0.1); // 1/5 of mousewheel step?
    final double targetScale = min(scale * scaleFactor, maxScale);
    value.scale(targetScale / scale);

    _animation = Matrix4Tween(
      begin: _transformationController.value,
      end: value,
    ).animate(_animationController)
      ..addListener(_updateTransformationController);
    _animationController
      ..duration = Duration(milliseconds: 200)
      ..forward();
  }

  /// Zooms out of the child content.
  void zoomOut() {
    // Don't proceed if an animation is already in progress.
    if (_animationController.isAnimating) return;

    // Get the viewport details.
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    _viewportPosition = renderBox.localToGlobal(Offset.zero);
    _viewportSize = renderBox.size;

    // Calculate the minimum scale.
    double minScale = 0.8;
    if (_viewportSize.width > widget.childSize.width) {
      minScale = max(minScale, 1.0);
    } else {
      minScale = max(minScale, _viewportSize.width / widget.childSize.width);
    }
    if (_viewportSize.height > widget.childSize.height) {
      minScale = max(minScale, 1.0);
    } else {
      minScale = max(minScale, _viewportSize.height / widget.childSize.height);
    }

    // Don't proceed if we are already at minimum scale.
    final Matrix4 value = _transformationController.value.clone();
    final double scale = value.getMaxScaleOnAxis();
    if (scale <= minScale) return;

    final double scaleFactor = exp(-0.1); // 1/5 of mousewheel step?
    final double targetScale = (scale * scaleFactor).clamp(minScale, 2.5);
    value.scale(targetScale / scale);

    // Fix translation if out-of-bound.
    final Vector3 translation = value.getTranslation();
    if (_viewportSize.width > widget.childSize.width) {
      translation.x = 0.0;
    } else if (translation.x <
        _viewportSize.width - widget.childSize.width * targetScale) {
      translation.x =
          _viewportSize.width - widget.childSize.width * targetScale;
    }
    if (_viewportSize.height > widget.childSize.height) {
      translation.y = 0.0;
    } else if (translation.y <
        _viewportSize.height - widget.childSize.height * targetScale) {
      translation.y =
          _viewportSize.height - widget.childSize.height * targetScale;
    }
    value.setTranslation(translation);

    _animation = Matrix4Tween(
      begin: _transformationController.value,
      end: value,
    ).animate(_animationController)
      ..addListener(_updateTransformationController);
    _animationController
      ..duration = Duration(milliseconds: 200)
      ..forward();
  }

  /// Resets zoom back to 1:1.
  void resetZoom() {
    // Don't proceed if an animation is already in progress.
    if (_animationController.isAnimating) return;

    // Get the viewport details.
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    _viewportPosition = renderBox.localToGlobal(Offset.zero);
    _viewportSize = renderBox.size;

    // Get the new translation using the top-left of the viewport as reference.
    final double scale = _transformationController.value.getMaxScaleOnAxis();
    final Vector3 translation =
        _transformationController.value.getTranslation();
    final double currentX = translation.x;
    final double currentY = translation.y;
    // Perform some boundary checks.
    double targetX = currentX / scale;
    if (_viewportSize.width > widget.childSize.width) {
      targetX = 0.0;
    } else if (targetX < _viewportSize.width - widget.childSize.width) {
      targetX = _viewportSize.width - widget.childSize.width;
    }
    double targetY = currentY / scale;
    if (_viewportSize.height > widget.childSize.height) {
      targetY = 0.0;
    } else if (targetY < _viewportSize.height - widget.childSize.height) {
      targetY = _viewportSize.height - widget.childSize.height;
    }
    final Matrix4 value = Matrix4.identity()..translate(targetX, targetY);

    _animation = Matrix4Tween(
      begin: _transformationController.value,
      end: value,
    ).animate(_animationController)
      ..addListener(_updateTransformationController);
    _animationController
      ..duration = Duration(milliseconds: 200)
      ..forward();
  }

  /// Resets any pan or zoom to the initial state.
  void reset() {
    // Don't proceed if an animation is already in progress.
    if (_animationController.isAnimating) return;

    _animation = Matrix4Tween(
      begin: _transformationController.value,
      end: Matrix4.identity(),
    ).animate(_animationController)
      ..addListener(_updateTransformationController);
    _animationController
      ..duration = Duration(milliseconds: 200)
      ..forward();
  }
}
