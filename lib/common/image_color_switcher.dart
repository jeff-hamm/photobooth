import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'package:image/image.dart' as External;
import 'package:io_photobooth/common/widgets.dart';
import 'package:io_photobooth/theme_config.dart';
//import 'package:image/image.dart' as External;

class IconAssetColorSwitcher extends StatelessWidget {
  const IconAssetColorSwitcher(
    this.imagePath, {
    this.toColor = PhotoboothColors.primary,
    this.fromColor = PhotoboothColors.blue,
    super.key,
  });
  final Color toColor;
  final Color fromColor;
  final String imagePath;
  @override
  Widget build(BuildContext context) {
    return ResponsiveThemeBuilder(builder: (context, theme, _, __) {
      final iconSize = (theme.iconButtonTheme.style?.fixedSize?.resolve({}) ??
          toSize(theme.iconButtonTheme.style?.iconSize) ??
          Size(theme.iconTheme!.size!, theme.iconTheme!.size!))!;

      return AssetColorSwitcher(
        imagePath,
        fromColor: fromColor,
        toColor: toColor,
        width: iconSize.width + AppTheme.assetIconPadding,
        height: iconSize.height + AppTheme.assetIconPadding,
        assetWidth: iconSize.width + AppTheme.assetIconPadding,
        assetHeight: iconSize.height + AppTheme.assetIconPadding,
      );
    });
  }

  Size? toSize(WidgetStateProperty<double?>? iconSize) {
    final size = iconSize?.resolve({});
    if (size == null) {
      return null;
    }
    return Size(size, size);
  }
}

class AssetColorSwitcher extends StatefulWidget {
  AssetColorSwitcher(this.imagePath,
      {Color toColor = PhotoboothColors.accent,
      Color fromColor = PhotoboothColors.blue,
//      required this.colorMap,
      super.key,
      this.fit,
      this.filterQuality,
      this.width,
      this.height,
      this.assetWidth,
      this.assetHeight})
      : colorMap = {fromColor: toColor};
  final double? width;
  final double? height;
  final double? assetWidth;
  final double? assetHeight;
  final FilterQuality? filterQuality;
  final BoxFit? fit;

  /// Holds the Image Path
  final String imagePath;
  final Map<Color, Color> colorMap;
//  final Color imageColor;

  @override
  State createState() => _AssetColorSwitcherState();
}

class _AssetColorSwitcherState extends State<AssetColorSwitcher> {
  ui.Image? image;

  /// Holds the Image in Byte Format
  Uint8List? imageBytes;

  // @override
  // void initState() {
  //   Image.asset(widget.imagePath).image.resolve(const ImageConfiguration())
  //     .addListener(ImageStreamListener(
  //       (info, _) {
  //         image = info.image;
  //         info.image.toByteData(format: ui.ImageByteFormat.rawRgba).then(
  //         (data)  {
  //           final buffer = data!.buffer.asUint8List();
  //           switchColor(info.image, buffer);
  //         }

  //             );
  //       }));
  //   super.initState();
  // }

//   /// A function that switches the image color.
  void switchColor(ui.Image image, Uint8List pixels) {
    // final asset =
    //     ExactAssetImage(widget.imagePath).resolve(configuration).
    // asset.image.resolve(ImageConfiguration()).addListener(ImageStreamListener((image, synchronousCall) =>{
    //   image.image.toByteData()
    // }))

    // // Decode the bytes to [Image] type
    // final image = External.decodeNamedImage(widget.imagePath, bytes);
    // final bytes = image.toUint8List()
    // if(image == null) {
    //   throw Exception("Failed to decode the image");
    // }
    // Convert the [Image] to RGBA formatted pixels
//   final pixels = image.getBytes(order: External.ChannelOrder.rgba, alpha: 255);
    // Get the Pixel Length
//    final length = pixels.lengthInBytes;
    // for(final pixel in image.data!) {
    //   // Detect the light blue color & switch it with the desired color's RGB value.
    //   for(final c in widget.colorMap.entries) {
    //     if (pixel.r == c.key.red && pixel.g == c.key.green && pixel.b == c.key.blue) {
    //       image.data[pixel.] = c.value.red;
    //       pixel.red = c.value.red;
    //       pixel.green = c.value.green;
    //       pixel.blue = c.value.blue;
    //     }
    //   }
    // }
    for (var i = 0; i < pixels.length; i += 4) {
      ///           PIXELS
      /// =============================
      /// | i | i + 1 | i + 2 | i + 3 |
      /// =============================
      // pixels[i] represents Red
      // pixels[i + 1] represents Green
      // pixels[i + 2] represents Blue
      // pixels[i + 3] represents Alpha
      final r = pixels[i];
      final g = pixels[i + 1];
      final b = pixels[i + 2];

      // Detect the light blue color & switch it with the desired color's RGB value.
      for (final c in widget.colorMap.entries) {
        if (r > 240 && g > 240 && b > 240) {
          continue;
        }
        if (r < 10 && g < 10 && b < 10) {
          continue;
        }
        final deltaR = c.value.red - c.key.red;
        final deltaG = c.value.green - c.key.green;
        final deltaB = c.value.blue - c.key.blue;
//        if (r == c.key.red && g == c.key.green && b == c.key.blue) {
        pixels[i] = (r + deltaR).clamp(0, 255);
        pixels[i + 1] = (g + deltaG).clamp(0, 255);
        pixels[i + 2] = (b + deltaB).clamp(0, 255);
        //      }
      }
      // if (pixels[i] == 189 && pixels[i + 1] == 212 && pixels[i + 2] == 222) {
      //   pixels[i] = widget.color.shade300.red;
      //   pixels[i + 1] = widget.color.shade300.green;
      //   pixels[i + 2] = widget.color.shade300.blue;
      // }

      // // Detect the darkish blue shade & switch it with the desired color's RGB value.
      // else if (pixels[i] == 63 && pixels[i + 1] == 87 && pixels[i + 2] == 101) {
      //   pixels[i] = widget.color.shade900.red;
      //   pixels[i + 1] = widget.color.shade900.green;
      //   pixels[i + 2] = widget.color.shade900.blue;
      // }
    }
    ui.decodeImageFromPixels(
        pixels,
        image!.width,
        image!.height,
        ui.PixelFormat.rgba8888,
        (data) =>
//        this.image = data;
            setState(() {
              this.image = data;
//              imageBytes = data.asUint8List();
//              this.image = switchedImage;
            }));
//      });

//    final png = External.encodeNamedImage(widget.imagePath, image!);
//    return image!;
//    return pixels;
    // ui.in(pixels, image!.width, image!.height, ui.PixelFormat.rgba8888);
    // return decodeImageFromList(pixels);
  }

  @override
  Widget build(BuildContext context) {
    return Image.asset(widget.imagePath);
    // final imageWidget = image == null
    //     ? Center(child: CircularProgressIndicator())
    //     : RawImage(image: this.image!,
    //         fit: widget.fit,
    //         width: widget.assetWidth,
    //         height: widget.assetHeight,
    //         filterQuality: widget.filterQuality ?? FilterQuality.medium);
    // if(widget.width != null || widget.height != null) {
    //   return SizedBox(width: widget.width,
    //                    height: widget.height,
    //                 child:imageWidget);
    // }
    // return imageWidget;
//     FutureBuilder(
//            future: ,
//            builder: (_, AsyncSnapshot<Uint8List> snapshot) {
//              return snapshot.hasData
//                  ?
//                  Container(
    //                    width: MediaQuery.of(context).size.width * 0.9,
//                      decoration: BoxDecoration(
//                          image: ,
//                           DecorationImage(
//                               image:
// //                               Image.memory(
//                        imageBytes!,
//                      ).image
//                      )),
//                    )
//                  : CircularProgressIndicator();
//            },
//          );
  }
//   @override
//   Widget build(BuildContext context) {
//     return  SizedBox(
//                       width: 100,
//                       height: 100,
//                       child:
//           //             ColorFiltered(
//           // colorFilter: ColorFilter.mode(widget.imageColor, BlendMode.hue),
//           // child:
//           Image.asset(
//                         widget.imagePath,
// //                        color: widget.imageColor,
// //                        colorBlendMode: BlendMode.hue,

//                         ))
// //                        )
//  ;
// //                       decoration: BoxDecoration(
// //                           image: DecorationImage(
// //                           image:
// //                         color: widget.imageColor,
// //                         colorBlendMode: BlendMode.overlay,
// // //                        switchColor(imageBytes!),
// //                       ).image)),
// //                    ));
//   }
}
