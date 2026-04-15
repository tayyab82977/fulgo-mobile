import 'package:flutter/material.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';


/// CustomButton - A wrapper around ElevatedButton that accepts legacy parameters
/// This allows using the old FlatButton/RaisedButton API while using modern widgets internally
class CustomButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final Widget child;
  final Color? color;
  final Color? textColor;
  final Color? disabledColor;
  final Color? disabledTextColor;
  final EdgeInsetsGeometry? padding;
  final ShapeBorder? shape;
  final double? height;
  final double? minWidth;
  final double? elevation;
  final MaterialTapTargetSize? materialTapTargetSize;
  final Clip clipBehavior;

  const CustomButton({
    Key? key,
    required this.onPressed,
    required this.child,
    this.onLongPress,
    this.color,
    this.textColor,
    this.disabledColor,
    this.disabledTextColor,
    this.padding,
    this.shape,
    this.height,
    this.minWidth,
    this.elevation,
    this.materialTapTargetSize,
    this.clipBehavior = Clip.none,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: minWidth,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor,
          disabledBackgroundColor: disabledColor,
          disabledForegroundColor: disabledTextColor,
          padding: padding,
          shape: shape as OutlinedBorder?,
          elevation: elevation,
          tapTargetSize: materialTapTargetSize,
          minimumSize: minWidth != null || height != null
              ? Size(minWidth ?? 0, height ?? 0)
              : null,
        ),
        onPressed: onPressed,
        onLongPress: onLongPress,
        clipBehavior: clipBehavior,
        child: child,
      ),
    );
  }
}

/// CustomTextButton - A wrapper around TextButton for flat buttons
class CustomTextButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final Widget child;
  final Color? textColor;
  final EdgeInsetsGeometry? padding;
  final ShapeBorder? shape;
  final double? height;
  final double? minWidth;
  final MaterialTapTargetSize? materialTapTargetSize;

  const CustomTextButton({
    Key? key,
    required this.onPressed,
    required this.child,
    this.onLongPress,
    this.textColor,
    this.padding,
    this.shape,
    this.height,
    this.minWidth,
    this.materialTapTargetSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: minWidth,
      child: TextButton(
        style: TextButton.styleFrom(
          foregroundColor: textColor,
          padding: padding,
          shape: shape as OutlinedBorder?,
          tapTargetSize: materialTapTargetSize,
          minimumSize: minWidth != null || height != null
              ? Size(minWidth ?? 0, height ?? 0)
              : null,
        ),
        onPressed: onPressed,
        onLongPress: onLongPress,
        child: child,
      ),
    );
  }
}
