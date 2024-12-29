import router from '@ohos.router'
import CityModel from '../model/CityModel';
import { testUtil } from '../utils/TestUtil';

interface ParamsObj {
  provinceName:string
  provinceImage:string
  cityName:string
  cityImage:string
  user_id:string
  username:string
  user_profile:string
}

@Entry
@Component
struct CityPage {

  @State opacityValue : number = 0.3;

  onPageShow(){
    this.opacityValue = 1
  }

  @State cities: CityModel[] = [];
  @State provinceName:string=''
  @State provinceImage:string = ''
  @State cityName:string=''
  @State cityImage:string=''
  @State user_id:string=''
  @State username:string=''
  @State user_profile:string=''

  aboutToAppear():void{
    console.log('主页传递过来的省份名数据',JSON.stringify(router.getParams()))
    const params = router.getParams() as ParamsObj
    this.provinceName = params.provinceName
    this.provinceImage = params.provinceImage
    this.cityName = params.cityName
    this.cityImage= params.cityImage
    this.user_id = params.user_id;
    this.username = params.username;
    this.user_profile = params.user_profile
    this.queryCities()
  }

  navigateToCityPage = async (cityName: string,cityImage:string,user_id:string,username:string, user_profile:string) => {
    let options = {
      url:'pages/CityContentPage',
      params: {
        cityName: cityName,
        cityImage: cityImage,
        user_id:user_id,
        username:username,
        user_profile:user_profile
      }

    };
    try {
      await router.pushUrl(options);
    } catch (err) {
      console.error(`导航到攻略界面失败: ${err.message}`);
    }
  }

  queryCities =async()=> {

    const res = await testUtil.queryCitiesDataByProvinceName(
      ["CITY_ID","CITY_NAME","CITY_CONTENT","CITY_IMAGE","PROVINCE_ID"],"MYCITY", this.provinceName, this.cityName
    )
    console.log(`城市数据库结果为：${JSON.stringify(res)}`)
    this.cities = res

  }



  build() {
    Stack({
      alignContent:Alignment.TopStart
    }){
      Text('').width('100%').height("100%") .backgroundImage(this.provinceImage).opacity(0.9)
      Row({space:4}){
        Image($r('app.media.left'))
          .width(30)
          .onClick(()=>{
            router.back()
            router.RouterMode.Single
          })
        Text("城市查询").fontSize(20).fontWeight(500).margin({top:5})
        Image($r('app.media.helpone')).width(30).margin({top:3})
          .onClick(()=>{
            AlertDialog.show({
              message:'此页您可以查询该省级行政区对应的城市信息'
            })
          })
      }

      .width("100%")
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({
        left:10,
        right:10
      })
      .margin({bottom:10})


      Column(){
        Text(`欢迎来到`).fontWeight(700).fontSize(30).padding(5).opacity(this.opacityValue).animation({ duration:1500, iterations:3 })
        Text(`${this.provinceName}`).fontWeight(600).fontSize(30).padding(15).opacity(this.opacityValue).animation({ duration:1500, iterations:3 })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .margin({top:40})
      .border({ color:'black', width:2, radius:10 }).shadow({ radius:10, offsetY:20, })





      TextInput({placeholder:"请输入你想要查询的城市名称"})
        .height(50)
        .margin({top:170})
        .onChange((value:string)=>{
          this.cityName = value
        })
      Button("搜索城市名称")
        .width("50%")
        .margin({top:230,left:92})
        .onClick(this.queryCities)




      //循环渲染城市信息
      List(){
        ForEach(this.cities,(item:CityModel,index:number)=>{
          ListItem(){
            Column(){
              Column(){
                Row({space:2}){
                  Text((index+1).toString()).fontSize(25).fontWeight(600)
                  Text('.').fontSize(25).fontWeight(600)
                  Text(item.city_name).fontSize(25).fontWeight(600)
                }.width("100%")
                Text(item.city_content).fontSize(20).fontWeight(600).width("100%").margin({bottom:10})
              }
              .onClick(() => this.navigateToCityPage(item.city_name,item.city_image,this.user_id,this.username,this.user_profile))
              .border({ color:'black', width:2, radius:10 })
              .shadow({ radius:10, offsetY:20, })
              .backgroundColor(Color.White)
              Image(item.city_image) .margin({top:10,bottom:300}).onClick(() => this.navigateToCityPage(item.city_name,item.city_image,this.user_id,this.username,this.user_profile))

            }
          }
        },(item:CityModel)=>item.city_id)
      }.margin({top:295})


    }
    .width('100%')
    .height('100%')


  }
}