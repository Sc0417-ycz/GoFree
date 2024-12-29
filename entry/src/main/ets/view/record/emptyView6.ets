@Preview
@Component
export default struct emptyView6{
  private defaultHeight:string = '100%'
  build(){
    Column(){
      Image($r('app.media.empty'))
        .width(100)
        .height(100)
      Text("您还没有收藏的攻略呢~")
        .fontSize(18)
        .fontColor(Color.Gray)
    }
    .width("100%")
    .height(this.defaultHeight)
    .margin({top:200})
  }

}