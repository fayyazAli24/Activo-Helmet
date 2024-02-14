class Api {
  static const _baseUrl = 'http://103.143.76.242:1200/Api/';
  // static const _baseUrl = 'http://51.79.209.55:4900/Api/';

  static const trJourney = '${_baseUrl}TrJourney/TrJourney?';

  static const disconnectReason = '${_baseUrl}DisconnectingReason/DisconnectingReason?';

  static const disconnectingAlert = '${_baseUrl}DisconnectingAlert/DisconnectingAlert?';

  static const alarmTime = '${_baseUrl}GetMobileAlarmTimes';
}
