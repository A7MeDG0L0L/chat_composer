import 'package:chat_composer/consts/consts.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubit/recordaudio_cubit.dart';

class MessageField extends StatefulWidget {
  final FocusNode? focusNode;
  final TextEditingController? controller;
  final Widget? leading;
  final List<Widget>? actions;
  final TextCapitalization? textCapitalization;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final TextStyle? textStyle;
  final InputDecoration? decoration;
  final EdgeInsetsGeometry? textPadding;

  const MessageField({
    this.actions,
    this.focusNode,
    this.controller,
    this.leading,
    this.textCapitalization,
    this.textInputAction,
    this.keyboardType,
    this.textStyle,
    this.decoration,
    this.textPadding,
  });
  @override
  _MessageFieldState createState() => _MessageFieldState();
}

class _MessageFieldState extends State<MessageField> {
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: composerHeight),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          if (widget.leading != null) widget.leading!,
          // CupertinoButton(
          //   child: const Icon(
          //     Icons.insert_emoticon_outlined,
          //     size: 25,
          //     color: Colors.grey,
          //   ),
          //   onPressed: () {},
          // ),
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 160),
              child: Padding(
                padding: widget.textPadding ??
                    const EdgeInsets.symmetric(horizontal: 8),
                child: TextField(
                  focusNode: widget.focusNode,
                  controller: widget.controller,
                  textCapitalization:
                      widget.textCapitalization ?? TextCapitalization.sentences,
                  textInputAction:
                      widget.textInputAction ?? TextInputAction.newline,
                  keyboardType: widget.keyboardType ?? TextInputType.multiline,
                  style:
                      widget.textStyle ?? const TextStyle(color: Colors.black),
                  autofocus: false,
                  maxLines: null,
                  onChanged: (s) {
                    context
                        .read<RecordAudioCubit>()
                        .toggleRecord(canRecord: s.isEmpty);
                  },
                  decoration: widget.decoration ??
                      const InputDecoration(
                        hintText: 'Type your message...',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                      ),
                ),
              ),
            ),
          ),
          if (widget.actions != null)
            BlocBuilder<RecordAudioCubit, RecordaudioState>(
              builder: (context, state) {
                if (state is RecordAudioReady) {
                  return Row(
                    children: widget.actions!,
                  );
                  // [
                  //     Padding(
                  //       padding: const EdgeInsets.symmetric(horizontal: 4),
                  //       child: InkWell(
                  //         child: const Icon(
                  //           Icons.camera_alt_outlined,
                  //           size: 25,
                  //           color: Colors.grey,
                  //         ),
                  //         onTap: () => sendImage(ImageType.Camera, context),
                  //       ),
                  //     ),
                  //     Padding(
                  //       padding: const EdgeInsets.symmetric(horizontal: 4),
                  //       child: InkWell(
                  //         child: const Icon(
                  //           Icons.image_outlined,
                  //           size: 25,
                  //           color: Colors.grey,
                  //         ),
                  //         onTap: () => sendImage(ImageType.Gallery, context),
                  //       ),
                  //     ),
                  //   ]
                }
                return Container();
              },
            ),
          const SizedBox(width: 4)
        ],
      ),
    );
  }
}