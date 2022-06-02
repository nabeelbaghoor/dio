import 'dart:convert';

import 'package:dio/dio.dart';

void main() async {
  const URL_NOT_FIND = 'https://wendux.github.io/xxxxx/';
  const URL_NOT_FIND_1 = URL_NOT_FIND + '1';
  const URL_NOT_FIND_2 = URL_NOT_FIND + '2';
  const URL_NOT_FIND_3 = URL_NOT_FIND + '3';
  var dio = Dio();
  dio.options.baseUrl = 'http://localhost:8085/';
  dio.interceptors.add(InterceptorsWrapper(
    onResponse: (response, handler) {
      // print(response.data['data']);
      // response.data = json.decode("{}");
      handler.next(response);
    },
    onError: (DioError e, handler) {
      if (e.response != null) {
        switch (e.response!.requestOptions.path) {
          case URL_NOT_FIND:
            return handler.next(e);
          case URL_NOT_FIND_1:
            handler.resolve(
              Response(
                requestOptions: e.requestOptions,
                data: 'fake data',
              ),
            );
            break;
          case URL_NOT_FIND_2:
            handler.resolve(
              Response(
                requestOptions: e.requestOptions,
                data: 'fake data',
              ),
            );
            break;
          case URL_NOT_FIND_3:
            handler.next(
              e..error = 'custom error info [${e.response?.statusCode}]',
            );
            break;
        }
      } else {
        handler.next(e);
      }
    },
  ));

  Response response;
  response = await dio.get('/client/bee.mp4');
  // response = await dio.post('/client/bee.mp4', data: {'a': 7});
  print(response.data);
  assert(response.data['a'] == 5);
  try {
    await dio.get(URL_NOT_FIND);
  } on DioError catch (e) {
    assert(e.response!.statusCode == 404);
  }
  response = await dio.get(URL_NOT_FIND + '1');
  assert(response.data == 'fake data');
  response = await dio.get(URL_NOT_FIND + '2');
  assert(response.data == 'fake data');
  try {
    await dio.get(URL_NOT_FIND + '3');
  } on DioError catch (e) {
    assert(e.message == 'custom error info [404]');
  }
}
