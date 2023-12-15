class LocationHistoryState {}

class LocationHistoryInitial extends LocationHistoryState {}

class LocationHistoryLoading extends LocationHistoryState {}

class LocationHistorySuccess extends LocationHistoryState {
  var list = <Map<String, dynamic>>[];

  LocationHistorySuccess(this.list);
}

class LocationHistoryFailed extends LocationHistoryState {
  String? message;
  LocationHistoryFailed(this.message);
}
