import 'package:flutter/material.dart';

import '../../../constants/constants.dart';

class FontCategories extends StatefulWidget {
  final ValueChanged<List<String>> onFontCategoriesUpdated;
  const FontCategories({super.key, required this.onFontCategoriesUpdated});

  @override
  _FontCategoriesState createState() => _FontCategoriesState();
}

class _FontCategoriesState extends State<FontCategories> {
  final List<String> _selectedFontCategories = List.from(googleFontCategories);

  @override
  Widget build(BuildContext context) {
    return Wrap(
        children: googleFontCategories.map((fontCategory) {
          bool isSelectedCategory = _selectedFontCategories.contains(fontCategory);
          return SizedBox(
            height: 30.0,
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: isSelectedCategory ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).primaryColorDark.withOpacity(0.8),
                  textStyle: TextStyle(
                    fontSize: Theme.of(context).textTheme.headline2!.fontSize!/20*10,
                  ),
                  shape: const StadiumBorder(),
                  side: BorderSide(width: 0, color: Colors.transparent),
                ),
                child: Text(fontCategory,
                    style: TextStyle(
                      color: isSelectedCategory
                          ? Theme.of(context).shadowColor
                          : Theme.of(context).colorScheme.onPrimary,
                    )),
                onPressed: () {
                  _selectedFontCategories.contains(fontCategory)
                      ? _selectedFontCategories.remove(fontCategory)
                      : _selectedFontCategories.add(fontCategory);
                  widget.onFontCategoriesUpdated(_selectedFontCategories);
                },
              ),
            ),
          );
        }).toList());
  }
}
