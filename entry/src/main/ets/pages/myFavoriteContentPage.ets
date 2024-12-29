import router from '@ohos.router';


interface ParamsObj {
  strategyId: string,
  strategyName: string,
  authorName: string,
  date:string,
  content: string,
  imagePath: string[]
}


@Entry
@Component
struct myFavoriteContentPage {
  @State strategyId: string = '';
  @State strategyName: string = '';
  @State authorName: string = '';
  @State date: string = '';
  @State content: string = '';
  @State imagePath: string[] = []

  aboutToAppear() {
    const params = router.getParams() as ParamsObj;
    this.strategyId = params.strategyId;
    this.strategyName = params.strategyName;
    this.authorName = params.authorName;
    this.date = params.date;
    this.content = params.content;
    this.imagePath = params.imagePath;
  }

  build() {
    Scroll(){
      Column() {
        Text(`攻略名称: ${this.strategyName}`).fontSize(25).fontWeight(500);
        Text(`作者: ${this.authorName}`).fontSize(25).fontWeight(500);
        Text(`日期: ${this.date}`).fontSize(20).fontWeight(500);
        Text(`攻略内容: ${this.content}`).fontSize(20).fontWeight(500).margin({ bottom: 10 });
        Column() {
          Swiper() {
            ForEach(this.imagePath, (imgPath: string, imgIndex: number) => {
              Image(imgPath)
                .width('100%')
                .height('40%')
            })
          }
          .loop(true)
          .autoPlay(true)
          .interval(3000)
        }.margin({ top: 10, bottom: 10 })
      }
    }.margin({top:10})
  }
}