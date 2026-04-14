import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ok11/app/utils/assets.dart';

class GoogleIcon extends StatelessWidget {
  final double size;
  final Color? color;

  const GoogleIcon({super.key, this.size = 24.0, this.color});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      Assets.google,
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color!, BlendMode.srcIn)
          : null,
    );
  }
}
