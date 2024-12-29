import router from '@ohos.router';
import { testUtil } from '../utils/TestUtil';
import prompt from '@ohos.prompt';
import UserModel from '../model/UserModel';

@Entry
@Component
struct register {
  @State username: string = '';
  @State password: string = '';
  @State conf_psd: string = '';

  build() {
    Column({ space: 15 }) {
      // 顶部应用图标
      Text().width(150).height(150).borderRadius(90).margin({ top: 80 })
        .backgroundImage($r('app.media.logo1')).backgroundImageSize(ImageSize.Cover).width(110).height(100)
      // 三个输入框及注册按钮
      Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.SpaceEvenly, alignItems: ItemAlign.Center }) {
        TextInput({ placeholder: '输入用户名' }).width(300).onChange((value) => {
          this.username = value;
        }).maxLength(15);
        TextInput({ placeholder: '输入密码' }).width(300).type(InputType.Password).onChange((value) => {
          this.password = value;
        }).maxLength(15);
        TextInput({ placeholder: '确认密码' }).width(300).type(InputType.Password).onChange((value) => {
          this.conf_psd = value;
        }).maxLength(15);
        Button('注册', { stateEffect: true }).width(150)
          .onClick(() => {
            if (this.username === '') {
              // 用户名为空，弹窗提示
              prompt.showToast({
                message: '用户名不能为空',
                duration: 1000
              });
            } else {
              // 密码为空，弹窗提示
              if (this.password === '')
                prompt.showToast({
                  message: '密码不能为空',
                  duration: 1000
                });
              else {
                // 确认密码为空，弹窗提示
                if (this.conf_psd === '')
                  prompt.showToast({
                    message: '未确认密码',
                    duration: 1000
                  });
                else if (this.conf_psd!== this.password) {
                  // 密码不一致，弹窗提示
                  prompt.showToast({
                    message: '密码不一致',
                    duration: 1000
                  });
                } else {
                  // 创建符合新结构的UserModel实例
                  const user = new UserModel();
                  user.username = this.username;
                  user.password = this.password;
                  // 这里假设user_id在数据库插入时会自动生成，所以先暂设为空字符串，
                  // 你可以根据实际数据库逻辑进行调整，如果需要手动生成等情况要相应处理
                  user.user_id = '';

                  // 调用testUtil插入用户数据方法
                  testUtil.insertUserData('USER', user).then(() => {
                    // 成功注册，弹窗显示用户名及密码
                    prompt.showToast({
                      message: `注册成功\n用户名: ${this.username}\n密码: ${this.password}`,
                      duration: 1000
                    });
                    // 将完整的UserModel实例传递给登录页（这里假设登录页能接收并处理该对象）
                    router.replaceUrl({
                      url: 'pages/login',
                      params: user
                    });
                  }).catch((error) => {
                    // 插入用户数据失败提示，可根据实际错误情况优化提示内容
                    prompt.showToast({
                      message: `注册失败，原因: ${error.message}`,
                      duration: 1000
                    });
                  });
                }
              }
            }
          });
      }.height('40%').width('95%').backgroundColor(Color.White).borderRadius(20).margin({ top: 40 })
    }.height('100%').width('100%').alignItems(HorizontalAlign.Center).backgroundImage($r('app.media.indexbj2'))
    .backgroundImageSize(ImageSize.Cover);
  }
}