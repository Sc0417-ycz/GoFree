import router from '@ohos.router'

interface ParamsObj {
  cityName:string
  cityImage:string
  user_id:string
  username:string
}

@Entry
@Component
struct StrategyPage {

  @State cityName:string=''
  @State cityImage:string=''
  @State user_id:string=''
  @State username:string=''

  aboutToAppear():void{
    console.log('(攻略页接收)城市内容页传递过来的城市名数据',JSON.stringify(router.getParams()))
    const params = router.getParams() as ParamsObj
    this.cityName = params.cityName
    this.cityImage = params.cityImage
    this.user_id =params.user_id
    this.username = params.username
  }

  build() {
    Column(){
      Row() {
        Image($r('app.media.left1'))
          .width(30)
          .fillColor(Color.Grey)
          .onClick(()=>{
            router.back()
            router.RouterMode.Single
          })
        Text('攻略页').fontSize(20).fontWeight(600)
        Image($r("app.media.helpone"))
          .width(30)
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
        left: 10,
        right: 10
      })


      Column(){

        Row(){
          Image($r('app.media.others1')).width(35).margin({left:10})
          Text('查看他人的攻略').margin({left:10,right:10})
            .fontSize(35)
            .onClick(()=>{
              router.pushUrl({
                url:'pages/otherStrategy',
                params:{ cityName: this.cityName, user_id:this.user_id,username: this.username }
              })
            })
        }
        .margin({top:30})
        .height(80)
        .border({
          color:'black',
          width:3,
          radius:10
        })
        .shadow({
          radius:10,
          offsetY:20,
        })
        Row(){
          Image($r('app.media.me')).width(30).margin({left:5})
          Text('存入自己的攻略').fontSize(35).fontColor(Color.Red).margin({left:5,right:5})
            .onClick(()=>{
              router.pushUrl({
                url:'pages/myStrategy',
                params: { cityName: this.cityName, user_id:this.user_id,username: this.username }
              })
            })
        }
        .padding(10)
        .margin({top:40})
        .height(80)
        .border({
          color:'black',
          width:3,
          radius:10
        })
        .shadow({
          radius:10,
          offsetY:20,
        })
      }
      .width('100%')

      Swiper(){
        Image($r('app.media.StrategySw2'))
        Image($r('app.media.StrategySw3'))
        Image($r('app.media.StrategySw1'))
        Image($r('app.media.StrategySw4'))
        Image($r('app.media.StrategySw5'))
      }
      .margin({top:35})
      .width('100%')
      .height('55%')

      .loop(true)
      .autoPlay(true)
      .interval(3000)

    }
    .width('100%')
    .height('100%')



  }
}