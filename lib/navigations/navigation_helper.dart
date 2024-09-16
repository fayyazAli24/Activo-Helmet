import 'package:unilever_activo/app/app.dart';

Future pushNamed(String route, [arguments]) {
  return App.navigatorKey.currentState!.pushNamed(route, arguments: arguments);
}

Future pushNamedReplace(String route) => App.navigatorKey.currentState!.pushReplacementNamed(route);

Future pushNamedRemoveAll(String route, [bool hasBack = true]) =>
    App.navigatorKey.currentState!.pushNamedAndRemoveUntil(route, (_) => false, arguments: hasBack);
Future replaceNamedRoute(String route, [bool hasBack = true]) =>
    App.navigatorKey.currentState!.pushReplacementNamed(route, arguments: hasBack);

void pop() => App.navigatorKey.currentState!.pop();

void popWithValue(value) => App.navigatorKey.currentState!.pop(value);

void popAllRoutes() => App.navigatorKey.currentState!.popUntil((route) => false);

void popUntil(String untilRouteName) =>
    App.navigatorKey.currentState!.popUntil((route) => route.settings.name == untilRouteName);
