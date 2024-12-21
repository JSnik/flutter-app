import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:radio_skonto/helpers/api_helper.dart';
import 'package:radio_skonto/helpers/singleton.dart';
import 'package:radio_skonto/models/main_screen_data.dart';
import 'package:radio_skonto/providers/player_provider.dart';

enum MainScreenCellType {news, playlist, audio, video, interview}

class MainScreenProvider with ChangeNotifier {

  ResponseState getMainScreenDataResponseState = ResponseState.stateFirsLoad;

  int currentSelectedDataIndex = 0;
  bool needSendStatisticOneImageBannerWidget = true;
  List<int> listOfSentHorizontalAdIds = [];
  final ScrollController scrollControllerHomeScreen = ScrollController();

  MainScreenData mainScreenData = MainScreenData(apiVersion: '1.0', data: [], banners: []);

  void setCurrentDataIndex(int index) {
    currentSelectedDataIndex = index;
    notifyListeners();
  }

  void switchToDataByPlaylistId(int playlistId) {
    for (int i = 0; i < mainScreenData.data.length; i++) {
      if (mainScreenData.data[i].id == playlistId) {
        setCurrentDataIndex(i);
        break;
      }
    }
  }

  Future<void> getMainScreenData(bool isFromInit, BuildContext context) async {
    getMainScreenDataResponseState = ResponseState.stateLoading;
    if (isFromInit == false) {
      notifyListeners();
    }
    ApiHelper helper = ApiHelper();
    String languageCode = Singleton.instance.getLanguageCodeFromSharedPreferences();
    String apiKey = '/api/homepage/$languageCode';
    final response = await helper.get(apiKey, null);
    //final response = await helper.getRequestWithToken(url: apiKey, context: context);

    if (response != null && response.statusCode == 200) {
      var errorTest = jsonDecode(response.body);
      if (errorTest['error'] != null) {
        getMainScreenDataResponseState = ResponseState.stateError;
        notifyListeners();
      } else {
        mainScreenData = mainScreenDataFromJson(response.body);
        //TODO
        List<MainData>  tempList = [];
        for (int i = 0; i < mainScreenData.data.length; i++) {
          var test = mainScreenData.data[i];
          if (test.name != '') {
            tempList.add(test);
          }
        }
        mainScreenData.data = tempList;
        getMainScreenDataResponseState = ResponseState.stateSuccess;
        notifyListeners();
        //context.read<PlayerProvider>().updateAndroidAutoAndCarPlayItems(mainScreenData.data);
      }
    } else {
      getMainScreenDataResponseState = ResponseState.stateError;
      notifyListeners();
    }
  }

  Future<void> sendEventBannerShown(String type, List<int> ids) async {
    ApiHelper helper = ApiHelper();
    String apiKey = '/api/count-view';

    String uniqueDeviseId = await Singleton.instance.getDeviseIdFromSharedPreferences();

    Map<String, dynamic> finishBody = {
      'guest': uniqueDeviseId,
      'entityType': type,
      'ids': ids,
    };
    var body = json.encode(finishBody);

    final response = await helper.post(apiKey, null, body);
    if (response != null && response.statusCode == 200) {
      var errorTest = jsonDecode(response.body);
      print(errorTest);
    }
  }

  Future<void> sendEventBannerClick(String type, int id) async {
    ApiHelper helper = ApiHelper();
    String apiKey = '/api/count-click';

    String uniqueDeviseId = await Singleton.instance.getDeviseIdFromSharedPreferences();

    Map<String, dynamic> finishBody = {
      'guest': uniqueDeviseId,
      'entityType': type,
      'id': id,
    };
    var body = json.encode(finishBody);

    final response = await helper.post(apiKey, null, body);
    if (response != null && response.statusCode == 200) {
      var errorTest = jsonDecode(response.body);
      print(errorTest);
    }
  }
}
