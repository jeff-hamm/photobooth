import 'dart:math';

import 'package:analytics/analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:io_photobooth/assets.g.dart';
import 'package:io_photobooth/l10n/l10n.dart';
import 'package:io_photobooth/photobooth/photobooth.dart';
import 'package:io_photobooth/photobooth/widgets/side_icon_button.dart';
import 'package:io_photobooth/stickers/view/stickers_page.dart';
import 'package:photobooth_ui/photobooth_ui.dart';
import '../../config.dart' as config;

class PhotoboothPreview extends StatelessWidget {
  const PhotoboothPreview({
    required this.preview,
    required this.onSnapPressed,
    required this.seed,
    super.key,
  });
  final Widget preview;
  final VoidCallback onSnapPressed;
  final int seed;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PhotoboothBloc>().state;
//    final children = _getCharacterIcons(context,state);
    final children = _getRandomProps(context,state);
    return Stack(
      fit: StackFit.expand,
      children: [
        preview,
        Positioned.fill(
          child: GestureDetector(
            key: const Key('photoboothPreview_background_gestureDetector'),
            onTap: () {
              context.read<PhotoboothBloc>().add(const PhotoTapped());
            },
          ),
        ),
        for (final character in state.characters)
          DraggableResizable(
            key: Key(
              '''photoboothPreview_${character.asset.name}_draggableResizableAsset''',
            ),
            canTransform: character.id == state.selectedAssetId,
            onUpdate: (update) {
              context.read<PhotoboothBloc>().add(
                    PhotoCharacterDragged(character: character, update: update),
                  );
            },
            onDelete: () =>
              context
                .read<PhotoboothBloc>()
                .add(PhotoCharacterToggled(character: character.asset)),
            constraints: _getAnimatedSpriteConstraints(character.asset),
            size: _getAnimatedSpriteSize(character.asset),
            child: _AnimatedCharacter(asset: character.asset)
          ),
                          const DraggableStickers(),
        CharactersIconLayout(children: children),

        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: ShutterButton(
              key: const Key('photoboothPreview_photo_shutterButton'),
              onCountdownComplete: onSnapPressed,
            ),
          ),
        ),
      ],
    );
  }
  List<Widget> _getRandomProps(BuildContext context,PhotoboothState state) {
      final random = Random(seed);
    final assets = <Asset>[];
     for (var i = 0; i < config.NumRandomProps; i++) {
        
        Asset? prop;
        do {
          prop = Assets.randomProps.elementAt(random.nextInt(Assets.randomProps.length));
        } while(prop == null || state.stickers.any((s) => s.asset.name == prop!.name) || assets.contains(prop));
        assets.add(prop);
     }
     return <Widget>[
      for(var prop in assets)
        SideIconButton(
            key: Key(prop.name),
          icon: AssetImage(prop.path),
          isSelected: state.isSelected(prop.name),
          onPressed: () {
            trackEvent(
              category: 'button',
              action: 'click-add-friend',
              label: 'add-sticker-friend',
            );
            context
                .read<PhotoboothBloc>()
                .add(PhotoCharacterToggled(character: prop!));
          },
      )];
}

}

List<Widget> _getCharacterIcons(BuildContext context,PhotoboothState state) {
    final l10n = context.l10n;
  return <Widget>[
      CharacterIconButton(
        key: const Key('photoboothView_dash_characterIconButton'),
        icon: const AssetImage('assets/icons/dash_icon.png'),
        label: l10n.dashButtonLabelText,
        isSelected: state.isDashSelected,
        onPressed: () {
          trackEvent(
            category: 'button',
            action: 'click-add-friend',
            label: 'add-dash-friend',
          );
          context
              .read<PhotoboothBloc>()
              .add(const PhotoCharacterToggled(character: Assets.dash));
        },
      ),
      CharacterIconButton(
        key: const Key('photoboothView_sparky_characterIconButton'),
        icon: const AssetImage('assets/icons/sparky_icon.png'),
        label: l10n.sparkyButtonLabelText,
        isSelected: state.isSparkySelected,
        onPressed: () {
          trackEvent(
            category: 'button',
            action: 'click-add-friend',
            label: 'add-sparky-friend',
          );
          context
              .read<PhotoboothBloc>()
              .add(const PhotoCharacterToggled(character: Assets.sparky));
        },
      ),
      CharacterIconButton(
        key: const Key('photoboothView_android_characterIconButton'),
        icon: const AssetImage('assets/icons/android_icon.png'),
        label: l10n.androidButtonLabelText,
        isSelected: state.isAndroidSelected,
        onPressed: () {
          trackEvent(
            category: 'button',
            action: 'click-add-friend',
            label: 'add-bugdroid-friend',
          );
          context
              .read<PhotoboothBloc>()
              .add(const PhotoCharacterToggled(character: Assets.android));
        },
      ),
      CharacterIconButton(
        key: const Key('photoboothView_dino_characterIconButton'),
        icon: const AssetImage('assets/icons/dino_icon.png'),
        label: l10n.dinoButtonLabelText,
        isSelected: state.isDinoSelected,
        onPressed: () {
          trackEvent(
            category: 'button',
            action: 'click-add-friend',
            label: 'add-dino-friend',
          );
          context
              .read<PhotoboothBloc>()
              .add(const PhotoCharacterToggled(character: Assets.dino));
        },
      ),
    ];
}
BoxConstraints? _getAnimatedSpriteConstraints(Asset asset) {
  final sprite = _getAnimatedSprite(asset.name);

  final size = sprite?.sprites.size ?? asset.size;
  return BoxConstraints(
    minWidth: size.width * config.MinCharacterScale,
    minHeight: size.height * config.MinCharacterScale,
  );
}

Size _getAnimatedSpriteSize(Asset asset) {
  final sprite = _getAnimatedSprite(asset.name);
  return (sprite?.sprites.size ?? asset.size) * config.InitialCharacterScale;
}

AnimatedSprite? _getAnimatedSprite(String name) {
  switch (name) {
    case 'android':
      return const AnimatedAndroid();
    case 'dash':
      return const AnimatedDash();
    case 'dino':
      return const AnimatedDino();
    case 'sparky':
      return const AnimatedSparky();
    default:
      return null;
  }
}

class _AnimatedCharacter extends StatelessWidget {
  const _AnimatedCharacter({required this.asset});

  final Asset asset;

  @override
  Widget build(BuildContext context) {
    return _getAnimatedSprite(asset.name) ?? SizedBox.expand(
              child: Image.asset(
                asset.path,
                fit: BoxFit.fill,
                gaplessPlayback: true,
              ),
                    );
  }
}

class CharactersIconLayout extends StatelessWidget {
  const CharactersIconLayout({
    required this.children,
    super.key,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    return orientation == Orientation.landscape
        ? LandscapeCharactersIconLayout(children: children)
        : PortraitCharactersIconLayout(children: children);
  }
}

@visibleForTesting
class LandscapeCharactersIconLayout extends StatelessWidget {
  const LandscapeCharactersIconLayout({
    required this.children,
    super.key,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CharactersCaption(),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: children,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

@visibleForTesting
class PortraitCharactersIconLayout extends StatelessWidget {
  const PortraitCharactersIconLayout({
    required this.children,
    super.key,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: children,
              ),
            ),
          ),
          BlocBuilder<PhotoboothBloc, PhotoboothState>(
            builder: (context, state) {
              if (state.isAnyCharacterSelected) return const SizedBox();
              return const CharactersCaption();
            },
          )
        ],
      ),
    );
  }
}
