import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpInputField extends StatefulWidget {
  const OtpInputField({
    required this.length,
    required this.onChanged,
    required this.onCompleted,
    super.key,
  });

  final int length;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onCompleted;

  @override
  State<OtpInputField> createState() => _OtpInputFieldState();
}

class _OtpInputFieldState extends State<OtpInputField> {
  late final FocusNode _focusNode;
  late final TextEditingController _controller;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _controller = TextEditingController();

    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_onFocusChange)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _focusNode.requestFocus();
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Invisible text field that captures all keyboard input
          Opacity(
            opacity: 0,
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(widget.length),
              ],
              onChanged: (val) {
                setState(() {});
                widget.onChanged(val);
                if (val.length == widget.length) {
                  widget.onCompleted(val);
                }
              },
              autofocus: true,
              enableInteractiveSelection: false,
              showCursor: false,
            ),
          ),

          // Visual 6-box representation
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.length, (index) {
              final text = _controller.text;
              final isCurrentIndex = text.length == index && _isFocused;
              final hasValue = index < text.length;
              final char = hasValue ? text[index] : '';

              // Using the HTML mockup's styles
              var borderColor = const Color(0xFFE5E7EB);
              var bgColor = const Color(0xFFFFFFFF);

              if (isCurrentIndex) {
                borderColor = const Color(0xFFFF4040); // blinking cursor state
                bgColor = const Color(0xFFFF4040).withValues(alpha: 0.04);
              } else if (hasValue) {
                borderColor = const Color(0xFFFF4040); // filled state
                bgColor = const Color(0xFFFFFFFF);
              }

              return Flexible(
                child: Container(
                  margin: EdgeInsets.only(
                    right: index == widget.length - 1 ? 0 : 8,
                  ),
                  constraints: const BoxConstraints(maxWidth: 52),
                  height: 56,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: borderColor,
                      width: hasValue || isCurrentIndex ? 2 : 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: isCurrentIndex
                      ? const _BlinkingCursor()
                      : Text(
                          char,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111827),
                            fontFamily: 'Inter',
                          ),
                        ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _BlinkingCursor extends StatefulWidget {
  const _BlinkingCursor();

  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    unawaited(_controller.repeat(reverse: true));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 2,
        height: 28,
        color: const Color(0xFFFF4040),
      ),
    );
  }
}
