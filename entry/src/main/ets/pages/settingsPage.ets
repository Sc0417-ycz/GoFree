import router from '@ohos.router'

interface ParamsObj {
  user_id: string;
}

@Entry
@Component
struct SettingsPage {

  @State user_id: string = '';

  aboutToAppear() {
    const params = router.getParams() as ParamsObj;
    this.user_id = params.user_id;
    console.log('主页(个人)传过来的用户ID数据', JSON.stringify(router.getParams()));
  }

  build() {
    Column(){
      Row(){
        Image($r('app.media.left1'))
          .width(30)
          .fillColor(Color.Grey)
          .onClick(()=>{
            router.back()
            router.RouterMode.Single
          })
        Text(`我的设置`).fontSize(18).fontWeight(600)

        Image($r("app.media.helpone"))
          .width(30)
          .onClick(()=>{
            AlertDialog.show({
              message:'此页您可以设置相关应用设置'
            })
          })

      }
      .border({
        width:{bottom:2},
        color:Color.Gray
      })
      .borderRadius(15)
      .justifyContent(FlexAlign.SpaceBetween)
      .width('100%')
      .height(50)
      .backgroundColor(Color.White)
      .padding({
        left:10,
        right:10
      })

      Column({space:20}){
        Button('隐私设置').width(300).height(40)
        Button('主题切换').width(300).height(40)
        Button('切换账号').width(300).height(40)
        Button('退出账号').width(300).height(40)
          .onClick(()=>{

          })
      }.width("100%").height("90%").justifyContent(FlexAlign.Center)
    }.width("100%").height('100%').backgroundImage($r('app.media.bj5'))
  }
}