@Preview
@Component
export default struct emptyView1{
  private defaultHeight:string = '100%'
  build(){
    Column(){
      Image($r('app.media.empty'))
        .width(100)
        .height(100)
      Text("您还未留下任何足迹呢~")
        .fontSize(18)
        .fontColor(Color.Gray)
      Text("现在就出发吧！!")
        .fontSize(18)
        .fontColor(Color.Gray)
    }
    .width("100%")
    .height(this.defaultHeight)
    .margin({top:200})
  }

}