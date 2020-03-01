import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';

class MockClient extends Mock implements http.Client {
  String json = '{"person_id": 1, "tasks": []}';

  Future<http.Response> get(url, {Map<String, String> headers}) {
    return Future<http.Response>.value(http.Response(json, 200));
  }
}