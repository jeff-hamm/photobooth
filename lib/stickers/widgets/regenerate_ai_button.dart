import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:io_photobooth/common/camera_button.dart';
import 'package:io_photobooth/photobooth/photobooth.dart';
import 'package:io_photobooth/share/bloc/share_bloc.dart';

class RegenerateAiButton extends StatelessWidget {
  const RegenerateAiButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select(
      (ShareBloc bloc) => bloc.state.aiStatus.isLoading,
    );
    final bloc = context.watch<ShareBloc>();
        final image = context.watch<PhotoboothBloc>().state.selectedImage;
    return BlocListener<ShareBloc, ShareState>(
      listener: _onShareStateChange,
      child: RotatingWidget(
          isLoading: isLoading,
          child: CameraButton(
              onPressed: () => bloc.add(GenerateAiTapped(image)),
              icon: 'assets/icons/retake_button_icon.png')),
    );
  }

  void _onShareStateChange(BuildContext context, ShareState state) {
    if (!state.aiStatus.isLoading) {
      final booth = context.read<PhotoboothBloc>();
      final firstItem = state.aiImages?.isNotEmpty == true
          ? state.aiImages!.first
          : emptyImage;
//      if (booth.state.aiImage != firstItem) {
        booth.add(GenerateAiPhotoBoothSucceeded(
            imageUrls: state.aiImages ?? [], aiPrompt: state.aiPrompt));
      }
    }
}

class RotatingWidget extends StatefulWidget {
  const RotatingWidget(
      {required this.child,
      this.isLoadingFn,
      this.isLoading = true,
      this.alignment = Alignment.center,
      this.filterQuality,
      this.duration = const Duration(seconds: 1),
      super.key});

  final Duration duration;
  final Widget child;
  final Alignment alignment;
  final FilterQuality? filterQuality;
  final bool Function(BuildContext context)? isLoadingFn;
  final bool isLoading;

  @override
  State<RotatingWidget> createState() => _RotatingWidgetState();
}

class _RotatingWidgetState extends State<RotatingWidget>
    with SingleTickerProviderStateMixin {
  double turns = 0.0;

  void _changeRotation() {
    setState(() => turns += 1.0 / 8.0);
  }

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = widget.isLoadingFn?.call(context) ?? widget.isLoading;
    if (isLoading) {
      _controller.repeat();
    } else {
//      _controller.stop();
      _controller.reset();
    }
    return RotationTransition(
      turns: _controller,
      alignment: widget.alignment,
      filterQuality: widget.filterQuality,
      child: widget.child,
    );
  }
}
