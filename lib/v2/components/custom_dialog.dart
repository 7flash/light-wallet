import 'package:flutter/material.dart';
import 'package:seeds/v2/components/flat_button_long.dart';
import 'package:seeds/v2/constants/app_colors.dart';

const double padding = 20;
const double avatarRadius = 40;

/// A custom dialog with top icon that can be used in multiple screens
class CustomDialog extends StatelessWidget {
  /// Top icon dialog
  final Widget icon;

  /// Dialog body content
  final List<Widget> children;

  /// Default title empty
  final String leftButtonTitle;

  /// Require define leftButtonTitle
  final VoidCallback? onLeftButtonPressed;

  /// Default title empty
  final String rightButtonTitle;

  /// Require define rightButtonTitle
  final VoidCallback? onRightButtonPressed;

  /// Default title empty
  final String singleLargeButtonTitle;

  /// Default Navigator pop
  final VoidCallback? onSingleLargeButtonPressed;

  const CustomDialog({
    Key? key,
    required this.icon,
    required this.children,
    this.leftButtonTitle = '',
    this.onLeftButtonPressed,
    this.rightButtonTitle = '',
    this.onRightButtonPressed,
    this.singleLargeButtonTitle = '',
    this.onSingleLargeButtonPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      child: Stack(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(
                left: padding, top: avatarRadius + padding - 10, right: padding, bottom: padding + 10),
            margin: const EdgeInsets.only(top: avatarRadius),
            decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                color: AppColors.whiteYellow,
                borderRadius: BorderRadius.circular(18.0),
                boxShadow: const [
                  BoxShadow(color: AppColors.black, offset: Offset(0, 10), blurRadius: 10),
                ]),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: children,
                ),
                if (leftButtonTitle.isNotEmpty || rightButtonTitle.isNotEmpty)
                  Column(
                    children: [
                      const SizedBox(height: 30),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Row(
                          children: [
                            if (leftButtonTitle.isNotEmpty)
                              Expanded(
                                child: FlatButtonLong(
                                  title: leftButtonTitle,
                                  onPressed: onLeftButtonPressed,
                                  color: AppColors.white,
                                ),
                              ),
                            if (leftButtonTitle.isNotEmpty) const SizedBox(width: 10),
                            if (rightButtonTitle.isNotEmpty)
                              Expanded(
                                child: FlatButtonLong(
                                  title: rightButtonTitle,
                                  onPressed: onRightButtonPressed,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                if (leftButtonTitle.isEmpty && rightButtonTitle.isEmpty && singleLargeButtonTitle.isNotEmpty)
                  Column(
                    children: [
                      const SizedBox(height: 30),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: FlatButtonLong(
                          title: singleLargeButtonTitle,
                          onPressed: onSingleLargeButtonPressed ?? () => Navigator.pop(context),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          Positioned(
            left: padding,
            right: padding,
            child: CircleAvatar(
              backgroundColor: Colors.transparent,
              radius: avatarRadius,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.green1.withOpacity(0.20),
                      offset: const Offset(0.0, 1.0),
                      blurRadius: 6.0,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(avatarRadius)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: icon,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
