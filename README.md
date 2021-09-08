# train

火车票售票系统管理端(模拟12306).

## Getting Started 安装flutter
1. 按照flutter官方教程安装flutter框架 https://flutter.dev/docs/get-started/install
2. 更改api.dart文件中的全局变量host(默认127.0.0.1:8080)为目前运行train-server的ip地址和端口
3. 确保train-server已经启动成功
4. 启动已经打好的release包,或执行flutter build重新打包(部分地方用到了dart.io包,排除后即可运行在网页端)

## 用到dart.io的位置
1. 上传头像 change_user_info.dart
2. constant.dart
3. etc...

## 运行平台代码
需要在项目文件夹下执行
1. windows平台: flutter build windows
2. 安卓平台: flutter build android
3. etc...

## 部分截图
![image](https://user-images.githubusercontent.com/57834237/132508140-d56ef78d-c1ee-4407-af30-c3737768d10c.png)
![image](https://user-images.githubusercontent.com/57834237/132508156-578d8972-fd6e-4d27-ae49-f538a31f2fe2.png)
![image](https://user-images.githubusercontent.com/57834237/132508173-f83442b4-f081-410b-86ae-77576b632dd9.png)
![image](https://user-images.githubusercontent.com/57834237/132508262-abd73a97-08c5-4f31-aea3-b933a3bdfa8a.png)
![image](https://user-images.githubusercontent.com/57834237/132508314-81aefbfa-80e4-43bc-91af-14494096bffb.png)
![image](https://user-images.githubusercontent.com/57834237/132508341-c5b318da-f083-46d4-9955-74ac01d20f86.png)
![image](https://user-images.githubusercontent.com/57834237/132508366-146bd69c-c97f-4712-9745-7dc23bdd8954.png)
![image](https://user-images.githubusercontent.com/57834237/132508391-5c35e295-20ad-4464-8f6e-ec4b343914ad.png)
![image](https://user-images.githubusercontent.com/57834237/132508416-51886d1d-9c74-420f-9c8a-b26c9a4cb12b.png)
![image](https://user-images.githubusercontent.com/57834237/132508447-9a38fbc9-1985-43cd-8d0b-b05e549b27c1.png)

