@Component

export default struct recordCommunity{

  myScroll:Scroller=new Scroller()

  build(){
    Column(){
      Stack({alignContent:Alignment.BottomEnd}){
        Scroll(this.myScroll) {
          Column() {

            Image($r('app.media.bj3'))
          }
        }
        .scrollBar(BarState.Off)
        .width('100%')


        Image($r('app.media.rocket'))
          .width(50)
          .backgroundColor(Color.White)
          .borderRadius(25)
          .padding(5)
          .offset({x:-20,y:-20})
          .onClick(()=>{
            this.myScroll.scrollEdge(Edge.Top)
          })


      }
    }
  }
}