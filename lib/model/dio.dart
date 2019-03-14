import 'package:dio/dio.dart';
import '../global.dart';
import '../common.dart';
import 'user.dart';

BaseOptions options = new BaseOptions(
    baseUrl:"https://cuijiajie.com",
//    baseUrl: "http://localhost",
    connectTimeout: 5000,
    receiveTimeout: 3000);
bool isDebug = false;
String proxy = 'localhost:8888';
Dio dio = Dio(options);
List<String> permitRoute = ['canRegister', 'register', 'login'];
// token用独立的实例，避免死锁
Dio tokenDio = new Dio(options);

initDio() {
  if (isDebug) {
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (client) {
      client.findProxy = (uri) {
        return 'PROXY $proxy';
      };
    };
  }
  dio.interceptors
      .add(InterceptorsWrapper(onRequest: (RequestOptions options) async {
    List<String> pathArr = options.path.split('/');
    if (pathArr.length <= 1 || permitRoute.indexOf(pathArr[1]) >= 0) {
      return options;
    }
    final arr = $token.split('.');
    if (arr.length < 0) {
      Common.logout();
    }
    final decoded = Common.base64ToJson(arr[1]);
    // token 超时
    if (decoded['exp'] - DateTime.now().millisecondsSinceEpoch / 1000 <
        30) {
      dio.lock();
      final result = await User.getToken();
      if (result != true) {
        dio.clear();
        dio.unlock();
        Common.logout($ERRMSG['token']);
        return DioError(type: DioErrorType.CANCEL);
      }
      dio.unlock();
    }
    options.headers['token'] = $token;
    return options; //continue
  }));
}
