class Api {
  static const _baseUrl = 'http://175.107.195.221:1500/Api/';

  static const trJourney = '${_baseUrl}TrJourney';

  static const disconnectReason = '${_baseUrl}DisconnectingReason';

  static const disconnectingAlert = '${_baseUrl}DisconnectingAlert';

  static const alarmTime = '${_baseUrl}GetMobileAlarmTime';

  static const register = '${_baseUrl}Auth/Register';

  static const login = '${_baseUrl}Auth/login';

  static const getGraph = '${_baseUrl}Auth/GetGraphData?deviceId=';
}
