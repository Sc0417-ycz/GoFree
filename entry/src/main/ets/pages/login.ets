import router from '@ohos.router';
import { testUtil } from '../utils/TestUtil';
import prompt from '@ohos.prompt';
import UserModel from '../model/UserModel';

@Entry
@Component
struct login {
  @State username: string = '';
  @State password: string = '';



  async loginCheck() {
    if (this.username === '') {
      prompt.showToast({
        message: '用户名不能为空',
        duration: 1000
      });
      return;
    }
    if (this.password === '') {
      prompt.showToast({
        message: '密码不能为空',
        duration: 1000
      });
      return;
    }

    // 根据输入的用户名去数据库中查询所有同名用户信息，传递正确的查询列参数
    const userFromDB: UserModel[] = await testUtil.queryUser(["USER_ID", "USERNAME", "PASSWORD"], "USER", this.username);
    console.log('查询到的用户信息数组：', JSON.stringify(userFromDB))
    const matchingUser = userFromDB.find((user) => user.username === this.username && user.password === this.password );
    if (matchingUser) {
      // 密码正确且用户名匹配，登录成功，可进行页面跳转等后续操作
      prompt.showToast({
        message: '登录成功',
        duration: 1000
      });
      router.replaceUrl({
        url: 'pages/Index',
        // 传递完整的UserModel实例到下一个页面（这里假设Index页面能接收并处理该对象）
        params: {
          user_id: matchingUser.user_id,
          username: matchingUser.username
        }
      });
    } else {
      // 未找到匹配的用户（用户名和密码组合不对应任何记录），提示用户
      prompt.showToast({
        message: '用户名或密码错误，请重新输入',
        duration: 1000
      });
    }
  }

  build() {
    Column({ space: 15 }) {
      // 顶部应用图标（假设和注册页类似，你可根据实际调整）
      Text()
        .width(150)
        .height(150)
        .borderRadius(90)
        .margin({ top: 80 })
        .backgroundImage($r('app.media.logo1'))
        .backgroundImageSize(ImageSize.Cover)
        .width(110)
        .height(100)
      // 两个输入框及登录按钮
      Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.SpaceEvenly, alignItems: ItemAlign.Center }) {
        TextInput({ placeholder: '输入用户名' }).width(300).onChange((value) => {
          this.username = value;
        }).maxLength(15);
        TextInput({ placeholder: '输入密码' }).width(300).type(InputType.Password).onChange((value) => {
          this.password = value;
        }).maxLength(15);
        Button('登录', { stateEffect: true }).width(150)
          .onClick(() => {
            this.loginCheck();
          });
      }
      .height('38%')
      .width('95%')
      .backgroundColor(Color.White)
      .borderRadius(20)
      .margin({ top: 40 });
      Row({ space: 15 }) {
        Text('前往注册').fontSize(20).fontColor(Color.White)
          .onClick(() => {
            router.pushUrl({
              url: 'pages/register'
            });
          })
        Text('忘记密码').fontSize(20).fontColor(Color.White)
          .onClick(() => {
            router.pushUrl({
              url: 'pages/forget'
            });
          })
      }

      Row() {
        Text('其他登录方式')
          .margin({ top: 50 })
          .fontColor(Color.White)
          .fontSize(20)
      }

      Row({ space: 40 }) {
        Image($r('app.media.img'))
          .width(60)
        Image($r('app.media.wx'))
          .borderRadius(50)
          .width(60)
        Image($r('app.media.img_2'))
          .borderRadius(50)
          .width(60)
      }

    }
    .height('100%')
    .width('100%')
    .backgroundImage($r('app.media.indexbj2'))
    .backgroundImageSize(ImageSize.Cover)
    .alignItems(HorizontalAlign.Center);
  }
}