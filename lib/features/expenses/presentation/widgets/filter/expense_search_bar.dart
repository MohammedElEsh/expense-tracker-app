// Expense Filter - Search Bar Widget
import 'package:flutter/material.dart';

class ExpenseSearchBar extends StatefulWidget {
  final Function(String) onSearchChanged;
  final VoidCallback? onFilterToggle;
  final int activeFilterCount;
  final bool isRTL;
  final TextEditingController? controller;
  final FocusNode? focusNode;

  const ExpenseSearchBar({
    super.key,
    required this.onSearchChanged,
    this.onFilterToggle,
    this.activeFilterCount = 0,
    this.isRTL = false,
    this.controller,
    this.focusNode,
  });

  @override
  State<ExpenseSearchBar> createState() => _ExpenseSearchBarState();
}

class _ExpenseSearchBarState extends State<ExpenseSearchBar> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isControllerOwned = false;
  bool _isFocusNodeOwned = false;

  @override
  void initState() {
    super.initState();
    // Use provided controller/focusNode or create our own
    if (widget.controller != null) {
      _controller = widget.controller!;
      _isControllerOwned = false;
    } else {
      _controller = TextEditingController();
      _isControllerOwned = true;
    }

    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
      _isFocusNodeOwned = false;
    } else {
      _focusNode = FocusNode();
      _isFocusNodeOwned = true;
    }

    _controller.addListener(() {
      widget.onSearchChanged(_controller.text);
    });
  }

  @override
  void dispose() {
    if (_isControllerOwned) {
      _controller.dispose();
    }
    if (_isFocusNodeOwned) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText:
                    widget.isRTL
                        ? 'ابحث في المصروفات...'
                        : 'Search expenses...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor:
                    Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[800]
                        : Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          if (widget.onFilterToggle != null) ...[
            const SizedBox(width: 8),
            // Filter Toggle Button
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  tooltip: widget.isRTL ? 'الفلاتر' : 'Filters',
                  onPressed: widget.onFilterToggle,
                ),
                if (widget.activeFilterCount > 0)
                  Positioned(
                    right: 4,
                    top: 4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        widget.activeFilterCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
