library circular_bottom_navigation;

import 'dart:core';
import 'dart:math';
import 'package:flutter/material.dart';

import 'Tab_item.dart';

typedef CircularBottomNavSelectedCallback = Function(int? selectedPos);

class CircularBottomNavigation extends StatefulWidget {
  final List<TabItem> tabItems;
  final int selectedPos;
  final double barHeight;
  final Color? barBackgroundColor;
  final Gradient? barBackgroundGradient;
  final double circleSize;
  final double circleStrokeWidth;
  final double iconsSize;
  final Color? selectedIconColor;
  final Color? normalIconColor;
  final Duration animationDuration;
  final List<BoxShadow>? backgroundBoxShadow;
  final CircularBottomNavSelectedCallback? selectedCallback;
  final CircularBottomNavigationController? controller;
  final bool allowSelectedIconCallback;

  CircularBottomNavigation(
      this.tabItems, {
        this.selectedPos = 0,
        this.barHeight = 60,
        this.barBackgroundColor,
        this.barBackgroundGradient,
        this.circleSize = 58,
        this.circleStrokeWidth = 4,
        this.iconsSize = 32,
        this.selectedIconColor,
        this.normalIconColor,
        this.animationDuration = const Duration(milliseconds: 300),
        this.selectedCallback,
        this.controller,
        this.allowSelectedIconCallback = false,
        this.backgroundBoxShadow,
      })  : assert(barBackgroundColor == null || barBackgroundGradient == null,
  "Both barBackgroundColor and barBackgroundGradient can't be not null."),
        assert(tabItems.length != 0, "tabItems is required");

  @override
  State<StatefulWidget> createState() => _CircularBottomNavigationState();
}

class _CircularBottomNavigationState extends State<CircularBottomNavigation>
    with TickerProviderStateMixin {
  Curve _animationsCurve = Curves.easeOutBack;

  late AnimationController itemsController;
  late Animation<double> selectedPosAnimation;
  late Animation<double> itemsAnimation;

  late List<double> _itemsSelectedState;

  int? selectedPos;
  int? previousSelectedPos;

  CircularBottomNavigationController? _controller;

  @override
  void initState() {
    super.initState();

    if (widget.controller != null) {
      _controller = widget.controller;
      previousSelectedPos = selectedPos = _controller!.value;
    } else {
      previousSelectedPos = selectedPos = widget.selectedPos;
      _controller = CircularBottomNavigationController(selectedPos);
    }

    _controller!.addListener(_newSelectedPosNotify);

    _itemsSelectedState = List.generate(widget.tabItems.length, (index) {
      return selectedPos == index ? 1.0 : 0.0;
    });

    itemsController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    itemsController.addListener(() {
      setState(() {
        _itemsSelectedState.asMap().forEach((i, value) {
          if (i == previousSelectedPos) {
            _itemsSelectedState[previousSelectedPos!] =
                1.0 - itemsAnimation.value;
          } else if (i == selectedPos) {
            _itemsSelectedState[selectedPos!] = itemsAnimation.value;
          } else {
            _itemsSelectedState[i] = 0.0;
          }
        });
      });
    });

    selectedPosAnimation = makeSelectedPosAnimation(
        selectedPos!.toDouble(), selectedPos!.toDouble());

    itemsAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: itemsController, curve: _animationsCurve),
    );
  }

  Animation<double> makeSelectedPosAnimation(double begin, double end) {
    return Tween(begin: begin, end: end).animate(
      CurvedAnimation(parent: itemsController, curve: _animationsCurve),
    );
  }

  void onSelectedPosAnimate() {
    setState(() {});
  }

  void _newSelectedPosNotify() {
    _setSelectedPos(widget.controller!.value);
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = widget.barBackgroundColor ?? Theme.of(context).colorScheme.surface;
    final iconSelectedColor =
        widget.selectedIconColor ?? Theme.of(context).iconTheme.color;
    final iconNormalColor =
        widget.normalIconColor ?? Theme.of(context).iconTheme.color?.withOpacity(0.6);

    double maxShadowHeight = (widget.backgroundBoxShadow ?? []).isNotEmpty
        ? widget.backgroundBoxShadow!.map((e) => e.blurRadius).reduce(max)
        : 0.0;
    double fullWidth = MediaQuery.of(context).size.width;
    double fullHeight = widget.barHeight +
        (widget.circleSize / 2) +
        widget.circleStrokeWidth +
        maxShadowHeight;
    double sectionsWidth = fullWidth / widget.tabItems.length;
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    List<Rect> boxes = [];
    widget.tabItems.asMap().forEach((i, tabItem) {
      double left =
      isRTL ? fullWidth - (i + 1) * sectionsWidth : i * sectionsWidth;
      double top = fullHeight - widget.barHeight;
      double right = left + sectionsWidth;
      double bottom = fullHeight;
      boxes.add(Rect.fromLTRB(left, top, right, bottom));
    });

    List<Widget> children = [];

    children.add(Container(width: fullWidth, height: fullHeight));

    children.add(Positioned(
      top: fullHeight - widget.barHeight,
      left: 0,
      child: Container(
        width: fullWidth,
        height: widget.barHeight,
        decoration: BoxDecoration(
          color: backgroundColor,
          gradient: widget.barBackgroundGradient,
          boxShadow: widget.backgroundBoxShadow,
        ),
      ),
    ));

    children.add(Positioned(
      top: maxShadowHeight,
      left: isRTL
          ? fullWidth -
          ((selectedPosAnimation.value * sectionsWidth) +
              (sectionsWidth / 2) +
              (widget.circleSize / 2))
          : (selectedPosAnimation.value * sectionsWidth) +
          (sectionsWidth / 2) -
          (widget.circleSize / 2),
      child: Container(
        width: widget.circleSize,
        height: widget.circleSize,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                          top: Radius.circular(widget.circleSize / 2)),
                      color: widget.tabItems[selectedPos!].circleStrokeColor ??
                          backgroundColor,
                      boxShadow: widget.backgroundBoxShadow,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(widget.circleSize / 2)),
                      color: widget.tabItems[selectedPos!].circleStrokeColor ??
                          backgroundColor,
                    ),
                  ),
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.all(widget.circleStrokeWidth),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.tabItems[selectedPos!].circleColor,
              ),
            ),
          ],
        ),
      ),
    ));

    boxes.asMap().forEach((int pos, Rect r) {
      final isSelected = pos == selectedPos;

      children.add(Positioned(
        left: r.center.dx - (widget.iconsSize / 2),
        top: r.center.dy -
            (widget.iconsSize / 2) -
            (_itemsSelectedState[pos] *
                ((widget.barHeight / 2) + widget.circleStrokeWidth)),
        child: Transform.scale(
          scale: isSelected ? 1.2 : 1.0,
          child: Icon(
            widget.tabItems[pos].icon,
            size: widget.iconsSize,
            color: isSelected ? iconSelectedColor : iconNormalColor,
          ),
        ),
      ));

      double textHeight = fullHeight - widget.circleSize;
      double opacity = _itemsSelectedState[pos].clamp(0.0, 1.0);

      children.add(Positioned(
        left: r.left,
        top: r.top +
            (widget.circleSize / 2) -
            (widget.circleStrokeWidth * 2) +
            ((1.0 - _itemsSelectedState[pos]) * textHeight),
        child: Container(
          width: r.width,
          height: textHeight,
          child: Center(
            child: Opacity(
              opacity: opacity,
              child: Text(
                widget.tabItems[pos].title,
                textAlign: TextAlign.center,
                style: (widget.tabItems[pos].labelStyle ?? const TextStyle()).copyWith(
                  color: isSelected
                      ? Theme.of(context).textTheme.bodyLarge?.color
                      : Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                ),
              ),
            ),
          ),
        ),
      ));

      if (!isSelected) {
        children.add(Positioned.fromRect(
          rect: r,
          child: GestureDetector(
            onTap: () {
              _controller!.value = pos;
            },
          ),
        ));
      } else if (widget.allowSelectedIconCallback) {
        Rect selectedRect = Rect.fromLTWH(r.left, 0, r.width, fullHeight);
        children.add(Positioned.fromRect(
          rect: selectedRect,
          child: ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(40.0)),
            child: GestureDetector(onTap: _selectedCallback),
          ),
        ));
      }
    });

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Stack(children: children),
    );
  }

  void _setSelectedPos(int? pos) {
    previousSelectedPos = selectedPos;
    selectedPos = pos;

    itemsController.forward(from: 0.0);

    selectedPosAnimation = makeSelectedPosAnimation(
        previousSelectedPos!.toDouble(), selectedPos!.toDouble());
    selectedPosAnimation.addListener(onSelectedPosAnimate);

    _selectedCallback();
  }

  void _selectedCallback() {
    if (widget.selectedCallback != null) {
      widget.selectedCallback!(selectedPos);
    }
  }

  @override
  void dispose() {
    itemsController.dispose();
    _controller!.removeListener(_newSelectedPosNotify);
    super.dispose();
  }
}

class CircularBottomNavigationController extends ValueNotifier<int?> {
  CircularBottomNavigationController(int? value) : super(value);
}
