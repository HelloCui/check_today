library check_today.globals;

double $screenWidth;
var $borderSide;
bool $notNull(Object o) => o != null;
var $token;
var $refreshToken;
var $scaffoldKey;
var $navigatorKey;
const $ERRMSG = {
  'token': '鉴权失败，请重新登录',
  'api': '接口异常，请稍后重试',
  'unknow': '程序异常，请上报开发者',
};