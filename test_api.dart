import 'package:dio/dio.dart';

void main() async {
  final dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:5500',
    connectTimeout: Duration(seconds: 10),
  ));
  
  try {
    // Test health or openapi
    final res = await dio.get('/openapi.json');
    print('Status: ${res.statusCode}');
    print('Data keys: ${res.data.keys}');
  } catch (e) {
    print('Error: $e');
  }
}
