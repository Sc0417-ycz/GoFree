@Component

export default struct recordTrip{
  build() {
    Column(){
      Row(){
        Image($r("app.media.more"))
          .width(28)
        Text('出行方式选择').fontSize(18)
        Image($r('app.media.helpone'))
          .width(30)
          .fillColor(Color.Grey)
          .onClick(()=>{
            AlertDialog.show({
              message:'此页您为您提供大家最常用的出行软件，帮助您合理规划您的行程以及消费，您可以点击下方按钮跳转至各个软件并进行行程安排'
            })
          })
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .width('100%')
      .height(50)
      .backgroundColor(Color.White)
      .padding({
        left:10,
        right:10
      })
      Column() {
        Row() {
          Text('请选择您的出行App：')
            .fontSize(20)
            .margin({top:20,bottom:20})
        }
        Swiper(){
          Image($r('app.media.img_3'))
          Image($r('app.media.img_4'))
          Image($r('app.media.img_5'))
          Image($r('app.media.img_6'))
        }
        .width('100%')
        .height(180)
        .loop(true)
        .autoPlay(true)
        .interval(3000)
      }
      .width('100%')


      Column(){
        Row(){
          Image($r('app.media.meituan')).height(30).width(30).margin({left:10})
          Text('美团').fontSize(25)
          Image($r('app.media.right')).height(30).width(30).margin({left:200,right:10})
        }
        .margin({top:10})
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
          Image($r('app.media.xiecheng')).height(30).width(30).margin({left:10})
          Text('携程旅行').fontSize(25)
          Image($r('app.media.right')).height(30).width(30).margin({left:150,right:10})
        }
        .margin({top:20})
        .height(80)
        .border({
          color:'black',
          width:2,
          radius:10
        })
        .shadow({
          radius:10,
          offsetY:23,
        })

        Row(){
          Image($r('app.media.qunaer')).height(30).width(30).margin({left:10})
          Text('去哪儿旅行').fontSize(25)
          Image($r('app.media.right')).height(30).width(30).margin({left:130,right:10})
        }
        .margin({top:20})
        .height(80)
        .border({
          color:'black',
          width:2,
          radius:10
        })
        .shadow({
          radius:10,
          offsetY:23,
        })

        Row(){
          Image($r('app.media.railway')).height(30).width(30).margin({left:10})
          Text('铁路12306').fontSize(25)
          Image($r('app.media.right')).height(30).width(30).margin({left:130,right:10})
        }
        .margin({top:20})
        .height(80)
        .border({
          color:'black',
          width:2,
          radius:10
        })
        .shadow({
          radius:10,
          offsetY:23,
        })


      }.padding({top:20})
    }

    .width('100%')
    .height('100%')
    .backgroundColor('#fff')
  }


}