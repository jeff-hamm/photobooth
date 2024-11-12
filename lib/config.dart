import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:io_photobooth/common/butts_repository.dart';
import 'package:io_photobooth/params.dart';
export './params.dart';
export './theme_config.dart';

const CameraResolution=ResolutionPreset.max;
const CameraImageFormat=ImageFormatGroup.jpeg;
const TimeoutDuration = Duration(seconds: 60);
const ShareDuration=Duration(hours: 1);
const NumRandomProps=4;
const SideIconButtonSizeLandscape = 120.0;
const SideIconButtonSizePortait = 90.0;
const InitialCharacterScale = 0.8;
const MinCharacterScale = 0.1;
const PickerWidth = 3;
const int? NumAiImages = 2;
const ShutterDuration = const Duration(milliseconds: 150);
const IsDebug =
    kDebugMode || const bool.fromEnvironment('IS_DEBUG', defaultValue: false);
//final ShareUrl = Uri.https('infinitebutts.com','/api/butts/upload');;
final AiPrompt = const bool.hasEnvironment('AI_PROMPT')
    ? const String.fromEnvironment('AI_PROMPT')
    : "cinematic film still, photo of people in a mystical forest, in the style of hyper-realistic fantasy, sony fe 12-24mm f/2.8 gm, close up, 32k uhd, light navy and light amber, kushan empirem alluring, perfect skin, seductive, amazing quality, wallpaper, analog film grain";
const AiNegativePrompt = const String.fromEnvironment('AI_NEGATIVE_PROMPT',
    defaultValue:
        "ugly, deformed, noisy, blurry, low contrast, text,  (low quality, worst quality:1.4), text, signature, watermark, extra limbs, ((nipples))");
final EnableAi = const bool.hasEnvironment('ENABLE_AI') ? const bool.fromEnvironment('ENABLE_AI') : true;
final DefaultImageType = ImageType.photo;
final AiImageType = ImageType.photo;
final IsOnline = const bool.hasEnvironment('IS_ONLINE')
    ? const bool.fromEnvironment('IS_ONLINE')
    : true;
final AiUpload = const bool.hasEnvironment('AI_UPLOAD')
    ? const bool.fromEnvironment('AI_UPLOAD')
    : true;
final PhotosPerPress = const bool.hasEnvironment('PHOTOS_PER_PRESS')
    ? const int.fromEnvironment('PHOTOS_PER_PRESS')
    : 3;
final EnableCharacters = const bool.fromEnvironment('ENABLE_CHARACTERS',
    defaultValue: EnablePropsDefault);
final EnableStickers = const bool.fromEnvironment('ENABLE_STICKERS',
    defaultValue: EnablePropsDefault);
