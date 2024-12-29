import router from '@ohos.router'

@Entry
@Component

struct welcome{

  @State opacityValue : number = 0.3;


  onPageShow(){
    this.opacityValue = 1
  }

  build(){
    Column(){
      Blank()
      Column(){
        Text('欢迎来到').fontColor(Color.White).fontSize(50).fontWeight(FontWeight.Bold)
        Text(' GoFree').fontColor(Color.White).fontSize(50).fontWeight(FontWeight.Bold)
      }.alignItems(HorizontalAlign.Start).opacity(this.opacityValue)
      .animation({
        duration:2000,
        iterations:2,
        onFinish:()=>{
          router.replaceUrl({
            url:'pages/login',

          })
        }
      })
      Blank()
      Blank()
      Image($r('app.media.logo1')).width(100).borderRadius(50).margin({bottom:10})
    }.width('100%').height('100%').linearGradient({
      colors:[
        ['#ff69ff9b',0],["#ff358ffc",1]
      ]
    })
  }
}