

@Entry
@Component
struct DatePickerExample {
  @State isLunar: boolean = false
  private selectedDate: Date = new Date('2021-08-08')
  @State myDate: string = ''

  build() {
    Column() {
      Row({space:4}){
        Image($r('app.media.profile')).width(30).height(30).borderRadius(15)
        Column(){
          Text('ycz0417123456'.split('').join('\u200B'))
            .fontSize(15)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          TextArea({text:'2024-12-27'})
            .fontColor("#ff4c4a4a")
            .fontSize(12)
            .fontWeight(300)
            .width(70)
            .backgroundColor(Color.White)
        }
      }.width("20%")

    }.width('100%')
  }
}