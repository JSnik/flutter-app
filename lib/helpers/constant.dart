import 'package:flutter/material.dart';
import 'package:radio_skonto/helpers/singleton.dart';

const List<String> languageList = [
  'English',
  'Latviski'
];

// deniss.f@efumo.lv
// Option123)

//const apiBaseUrl = 'https://skonto.tst.lv';
//const apiBaseUrl = 'https://skonto2.tst.lv';
const apiBaseUrl =  'http://skonto2.mediaresearch.lv';
//41 76 528 63 41

//Для правильной работы CarPlay нужно сделать действия описанные внизу файла - CarPlayModule

String getTranslateValue (String key) {
  String value = '';
  String langCode = Singleton.instance.getLanguageCodeFromSharedPreferences();
  value = translateKeys[key+'_'+langCode]?? '';
  return value;
}

class App {
  static const padding = 24.0;
  static const edgeInsets = EdgeInsets.symmetric(horizontal: padding);
  static const empty = SizedBox.shrink();
  static const expanded = Expanded(child: empty);

  static BoxShadow appBoxShadow = BoxShadow(
    color: Colors.black54.withOpacity(0.3),
    blurRadius: 20,
    offset: const Offset(-2, 15), // changes position of shadow
  );
}

const Map <String, String> translateKeys = {
  'female_lv' : 'Sieviete',
  'female_en' : 'Woman',
  'male_lv' : 'Vīrietis',
  'male_en' : 'Man',
  'advanced_lv' : 'Uzlabotas',
  'advanced_en' : 'Advanced',
  'intermediate_lv' : 'Starpposma',
  'intermediate_en' : 'Intermediate',
  'basic_lv' : 'Pamatizglītība',
  'basic_en' : 'Basic',
};