/// font picker 0.3.3 ///

// font_picker_ui
/*
* library flutter_font_picker;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/constants.dart';
import '../models/picker_font.dart';
import 'font_categories.dart';
import 'font_language.dart';
import 'font_preview.dart';
import 'font_search.dart';

class FontPickerUI extends StatefulWidget {
  final List<String> googleFonts;
  final ValueChanged<PickerFont> onFontChanged;
  final String initialFontFamily;
  final bool showFontInfo;
  final bool showInDialog;
  final int recentsCount;

  const FontPickerUI(
      {Key? key,
      this.googleFonts = googleFontsList,
      this.showFontInfo = true,
      this.showInDialog = false,
      this.recentsCount = 3,
      required this.onFontChanged,
      required this.initialFontFamily})
      : super(key: key);

  @override
  _FontPickerUIState createState() => _FontPickerUIState();
}

class _FontPickerUIState extends State<FontPickerUI> {
  var _shownFonts = <PickerFont>[];
  var _allFonts = <PickerFont>[];
  var _recentFonts = <PickerFont>[];
  String? _selectedFontFamily;
  FontWeight _selectedFontWeight = FontWeight.w400;
  FontStyle _selectedFontStyle = FontStyle.normal;
  String _selectedFontLanguage = 'all';

  @override
  void initState() {
    _prepareShownFonts();
    super.initState();
  }

  Future _prepareShownFonts() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var recents = prefs.getStringList(prefsRecentsKey) ?? [];
    setState(() {
      _recentFonts = recents.reversed
          .map((fontFamily) =>
              PickerFont(fontFamily: fontFamily, isRecent: true))
          .toList();
      _allFonts = _recentFonts +
          widget.googleFonts
              .where((fontFamily) => !recents.contains(fontFamily))
              .map((fontFamily) => PickerFont(fontFamily: fontFamily))
              .toList();
      _shownFonts = List.from(_allFonts);
    });
  }

  void changeFont(PickerFont selectedFont) {
    setState(() {
      widget.onFontChanged(selectedFont);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 5 / 6,
      child: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
            child: widget.showInDialog
                ? ListView(
                    shrinkWrap: true,
                    children: [
                      FontSearch(
                        onSearchTextChanged: onSearchTextChanged,
                      ),
                      FontLanguage(
                        onFontLanguageSelected: onFontLanguageSelected,
                        selectedFontLanguage: _selectedFontLanguage,
                      ),
                      SizedBox(height: 12.0)
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: FontSearch(
                          onSearchTextChanged: onSearchTextChanged,
                        ),
                      ),
                      Expanded(
                        child: FontLanguage(
                          onFontLanguageSelected: onFontLanguageSelected,
                          selectedFontLanguage: _selectedFontLanguage,
                        ),
                      )
                    ],
                  ),
          ),
          FontCategories(onFontCategoriesUpdated: onFontCategoriesUpdated),
          FontPreview(
              fontFamily: _selectedFontFamily ?? widget.initialFontFamily,
              fontWeight: _selectedFontWeight,
              fontStyle: _selectedFontStyle,),
          Expanded(
              child: ListView.builder(
            itemCount: _shownFonts.length,
            itemBuilder: (context, index) {
              PickerFont f = _shownFonts[index];
              bool isBeingSelected = _selectedFontFamily == f.fontFamily;
              String stylesString = widget.showFontInfo
                  ? f.variants.length > 1
                      ? "  ${f.category}, ${f.variants.length} styles"
                      : "  ${f.category}"
                  : "";
              return ListTile(
                selected: isBeingSelected,
                selectedTileColor: Theme.of(context).primaryColorDark,
                onTap: () {
                  setState(() {
                    if (!isBeingSelected) {
                      _selectedFontFamily = f.fontFamily;
                      _selectedFontWeight = FontWeight.w400;
                      _selectedFontStyle = FontStyle.normal;
                    } else {
                      _selectedFontFamily = null;
                    }
                  });
                },
                title: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: RichText(
                      text: TextSpan(
                          text: f.fontFamily,
                          style: TextStyle(
                                  fontFamily: GoogleFonts.getFont(f.fontFamily)
                                      .fontFamily)
                              .copyWith(
                                  color:
                                      DefaultTextStyle.of(context).style.color),
                          children: [
                        TextSpan(
                            text: stylesString,
                            style: TextStyle(
                                fontStyle: FontStyle.italic,
                                fontSize: Theme.of(context).textTheme.headline2!.fontSize!/20*11,
                                color: Colors.grey,
                                fontFamily: DefaultTextStyle.of(context)
                                    .style
                                    .fontFamily))
                      ])),
                ),
                subtitle: isBeingSelected
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Wrap(
                            children: f.variants.map((variant) {
                          bool isSelectedVariant;
                          if (variant == "italic" &&
                              _selectedFontStyle == FontStyle.italic) {
                            isSelectedVariant = true;
                          } else {
                            isSelectedVariant = _selectedFontWeight
                                .toString()
                                .contains(variant);
                          }
                          return SizedBox(
                            height: 30.0,
                            width: 60.0,
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                    backgroundColor: isSelectedVariant
                                        ? Theme.of(context).primaryColor : Theme.of(context).primaryColorDark,
                                    textStyle: TextStyle(
                                      color: !isSelectedVariant
                                          ? Theme.of(context).primaryColor : Theme.of(context).primaryColorDark,
                                      fontSize: Theme.of(context).textTheme.headline2!.fontSize!/20*10,
                                    ),
                                    shape: StadiumBorder()),
                                child: Text(
                                  variant,
                                  style: TextStyle(
                                      fontStyle: variant == "italic"
                                          ? FontStyle.italic
                                          : FontStyle.normal,
                                      color: !isSelectedVariant
                                          ? Theme.of(context).primaryColor : Theme.of(context).primaryColorDark,),
                                ),
                                onPressed: () {
                                  setState(() {
                                    if (variant == "italic") {
                                      _selectedFontStyle == FontStyle.italic
                                          ? _selectedFontStyle =
                                              FontStyle.normal
                                          : _selectedFontStyle =
                                              FontStyle.italic;
                                    } else {
                                      _selectedFontWeight =
                                          fontWeightValues[variant]!;
                                    }
                                  });
                                },
                              ),
                            ),
                          );
                        }).toList()),
                      )
                    : null,
                trailing: isBeingSelected
                    ? TextButton(
                        child: Text(
                          'SELECT',
                        ),
                        onPressed: () {
                          addToRecents(_selectedFontFamily!);
                          changeFont(PickerFont(
                              fontFamily: _selectedFontFamily!,
                              fontWeight: _selectedFontWeight,
                              fontStyle: _selectedFontStyle));
                          Navigator.of(context).pop();
                        },
                      )
                    : _recentFonts.contains(f)
                        ? Icon(
                            Icons.history,
                            size: 18.0,
                          )
                        : null,
              );
            },
          ))
        ],
      ),
    );
  }

  Future<void> addToRecents(String fontFamily) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var recents = prefs.getStringList(prefsRecentsKey);
    if (recents != null && !recents.contains(fontFamily)) {
      if (recents.length == widget.recentsCount) {
        recents = recents.sublist(1)..add(fontFamily);
      } else {
        recents.add(fontFamily);
      }
      prefs.setStringList(prefsRecentsKey, recents);
    } else {
      prefs.setStringList(prefsRecentsKey, [fontFamily]);
    }
  }

  void onFontLanguageSelected(String? newValue) {
    setState(() {
      _selectedFontLanguage = newValue!;
      if (newValue == 'all') {
        _shownFonts = _allFonts;
      } else {
        _shownFonts =
            _allFonts.where((f) => f.subsets.contains(newValue)).toList();
      }
    });
  }

  void onFontCategoriesUpdated(List<String> selectedFontCategories) {
    setState(() {
      _shownFonts = _allFonts
          .where((f) => selectedFontCategories.contains(f.category))
          .toList();
    });
  }

  void onSearchTextChanged(String text) {
    if (text.isEmpty) {
      setState(() {
        _shownFonts = _allFonts;
      });
      return;
    } else {
      setState(() {
        _shownFonts = _allFonts
            .where(
                (f) => f.fontFamily.toLowerCase().contains(text.toLowerCase()))
            .toList();
      });
    }
  }
}
*/

// font_preview
/*
* import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FontPreview extends StatelessWidget {
  final String fontFamily;
  final FontWeight fontWeight;
  final FontStyle fontStyle;
  const FontPreview(
      {Key? key,
      required this.fontFamily,
      required this.fontWeight,
      required this.fontStyle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextField(
        textAlign: TextAlign.center,
        style: GoogleFonts.getFont(fontFamily,
            fontWeight: fontWeight, fontStyle: fontStyle),
        decoration: InputDecoration(
            hintText: 'The quick brown fox jumped over the lazy dog',
            hintStyle: TextStyle(
              color: Theme.of(context).iconTheme.color,
                fontSize: Theme.of(context).textTheme.headline2!.fontSize!/20*14,
                fontStyle: fontStyle, fontWeight: fontWeight)),
      ),
    );
  }
}
*/

// font categories
/*import 'package:flutter/material.dart';

import '../constants/constants.dart';

class FontCategories extends StatefulWidget {
  final ValueChanged<List<String>> onFontCategoriesUpdated;
  const FontCategories({Key? key, required this.onFontCategoriesUpdated})
      : super(key: key);

  @override
  _FontCategoriesState createState() => _FontCategoriesState();
}

class _FontCategoriesState extends State<FontCategories> {
  List<String> _selectedFontCategories = List.from(googleFontCategories);

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
                backgroundColor:
                    isSelectedCategory ? Theme.of(context).primaryColor : Theme.of(context).primaryColorDark,
                textStyle: TextStyle(
                  fontSize: Theme.of(context).textTheme.headline2!.fontSize!/20*10,
                ),
                shape: StadiumBorder()),
            child: Text(fontCategory,
                style: TextStyle(
                  color: isSelectedCategory
                      ? Theme.of(context).primaryColorDark:Theme.of(context).colorScheme.onPrimary,
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
*/

// font search
/*
* import 'package:flutter/material.dart';

class FontSearch extends StatefulWidget {
  final ValueChanged<String> onSearchTextChanged;
  const FontSearch({Key? key, required this.onSearchTextChanged})
      : super(key: key);

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
              color: Theme.of(context).iconTheme.color,
            ),
            suffixIcon: _isSearchFocused
                ? IconButton(
                    icon: const Icon(Icons.cancel),
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
*/