import 'dart:async';
import 'package:flutter/scheduler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A customizable search text field widget that allows users to input and search for text.
///
/// This widget is a stateful widget that provides a text field for user input and can be
/// used to implement search functionality in your Flutter application.
///
/// The generic type parameter `T` allows you to specify the type of the search results.
///
/// Example usage:
/// ```dart
/// SearchTextfield<String>(
///   // Add your parameters here
/// );
/// ```
///
/// You can customize the appearance and behavior of the search text field by providing
/// various parameters and callbacks.
class SearchTextfield<T> extends StatefulWidget {
  /// The initial data to be displayed in the search field.
  final List<T>? initialData;

  /// The duration to wait before triggering the search after the user stops typing.
  final Duration debounceDuration = const Duration(milliseconds: 300);

  /// A function that returns a future list of items based on the search query.
  ///
  /// - `context` - The build context.
  /// - `query` - The search query string.
  final Future<List<T>> Function(BuildContext context, String query) future;

  /// A function that builds a widget for each item in the search results.
  ///
  /// - `context` - The build context.
  /// - `item` - The item to build the widget for.
  final Widget Function(BuildContext context, T item) itemBuilder;

  /// A widget to display while the search results are loading.
  ///
  /// - `context` - The build context.
  final Widget Function(BuildContext context)? onLoading;

  /// A callback function that is called when an item is selected.
  ///
  /// - `context` - The build context.
  /// - `item` - The selected item.
  final String? Function(BuildContext context, T item)? onSelected;

  final Function(String value)? onSubmitted;

  /// The decoration to show around the text field.
  ///
  /// This can be used to add borders, labels, icons, etc.
  final InputDecoration? decoration;

  /// The position of the popup menu relative to the search text field.
  final PopupMenuPosition popupPosition;

  /// An optional offset to apply to the popup menu's position.
  final Offset? popupOffset;

  /// This can be used to control the focus of the text field.
  final FocusNode? focusNode;

  /// The controller for the text field.
  ///
  /// This can be used to read and modify the text being edited.
  final TextEditingController? controller;

  /// The type of keyboard to use for editing the text.
  ///
  /// This can be used to specify the type of input expected, such as text, number, email, etc.
  final TextInputType? keyboardType;

  /// The action button to use for the keyboard.
  ///
  /// This can be used to specify the action button on the keyboard, such as done, next, search, etc.
  final TextInputAction? textInputAction;

  /// How the text should be aligned horizontally.
  ///
  /// This can be used to align the text to the left, right, or center.
  final TextAlign textAlign;

  /// The maximum number of lines to show at one time.
  ///
  /// This can be used to limit the height of the text field.
  final int maxLines;

  /// The minimum number of lines to show at one time.
  ///
  /// This can be used to ensure the text field is at least a certain height.
  final int? minLines;

  /// The maximum number of characters to allow in the text field.
  ///
  /// This can be used to limit the length of the input.
  final int? maxLength;

  /// The appearance of the keyboard.
  ///
  /// This can be used to specify the brightness of the keyboard, such as light or dark.
  final Brightness? keyboardAppearance;

  /// A [ConstrainedBox] that defines the constraints for the menu.
  ///
  /// This is used to limit the size of the menu that appears when the
  /// user interacts with the search text field.
  final BoxConstraints menuConstraints;

  final List<TextInputFormatter>? inputFormatters;

  /// This widget provides a customizable text field for search functionality.
  ///
  /// The `SearchTextfield` widget can be used to create a search input field
  /// with various customization options such as hint text, text style, and more.
  const SearchTextfield({
    super.key,
    required this.future,
    required this.itemBuilder,
    required this.menuConstraints,
    this.initialData = const [],
    this.onSelected,
    this.decoration,
    this.focusNode,
    this.controller,
    this.keyboardType,
    this.textInputAction,
    this.textAlign = TextAlign.start,
    this.maxLines = 1,
    this.minLines = 1,
    this.maxLength,
    this.keyboardAppearance,
    this.onLoading,
    this.popupPosition = PopupMenuPosition.under,
    this.popupOffset,
    this.onSubmitted,
    this.inputFormatters,
  });

  @override
  State<SearchTextfield<T>> createState() => _SearchTextfieldState<T>();
}

class _SearchTextfieldState<T> extends State<SearchTextfield<T>> {
  late TextEditingController controller;
  late FocusNode focusNode;
  final LayerLink link = LayerLink();
  OverlayEntry? _overlayEntry;

  Timer? debouncer;

  @override
  void initState() {
    controller = widget.controller ?? TextEditingController();
    focusNode = widget.focusNode ?? FocusNode();
    focusNode.addListener(_focusNodeListner);
    SchedulerBinding.instance.addPostFrameCallback((value) {
      _reset();
    });
    super.initState();
  }

  void _focusNodeListner() {
    if (focusNode.hasFocus) {
      _showMenu();
    } else {
      if (_overlayEntry != null) {
        _remove();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: link,
      child: TextField(
        controller: controller,
        decoration: widget.decoration,
        focusNode: focusNode,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        textAlign: widget.textAlign,
        maxLines: widget.maxLines,
        minLines: widget.minLines,
        maxLength: widget.maxLength,
        onSubmitted: widget.onSubmitted,
        keyboardAppearance: widget.keyboardAppearance,
        inputFormatters: widget.inputFormatters,
        onChanged: (query) async {
          debouncer?.cancel();
          debouncer = Timer(widget.debounceDuration, () => _overlayEntry!.markNeedsBuild());
        },
      ),
    );
  }

  OverlayEntry _overlay() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Size overlaySize = renderBox.size;
    return OverlayEntry(
      builder: (context) {
        return Positioned(
          width: overlaySize.width,
          child: CompositedTransformFollower(
            link: link,
            showWhenUnlinked: false,
            offset: Offset(widget.popupOffset?.dx ?? 0, overlaySize.height + (widget.popupOffset?.dy ?? 0)),
            child: Material(
              color: Theme.of(context).colorScheme.surface,
              elevation: 4.0,
              child: ConstrainedBox(
                constraints: widget.menuConstraints,
                child: FutureBuilder<List<T>>(
                  future: widget.future(context, controller.text),
                  initialData: widget.initialData ?? [],
                  builder: (context, snapshot) {
                    if (!snapshot.hasData && snapshot.connectionState == ConnectionState.waiting) {
                      return widget.onLoading?.call(context) ?? SizedBox.shrink();
                    }
                    return ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: snapshot.data?.length ?? 0,
                      itemBuilder: (context, index) {
                        var item = snapshot.data![index];
                        return GestureDetector(
                          onTap: () {
                            controller.text = widget.onSelected?.call(context, item) ?? "";
                            _remove();
                            focusNode.unfocus();
                          },
                          child: widget.itemBuilder(context, item),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showMenu() async {
    _reset();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _remove() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _reset() {
    _overlayEntry = _overlay();
  }

  @override
  void dispose() {
    controller.dispose();
    debouncer?.cancel();
    focusNode.removeListener(_focusNodeListner);
    focusNode.dispose();
    super.dispose();
  }
}
