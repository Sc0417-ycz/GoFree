@Preview
@Component
export default struct emptyView{
  private defaultHeight:string = '100%'
  build(){
    Column({space:10}){
      Image($r('app.media.empty'))
        .width(100)
        .height(100)
      Text("您在此城市还没有留下任何攻略呢~")
        .fontSize(18)
        .fontColor(Color.Gray)
    }
    .width("100%")
    .height(this.defaultHeight)
    .margin({top:200})
  }

}