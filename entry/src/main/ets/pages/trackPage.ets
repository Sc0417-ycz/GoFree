import router from '@ohos.router';
import { testUtil } from '../utils/TestUtil';
import emptyView1 from '../view/record/emptyView1';



interface ParamsObj {
  user_id: string;
}

@Entry
@Component
struct TrackPage {

  @State allStrategyCounts: Array<Array<string>> = [];
  @State user_id: string = '';


  aboutToAppear() {
    // 执行查询所有攻略信息的操作
    this.queryAllStrategyCounts();
    const params = router.getParams() as ParamsObj;
    this.user_id = params.user_id;
    console.log('主页(个人)传过来的用户ID数据', JSON.stringify(router.getParams()));
  }

   queryAllStrategyCounts = async  ()=> {
    // 先获取所有的省份数据，添加日志记录开始查询省份数据
    console.log('开始查询所有省份数据');
    const allProvinces = await testUtil.queryProvincesData(['PROVINCE_ID', 'PROVINCE_NAME', 'PROVINCE_IMAGE'], "MYPROVINCE");
    console.log('省份数据查询完成，共查询到', allProvinces.length, '个省份数据');

    for (const province of allProvinces) {
      const provinceName = province.province_name;

      // 获取当前省份下的所有城市数据，添加日志记录开始查询城市数据
      console.log(`开始查询 ${provinceName} 省的所有城市数据`);
      const allCities = await testUtil.queryCitiesDataByProvinceName(['CITY_NAME', 'CITY_ID', "CITY_CONTENT", 'CITY_IMAGE', 'PROVINCE_ID'], "MYCITY", provinceName);
      console.log(`${provinceName} 省的城市数据查询完成，共查询到`, allCities.length, '个城市数据');

      for (const city of allCities) {
        const cityName = city.city_name;

        try {
          // 查询每个省份、城市组合下对应的攻略数量，添加日志记录即将查询攻略数量
          console.log(`即将查询 ${provinceName} 省 ${cityName} 市的攻略数量`);
          // 查询每个省份、城市组合下对应的攻略数量，接收的返回值现在为字符串类型
          const strategyCountArr = await testUtil.queryStrategyCountByUserIdProvinceAndCity(this.user_id, provinceName, cityName);
          console.log(`成功查询到 ${provinceName} 省 ${cityName} 市的攻略数量，结果为：`, strategyCountArr);
          // 直接将拼接好的字符串添加到结果数组中
          this.allStrategyCounts.push(strategyCountArr)
          console.log('当前allStrategyCounts数组内容：', this.allStrategyCounts);


        } catch (error) {
          console.error(`在查询 ${provinceName} 省 ${cityName} 市的攻略数量时出现错误，错误信息: ${error}`);
        }

      }
    }
     // 数据查询完成后，对allStrategyCounts按照攻略数量进行排序（冒泡排序实现降序）
     const len = this.allStrategyCounts.length;
     for (let i = 0; i < len - 1; i++) {
       for (let j = 0; j < len - i - 1; j++) {
         const numA = Number(this.allStrategyCounts[j][2]);
         const numB = Number(this.allStrategyCounts[j + 1][2]);
         if (numA < numB) {
           // 交换两个元素的位置
           const temp = this.allStrategyCounts[j];
           this.allStrategyCounts[j] = this.allStrategyCounts[j + 1];
           this.allStrategyCounts[j + 1] = temp;
         }
       }
     }
     // 打印排序后的allStrategyCounts数组内容
     console.log('排序后的allStrategyCounts数组内容：', this.allStrategyCounts);
  }
  //判断是攻略信息是否大于0
  hasAnyStrategy(): boolean {
    for (const item of this.allStrategyCounts) {
      if (Number(item[2]) > 0) {
        return true;
      }
    }
    return false;
  }

  build() {
    Column(){
      Row(){
        Image($r('app.media.left1'))
          .width(30)
          .fillColor(Color.Grey)
          .onClick(()=>{
            router.back()
            router.RouterMode.Single
          })
        Text(`我的足迹`).fontSize(18).fontWeight(600)

        Image($r("app.media.helpone"))
          .width(30)
          .onClick(()=>{
            AlertDialog.show({
              message:'此页可以帮助您记录您到访过我国的哪些城市，并在此留下了哪些信息'
            })
          })

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
        left:10,
        right:10
      })



      if(this.hasAnyStrategy()){
        List(){
          ForEach(this.allStrategyCounts, (item:Array<string>,index:number) => {
            if(Number(item[2])>0){
              ListItem(){
                Row({space:7}){
                  Row(){
                    Text((index+1).toString()).fontSize(20).fontWeight(600).fontColor(Color.White).padding({left:9})
                  }.backgroundColor('#ffc8bdbd').width(30).height(30).borderRadius(15)
                  Text(`${item[0]}`).fontSize(20).fontWeight(600).fontColor(Color.White)
                  Text(`${item[1]}`).fontSize(20).fontWeight(600).fontColor(Color.White)
                  ForEach(Array.from({ length: Number(item[2]) }, (_, i) => i), () => {
                    Row(){
                      Image($r('app.media.flag'))
                    }
                    .width(20)
                    .height(20)
                    .margin({ left: 8 });
                  })

                }.margin({ top: 20,left:15 })
              }
            }
          })
        }.backgroundImage($r('app.media.bj5')).width('100%').height('100%')
      }else{
        emptyView1()
      }
    }
  }
}