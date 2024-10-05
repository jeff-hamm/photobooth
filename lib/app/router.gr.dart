// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i6;
import 'package:flutter/foundation.dart' as _i7;
import 'package:flutter/material.dart' as _i9;
import 'package:io_photobooth/common/models/ImagePath.dart' as _i8;
import 'package:io_photobooth/landing/view/landing_page.dart' as _i1;
import 'package:io_photobooth/photobooth/view/photobooth_page.dart' as _i2;
import 'package:io_photobooth/photopicker/picker_page.dart' as _i3;
import 'package:io_photobooth/share/view/share_page.dart' as _i4;
import 'package:io_photobooth/stickers/view/stickers_page.dart' as _i5;

/// generated route for
/// [_i1.LandingPage]
class LandingRoute extends _i6.PageRouteInfo<void> {
  const LandingRoute({List<_i6.PageRouteInfo>? children})
      : super(
          LandingRoute.name,
          initialChildren: children,
        );

  static const String name = 'LandingRoute';

  static _i6.PageInfo page = _i6.PageInfo(
    name,
    builder: (data) {
      return const _i1.LandingPage();
    },
  );
}

/// generated route for
/// [_i2.PhotoboothPage]
class PhotoboothRoute extends _i6.PageRouteInfo<PhotoboothRouteArgs> {
  PhotoboothRoute({
    _i7.Key? key,
    bool isLocked = false,
    bool? isDebug,
    List<_i6.PageRouteInfo>? children,
  }) : super(
          PhotoboothRoute.name,
          args: PhotoboothRouteArgs(
            key: key,
            isLocked: isLocked,
            isDebug: isDebug,
          ),
          initialChildren: children,
        );

  static const String name = 'PhotoboothRoute';

  static _i6.PageInfo page = _i6.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PhotoboothRouteArgs>(
          orElse: () => const PhotoboothRouteArgs());
      return _i6.WrappedRoute(
          child: _i2.PhotoboothPage(
        key: args.key,
        isLocked: args.isLocked,
        isDebug: args.isDebug,
      ));
    },
  );
}

class PhotoboothRouteArgs {
  const PhotoboothRouteArgs({
    this.key,
    this.isLocked = false,
    this.isDebug,
  });

  final _i7.Key? key;

  final bool isLocked;

  final bool? isDebug;

  @override
  String toString() {
    return 'PhotoboothRouteArgs{key: $key, isLocked: $isLocked, isDebug: $isDebug}';
  }
}

/// generated route for
/// [_i2.PhotoboothView]
class PhotobothViewRoute extends _i6.PageRouteInfo<void> {
  const PhotobothViewRoute({List<_i6.PageRouteInfo>? children})
      : super(
          PhotobothViewRoute.name,
          initialChildren: children,
        );

  static const String name = 'PhotobothViewRoute';

  static _i6.PageInfo page = _i6.PageInfo(
    name,
    builder: (data) {
      return const _i2.PhotoboothView();
    },
  );
}

/// generated route for
/// [_i3.PickerPage]
class PickerRoute extends _i6.PageRouteInfo<PickerRouteArgs> {
  PickerRoute({
    List<_i8.ImagePath>? images,
    List<_i6.PageRouteInfo>? children,
  }) : super(
          PickerRoute.name,
          args: PickerRouteArgs(images: images),
          initialChildren: children,
        );

  static const String name = 'PickerRoute';

  static _i6.PageInfo page = _i6.PageInfo(
    name,
    builder: (data) {
      final args =
          data.argsAs<PickerRouteArgs>(orElse: () => const PickerRouteArgs());
      return _i3.PickerPage(images: args.images);
    },
  );
}

class PickerRouteArgs {
  const PickerRouteArgs({this.images});

  final List<_i8.ImagePath>? images;

  @override
  String toString() {
    return 'PickerRouteArgs{images: $images}';
  }
}

/// generated route for
/// [_i4.SharePage]
class ShareRoute extends _i6.PageRouteInfo<ShareRouteArgs> {
  ShareRoute({
    _i9.Key? key,
    String? imageId,
    List<_i6.PageRouteInfo>? children,
  }) : super(
          ShareRoute.name,
          args: ShareRouteArgs(
            key: key,
            imageId: imageId,
          ),
          initialChildren: children,
        );

  static const String name = 'ShareRoute';

  static _i6.PageInfo page = _i6.PageInfo(
    name,
    builder: (data) {
      final args =
          data.argsAs<ShareRouteArgs>(orElse: () => const ShareRouteArgs());
      return _i4.SharePage(
        key: args.key,
        imageId: args.imageId,
      );
    },
  );
}

class ShareRouteArgs {
  const ShareRouteArgs({
    this.key,
    this.imageId,
  });

  final _i9.Key? key;

  final String? imageId;

  @override
  String toString() {
    return 'ShareRouteArgs{key: $key, imageId: $imageId}';
  }
}

/// generated route for
/// [_i5.StickersPage]
class StickersRoute extends _i6.PageRouteInfo<void> {
  const StickersRoute({List<_i6.PageRouteInfo>? children})
      : super(
          StickersRoute.name,
          initialChildren: children,
        );

  static const String name = 'StickersRoute';

  static _i6.PageInfo page = _i6.PageInfo(
    name,
    builder: (data) {
      return const _i5.StickersPage();
    },
  );
}
