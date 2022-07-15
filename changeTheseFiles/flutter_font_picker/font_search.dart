import 'package:flutter/material.dart';

class FontSearch extends StatefulWidget {
  final ValueChanged<String> onSearchTextChanged;
  const FontSearch({super.key, required this.onSearchTextChanged});

  @override
  _FontSearchState createState() => _FontSearchState();
}

class _FontSearchState extends State<FontSearch> {
  bool _isSearchFocused = false;
  TextEditingController searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return FocusScope(
      child: Focus(
        onFocusChange: (focus) {
          setState(() {
            _isSearchFocused = focus;
          });
        },
        child: TextField(
          controller: searchController,
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.search,
              color:  Theme.of(context).iconTheme.color,
            ),
            suffixIcon: _isSearchFocused
                ? IconButton(
              icon: Icon(Icons.cancel,
              color: Theme.of(context).iconTheme.color,),
              onPressed: () {
                FocusScope.of(context).unfocus();
                searchController.clear();
                widget.onSearchTextChanged('');
              },
            )
                : null,
            hintText: "Search...",
            hintStyle: Theme.of(context).textTheme.subtitle1,
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
          ),
          onChanged: widget.onSearchTextChanged,
        ),
      ),
    );
  }
}
