import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:flutter_login/flutter_login.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:train/api/api.dart';
import 'package:train/util/constance.dart';

class LoginPage extends StatelessWidget {
  static const routeName = '/auth';

  Duration get loginTime => Duration(milliseconds: timeDilation.ceil() * 2250);

  Future<String?> _loginUser(LoginData data) async {
    String s = await UserApi.login(data.name, data.password);
    bool b = await UserApi.isAdmin();
    if (!b){
      UserApi.logout();
      return "您不是管理员,无权登录";
    }
    if (s == '登录成功') {
      BotToast.showText(text: '登录成功');
      Get.back();
      return null;
    }
    return s;
  }

  Future<String?> _registerUser(LoginData data) async {
    String s = await UserApi.register(data.name, data.password);
    if (s == '注册成功') {
      BotToast.showText(text: '注册成功');
      return null;
    }
    return s;
  }

  Future<String> _recoverPassword(String name) async {
    return "fail";
  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      loginAfterSignUp: false,
      title: Constants.appName,
      logo: 'assets/icon/icon.png',
      logoTag: Constants.logoTag,
      titleTag: Constants.titleTag,
      navigateBackAfterRecovery: true,
      // hideProvidersTitle: false,
      // loginAfterSignUp: false,
      hideForgotPasswordButton: true,
      // hideSignUpButton: true,
      // disableCustomPageTransformer: true,
      messages: LoginMessages(
        userHint: '用户名',
        passwordHint: '密码',
        confirmPasswordHint: '确认密码',
        loginButton: '登录',
        signupButton: '注册',
        forgotPasswordButton: '忘记密码?',
        recoverPasswordButton: '密码提示',
        goBackButton: '返回',
        confirmPasswordError: '密码不匹配',
      ),
      loginProviders: [
        LoginProvider(
          icon: FontAwesomeIcons.qq,
          label: 'QQ',
          callback: () async {
            await Future.delayed(loginTime);
            return '';
          },
        ),
        LoginProvider(
          icon: FontAwesomeIcons.weixin,
          label: '微信',
          callback: () async {
            await Future.delayed(loginTime);
            return '';
          },
        ),
      ],
      userValidator: (value) {
        return null;
      },
      passwordValidator: (value) {
        if (value!.isEmpty) {
          return '密码为空';
        }
        return null;
      },
      onLogin: (loginData) {
        return _loginUser(loginData);
      },
      onSignup: (loginData) {
        return _registerUser(loginData);
      },
      onSubmitAnimationCompleted: () {
        // Navigator.of(context).pushReplacement(FadePageRoute(
        //   builder: (context) => DashboardScreen(),
        // ));
      },
      onRecoverPassword: (name) {
        print('Recover password info');
        print('Name: $name');
        return _recoverPassword(name);
        // Show new password dialog
      },
      showDebugButtons: false,
    );
  }
}
