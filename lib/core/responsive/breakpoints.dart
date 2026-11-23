import 'package:flutter/material.dart';

enum DeviceType {
  mobile,
  tablet,
  desktop,
  largeDesktop,
}

class FlexBreakpoints {
  static const double mobileMax = 600;
  static const double tabletMax = 1024;
  static const double desktopMax = 1440;

  static DeviceType getDeviceType(double width) {
    if (width < mobileMax) {
      return DeviceType.mobile;
    } else if (width < tabletMax) {
      return DeviceType.tablet;
    } else if (width < desktopMax) {
      return DeviceType.desktop;
    } else {
      return DeviceType.largeDesktop;
    }
  }

  static DeviceType getDeviceTypeFromContext(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return getDeviceType(width);
  }
}

extension ContextResponsiveExtension on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;

  DeviceType get deviceType => FlexBreakpoints.getDeviceType(screenWidth);

  bool get isMobile => deviceType == DeviceType.mobile;
  bool get isTablet => deviceType == DeviceType.tablet;
  bool get isDesktop => deviceType == DeviceType.desktop || deviceType == DeviceType.largeDesktop;
  bool get isLargeDesktop => deviceType == DeviceType.largeDesktop;

  double get responsiveHorizontalPadding {
    if (isMobile) return 16.0;
    if (isTablet) return 24.0;
    if (isLargeDesktop) return 48.0;
    return 32.0; // Standard Desktop
  }
}
