import router from '@ohos.router'

interface ParamsObj {
  cityName:string
  cityImage:string
  username:string
  user_id:string,
  user_profile:string
}

@CustomDialog
struct CityImage{

  @State cityImage:string=''


  aboutToAppear(){
    console.log('(弹窗)城市页传递过来的城市图片数据',JSON.stringify(router.getParams()))
    const params = router.getParams() as ParamsObj
    this.cityImage = params.cityImage
  }

  controller:CustomDialogController = new CustomDialogController({
    builder:CityImage()
  })
  build(){
    Scroll(){
      Column(){
        Image(this.cityImage)
      }
    }.width("100%").height("100%").scrollable(ScrollDirection.Horizontal).scrollBar(BarState.Off)

  }
}

@Entry
@Component
struct CityContentPage {

  controller:CustomDialogController = new CustomDialogController({
    builder:CityImage()
  })

  @State cityName:string=''
  @State opacityValue : number = 0.3;


  @State cityImage:string=''
  @State user_id:string=''
  @State username:string=''
  @State user_profile:string=''

  onPageShow(){
    this.opacityValue = 1
  }
  aboutToAppear():void{
    console.log('城市页传递过来的城市数据',JSON.stringify(router.getParams()))
    const params = router.getParams() as ParamsObj
    this.cityName = params.cityName
    this.cityImage = params.cityImage
    this.user_id =params.user_id
    this.username =params.username
    this.user_profile = params.user_profile
  }
  build() {
    Column(){
      Row({space:4}){
        Image($r('app.media.left'))
          .width(30)
          .onClick(()=>{
            router.back()
            router.RouterMode.Single
          })
        Text("城市信息添加").fontSize(20).fontWeight(500).margin({top:5})
        Image($r('app.media.helpone')).width(30).margin({top:3})
          .onClick(()=>{
            AlertDialog.show({
              message:"此页您可以选择在该城市添加的旅游数据类型(攻略，图片，游记等)，并且可以通过点击城市大图更好地大体了解该城市的旅游资源"
            })
          })
      }.backgroundColor(Color.White)
      .height(32)
      .width("100%")
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({
        left:10,
        right:10
      })
      .margin({bottom:10})

      Column(){
        Text('')
      }
      .onClick(()=>{
        this.controller.open()
      })
      .width("100%")
      .height("50%")
      .backgroundImage(this.cityImage)

      .border({
        color:'black',
        width:2,
        radius:10
      })
      .shadow({
        radius:10,
        offsetY:20,
      })
      .opacity(this.opacityValue)
      .animation({
        duration:1800,
        iterations:2
      })


      Row(){
        Image($r('app.media.strategy')).height(40).width(40).margin({left:10,right:6})
        Text('旅行攻略').fontSize(26).fontWeight(500).fontColor(Color.Black)
        Image($r('app.media.right')).height(30).width(30).margin({left:113,right:10})

      }
      .onClick(()=>{
        router.pushUrl({
          url:'pages/StrategyPage',
          params: {
            cityName: this.cityName ,
            cityImage:this.cityImage,
            user_id:this.user_id,
            username:this.username,
            user_profile:this.user_profile
          }

        })
        router.RouterMode.Single
      })
      .margin({top:18})
      .height(80)
      .border({
        color:'black',
        width:2,
        radius:10
      })
      .shadow({
        radius:10,
        offsetY:20,
      })

      Row(){
        Image($r('app.media.video')).height(45).width(45).margin({left:10,right:5})
        Text('旅行视频').fontSize(26).fontWeight(500).fontColor(Color.Black)
        Image($r('app.media.right')).height(30).width(30).margin({left:105,right:10})
      }

      .margin({top:30})
      .height(80)
      .border({
        color:'black',
        width:2,
        radius:10
      })
      .shadow({
        radius:10,
        offsetY:20,
      })

      Row(){
        Image($r('app.media.photo')).height(50).width(50).margin({left:10,right:5})
        Text('旅行图片').fontSize(26).fontWeight(500).fontColor(Color.Black)
        Image($r('app.media.right')).height(30).width(30).margin({left:100,right:10})
      }
      .onClick(()=>{
        router.pushUrl({
          url:'pages/photoPage',
          params: {
            cityName: this.cityName,
            cityImage:this.cityImage,
            user_id:this.user_id,
            username:this.username
          }
        })
        router.RouterMode.Single
      })
      .margin({top:30})
      .height(80)
      .border({
        color:'black',
        width:2,
        radius:10
      })
      .shadow({
        radius:10,
        offsetY:20,
      })


    }

    .width('100%')
    .height('100%')
  }
}