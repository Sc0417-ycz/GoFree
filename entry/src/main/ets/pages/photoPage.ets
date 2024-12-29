import router from '@ohos.router'

interface ParamsObj {
  cityName:string
  cityImage:string
  user_id:string
  username:string
}

@Entry
@Component
struct photoPage {

  @State cityName:string=''
  @State cityImage:string=''
  @State user_id:string=''
  @State username:string=''

  aboutToAppear(){
    console.log('(图片页接收)城市内容页传递过来的城市名数据',JSON.stringify(router.getParams()))
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
        Text('图片页').fontSize(20).fontWeight(600)
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
          Text('查看他人的图片').margin({left:10,right:10})
            .fontSize(35)
            .onClick(()=>{
              router.pushUrl({
                url:'pages/otherPhoto',
                params:{ cityName: this.cityName, user_id:this.user_id,username: this.username }
              })
              router.RouterMode.Single
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
          Text('存入自己的图片').fontSize(35).fontColor(Color.Red).margin({left:5,right:5})
            .onClick(()=>{
              router.pushUrl({
                url:'pages/myPhoto',
                params: { cityName: this.cityName, user_id:this.user_id,username: this.username }
              })
              router.RouterMode.Single
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
        Image($r('app.media.photo1'))
        Image($r('app.media.photo2'))
        Image($r('app.media.photo3'))
        Image($r('app.media.photo4'))
        Image($r('app.media.photo5'))
      }
      .margin({top:40})
      .width('100%')
      .height('50%')

      .loop(true)
      .autoPlay(true)
      .interval(3000)

    }
    .width('100%')
    .height('100%')



  }
}