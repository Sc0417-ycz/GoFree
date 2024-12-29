import router from '@ohos.router'
import recordCommunity from '../view/record/recordCommunity';
import recordTrip from '../view/record/recordTrip';

import { testUtil } from '../utils/TestUtil'
import relationalStore from '@ohos.data.relationalStore';
import ProvinceModel from '../model/ProvinceModel';
import PreferencesUtil from '../utils/PreferencesUtil';
import picker from '@ohos.file.picker';

//中国省份信息
const CHINA_PROVINCES = [
  "北京市", "天津市", "河北省", "山西省", "内蒙古自治区",
  "辽宁省", "吉林省", "黑龙江省", "上海市", "江苏省",
  "浙江省", "安徽省", "福建省", "江西省", "山东省",
  "河南省", "湖北省", "湖南省", "广东省", "广西壮族自治区",
  "海南省", "重庆市", "四川省", "贵州省", "云南省",
  "西藏自治区", "陕西省", "甘肃省", "青海省", "宁夏回族自治区",
  "新疆维吾尔自治区", "香港特别行政区", "澳门特别行政区", "台湾省"
];
const CHINA_PROVINCES_IMAGE = [
  "images/beijing.jpg", "images/tianjin.jpg", "images/hebei.jpg", "images/shanxi.jpg", "images/neimenggu.jpg",
  "images/liaoning.jpg", "images/jilin.jpg", "images/heilongjiang.jpg", "images/shanghai.jpg", "images/jiangsu.jpg",
  "images/zhejiang.jpg", "images/anhui.jpg", "images/fujian.jpg", "images/jiangxi.jpg", "images/shandong.jpg",
  "images/henan.jpg", "images/hubei.jpg", "images/hunan.jpg", "images/guangdong.jpg", "images/guangxi.jpg",
  "images/hainan.jpg", "images/chongqing.jpg", "images/sichuan.jpg", "images/guizhou.jpg", "images/yunnan.jpg",
  "images/xizang.jpg", "images/shaanxi3.jpg", "images/gansu.jpg", "images/qinghai.jpg", "images/ningxia.jpg",
  "images/xinjiang.jpg", "images/xianggan.jpg", "images/aomen.jpg", "images/taiwan.jpg"
];
//辽宁省城市信息
const LIAONING_CITIES = [
  "沈阳市", "大连市", "鞍山市", "抚顺市", "本溪市",
  "丹东市", "锦州市", "营口市", "阜新市", "辽阳市",
  "盘锦市", "铁岭市", "朝阳市", "葫芦岛市"
];
const LIAONING_CITIES_CONTENT = [
  "辽宁省最具省会风范与多元文化融合性的城市", "辽宁省最具时尚浪漫气息与经济活力的城市",
  "辽宁省最具钢铁工业代表性与坚韧气质的城市", "辽宁省最具历史沧桑感与资源转型特色的城市",
  "辽宁省最具自然山水灵韵与工业文化交织特色的城市", "辽宁省最具边境异域风情与商贸往来活力的城市",
  "辽宁省最具交通枢纽战略意义与历史传承的城市", "辽宁省最具沿海开放先驱底蕴与商业文化传承的城市",
  "辽宁省最具能源转型探索精神与地域文化特色的城市", "辽宁省最具古都韵味与历史文化绵延性的城市",
  "辽宁省最具湿地生态魅力与石油产业影响力的城市", "辽宁省最具东北民俗文化浓郁性与农业根基的城市",
  "辽宁省最具古老文明底蕴与考古文化价值的城市", "辽宁省最具沿海门户特色与旅游资源潜力的城市"
];
const LIAONING_CITIES_IMAGE = [
  "images/LiaoningCities/shenyang.jpg",
  "images/LiaoningCities/dalian.jpg",
  "images/LiaoningCities/anshan.jpg",
  "images/LiaoningCities/fushun.jpg",
  "images/LiaoningCities/benxi.jpg",
  "images/LiaoningCities/dandong.jpg",
  "images/LiaoningCities/jinzhou.jpg",
  "images/LiaoningCities/yingkou.jpg",
  "images/LiaoningCities/fuxin.jpg",
  "images/LiaoningCities/liaoyang.jpg",
  "images/LiaoningCities/panjin.jpg",
  "images/LiaoningCities/tieling.jpg",
  "images/LiaoningCities/chaoyang.jpg",
  "images/LiaoningCities/huludao.jpg"
];
//湖北省城市信息
const HUBEI_CITIES = [
  "武汉市", "黄石市", "十堰市", "宜昌市", "襄阳市",
  "鄂州市", "荆门市", "孝感市", "荆州市", "黄冈市",
  "咸宁市", "随州市", "恩施土家族苗族自治州", "仙桃市",
  "潜江市", "天门市", "神农架林区"
];
const HUBEI_CITIES_CONTENT = [
  "湖北省最具交通枢纽地位与科教实力的城市",
  "湖北省最具矿冶文化底蕴与工业传承的城市",
  "湖北省最具汽车产业特色与道教文化魅力的城市",
  "湖北省最具水电资源优势与旅游吸引力的城市",
  "湖北省最具军事战略意义与历史文化厚重感的城市",
  "湖北省最具吴楚文化交融特色与滨江风光的城市",
  "湖北省最具农耕与工业融合发展特色的城市",
  "湖北省最具孝文化影响力与民俗风情的城市",
  "湖北省最具楚文化传承与古城韵味的城市",
  "湖北省最具教育资源优势与文化名人效应的城市",
  "湖北省最具温泉养生文化与生态旅游潜力的城市",
  "湖北省最具编钟文化代表性与特色民俗的城市",
  "湖北省最具少数民族风情与山区自然风光的城市",
  "湖北省最具轻纺产业活力与水乡特色的城市",
  "湖北省最具石油化工产业规模与水乡园林风貌的城市",
  "湖北省最具茶文化内涵与田园风光的城市",
  "湖北省最具原始森林生态与珍稀物种资源的城市"
];
const HUBEI_CITIES_IMAGE = [
  "images/HubeiCities/wuhan.jpg",
  "images/HubeiCities/huangshi.jpg",
  "images/HubeiCities/shiyan.jpg",
  "images/HubeiCities/yichang.jpg",
  "images/HubeiCities/xiangyang.jpg",
  "images/HubeiCities/ezhou.jpg",
  "images/HubeiCities/jingmen.jpg",
  "images/HubeiCities/xiaogan.jpg",
  "images/HubeiCities/jingzhou.jpg",
  "images/HubeiCities/huanggang.jpg",
  "images/HubeiCities/xianning.jpg",
  "images/HubeiCities/suizhou.jpg",
  "images/HubeiCities/enshi.jpg",
  "images/HubeiCities/xiantao.jpg",
  "images/HubeiCities/qianjiang.jpg",
  "images/HubeiCities/tianmen.jpg",
  "images/HubeiCities/shennongjia.jpg"
];


interface ParamsObj {
  user_id:string
  username:string
}



@CustomDialog
struct ProvinceList{

  controller: CustomDialogController = new CustomDialogController({
    builder:ProvinceList()
  })
  @State user_id:string=''
  @State username:string=''
  @State province: ProvinceModel[] = []
  @State myProvince:string=''
  private cityData: relationalStore.ValuesBucket[]= []
  @Consume selectedImagePath: string

  buildLiaoningCityDataArray() {
    this.cityData = [];
    // 确保两个数组长度一致，否则可能出现数据不匹配的情况
    const minLength = Math.min(LIAONING_CITIES.length, LIAONING_CITIES_CONTENT.length);
    for (let i = 0; i < minLength; i++) {
      const valueBucket: relationalStore.ValuesBucket = {
        CITY_NAME: LIAONING_CITIES[i],
        CITY_CONTENT:LIAONING_CITIES_CONTENT[i],
        CITY_IMAGE:LIAONING_CITIES_IMAGE[i],
        PROVINCE_NAME: "辽宁省"
      };
      this.cityData.push(valueBucket);
    }
  }

  insertLiaoningCity = () => {
    this.buildLiaoningCityDataArray();
    testUtil.insertCityData("MYCITY", this.cityData);
  };

  buildHubeiCityDataArray() {
    this.cityData = [];
    // 确保两个数组长度一致，否则可能出现数据不匹配的情况
    const minLength = Math.min(HUBEI_CITIES.length, HUBEI_CITIES_CONTENT.length);
    for (let i = 0; i < minLength; i++) {
      const valueBucket: relationalStore.ValuesBucket = {
        CITY_NAME: HUBEI_CITIES[i],
        CITY_CONTENT:HUBEI_CITIES_CONTENT[i],
        CITY_IMAGE:HUBEI_CITIES_IMAGE[i],
        PROVINCE_NAME: "湖北省"
      };
      this.cityData.push(valueBucket);
    }
  }

  insertHubeiCity = () => {
    this.buildHubeiCityDataArray();
    testUtil.insertCityData("MYCITY", this.cityData);
  };


  async aboutToAppear(){
    const params = router.getParams() as ParamsObj
    this.user_id = params.user_id
    this.username = params.username
    console.log('(弹窗)登录页传递过来的用户名数据',JSON.stringify(router.getParams()))
    this.queryProvince()
    const hasInsertedCities = await PreferencesUtil.getPreferencesValue("MyPreferences", 'hasInsertedCities', false) as boolean;
    if (!hasInsertedCities) {
      // 如果城市数据未插入，执行插入城市数据操作（包含辽宁、湖北城市数据插入）
      this.insertLiaoningCity();
      this.insertHubeiCity();
      // 插入成功后，将城市数据插入标记设置为true
      await PreferencesUtil.putPreferencesValue("MyPreferences", 'hasInsertedCities', true);
    }
  }
  queryProvince = async () => {
    const res = await testUtil.queryProvincesData(
      ["PROVINCE_ID","PROVINCE_NAME","PROVINCE_IMAGE"],
      "MYPROVINCE",
      this.myProvince

    );
    console.log(`数据库结果为：${JSON.stringify(res)}`);

    this.province = res;
  }
  //导航到城市页面的方法
  navigateToCityPage = async (provinceName: string,provinceImage:string,user_id:string,username:string,user_profile:string) => {
    let options = {
      url:'pages/CityPage',
      params: {
        provinceName: provinceName,
        provinceImage:provinceImage,
        user_id:user_id,
        username:username,
        user_profile:user_profile
      }
    };

    try {
      await router.pushUrl(options);
    } catch (err) {
      console.error(`导航到城市界面失败: ${err.message}`);
    }
  }

  build(){
    Column(){
      Row(){
        TextInput({placeholder:"请输入你想要查询的省份名称"})
          .onChange((value:string)=>{
            this.myProvince = value
          })
      }
      Button('搜索省份名称')
        .onClick(this.queryProvince)
        .width('50%')
        .margin({bottom:10})

      List({ space: 20 }) {
        ForEach(this.province, (item:ProvinceModel, index: number) => {
          ListItem() {
            Column(){
              Text(item.province_name)
                .fontSize(20)
                .onClick(() =>{
                  this.navigateToCityPage(item.province_name,item.province_image,this.user_id,this.username,this.selectedImagePath)
                  this.controller.close()
                 })
            }.width("100%")
          }
        }, (item:ProvinceModel)=>item.province_id);
      }
    }
  }
}

@Extend(Text)
function province(){
  .onClick(()=>{
    AlertDialog.show({
      message:'请使用上方搜素框搜索您想去的省级行政区！'
    })
  })
  .layoutWeight(1)
  .width(20)
  .height(40)
  .backgroundColor('#87CEFA')
  .borderRadius(20)
  .border({
    width:2,
    color:Color.Gray
  })
  .textAlign(TextAlign.Center)
  .fontWeight(700)
}


@CustomDialog
struct ConfirmAvatarDialog {
  @Consume username: string;
  @Consume selectedImagePath: string;
  @Consume user_id: string;
  @Consume originalImagePath: string;

  controller1: CustomDialogController = new CustomDialogController({
    builder: ConfirmAvatarDialog()
  });

  confirmInsert = () => {
    testUtil.insertUserProfile('USER', this.username, this.selectedImagePath).then(() => {
      console.log('头像图片插入成功');
      this.controller1.close();
    }).catch((error) => {
      console.error('插入头像图片时出现错误:', error);
    });
  };

  build() {
    Column() {
      Text('是否确认添加此头像？').fontSize(20).textAlign(TextAlign.Center).margin({ top: 20 });
      Row({space:20}) {
        Button('确认').width(100).onClick(this.confirmInsert).margin({ top: 30 });
        Button('取消').width(100).onClick(() => {
          // 直接更新 selectedImagePath 为 originalImagePath
          this.selectedImagePath = this.originalImagePath;
          this.controller1.close();
        }).margin({ top: 30 });
      }.width("100%").justifyContent(FlexAlign.Center)
    }.height('150').backgroundColor(Color.White)
  }
}



@Entry
@Component
struct Index {
  controller: CustomDialogController = new CustomDialogController({
    builder: ProvinceList()
  })

  controller1: CustomDialogController = new CustomDialogController({
    builder: ConfirmAvatarDialog()
  })

  @State selectedIndex: number = 0
  @Provide user_id: string = ''
  @Provide username: string = ''
  @Provide selectedImagePath: string = ''
  @Provide originalImagePath: string = '';

  async selectImage() {
    try {
      let PhotoSelectOptions = new picker.PhotoSelectOptions();
      PhotoSelectOptions.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE;
      PhotoSelectOptions.maxSelectNumber = 1;

      let photoPicker = new picker.PhotoViewPicker();
      photoPicker.select(PhotoSelectOptions).then((PhotoSelectResult) => {
        if (PhotoSelectResult && PhotoSelectResult.photoUris.length > 0) {
          // 保存当前的头像路径作为原来的头像路径
          this.originalImagePath = this.selectedImagePath;
          this.selectedImagePath = PhotoSelectResult.photoUris[0];

          this.controller1.open();
        }
      }).catch((err) => {
        console.error(`PhotoViewPicker.select failed with. Code: ${err.code}, message: ${err.message}`);
      });
    } catch (err) {
      console.error(`PhotoViewPicker.failed with. Code: ${err.code}, message: ${err.message}`);
    }
  }

  async aboutToAppear() {
    const hasInserted = await PreferencesUtil.getPreferencesValue("MyPreferences", 'hasInserted', false) as boolean;
    const params = router.getParams() as ParamsObj;
    this.user_id = params.user_id;
    this.username = params.username;
    console.log('(主页)登录页传递过来的用户名数据', JSON.stringify(router.getParams()));
    if (!hasInserted) {
      // 如果标记为false，表示还未插入省份数据，执行插入操作
      this.insertAllChinaProvinces();
      // 插入成功后，将标记设置为true，表示省份数据已插入过了
      await PreferencesUtil.putPreferencesValue("MyPreferences", 'hasInserted', true);
    }
    // 查询用户头像路径
    const imagePath = await testUtil.queryUserProfile('USER', this.user_id);
    if (imagePath) {
      this.selectedImagePath = imagePath;
      this.originalImagePath = imagePath;
    }
  }

  private provinceData: relationalStore.ValuesBucket[] = [];

  buildProvinceDataArray() {
    for (let i = 0; i < CHINA_PROVINCES.length; i++) {
      const valueBucket: relationalStore.ValuesBucket = {
        PROVINCE_NAME: CHINA_PROVINCES[i],
        PROVINCE_IMAGE: CHINA_PROVINCES_IMAGE[i]
      };
      this.provinceData.push(valueBucket);
    }
  }

  insertAllChinaProvinces = () => {
    this.buildProvinceDataArray();
    testUtil.insertProvinceData("MYPROVINCE", this.provinceData);
  };

  @Builder
  centerBuilder() {
    Image($r('app.media.logo1'))
      .width(60)
      .margin({ bottom: 10 })
      .borderRadius(30)
  }

  @Builder
  myBuilder(itemIndex: number, title: string, img: ResourceStr) {
    Column() {
      Image(img)
        .width(25)
      Text(title)
        .fontSize(15)
        .fontColor(itemIndex === this.selectedIndex? '#ff317dcd' : Color.Black)
    }
  }

  build() {
    Tabs({ barPosition: BarPosition.End }) {
      TabContent() {
        Stack({ alignContent: Alignment.Bottom }) {
          Stack({ alignContent: Alignment.Top }) {
            //头部
            Row() {
              //左边
              Column() {
                Text('武汉').fontColor(Color.Red).fontSize(16)
                Text('多云 15℃').fontColor(Color.Red).fontSize(12)
                Image($r('app.media.chevron_down'))
                  .position({
                    x: 40,
                    y: 0
                  })
                  .width(15)
                  .fillColor('#fff')
              }

              //中间
              Row() {
                Image($r('app.media.lightbulb'))
                  .width(20)
                  .fillColor('#666')
                  .margin({ left: 5, right: 5 })
                TextInput({ placeholder: '现在就出发' })
                  .backgroundColor('#fff')
                  .layoutWeight(1)
                  .onClick(() => {
                    this.controller.open()
                  })
                Text('搜索')
                  .width(55)
                  .fontWeight(700)
                  .textAlign(TextAlign.Center)
                  .border({
                    width: { left: 1 },
                    color: '#ccc'
                  })
              }
              .height(32)
              .layoutWeight(1)
              .backgroundColor(Color.White)
              .borderRadius(5)
              .margin({ left: 25, right: 12 })

              //右边
              Image($r('app.media.helpone'))
                .width(26)
                .fillColor('#fff')
                .onClick(() => {
                  AlertDialog.show({
                    message: '此页为本APP主页，您可以选择中国的各个省市，查看到访过该地其他游客的照片和攻略，也可以存入您到访过此地的旅游照片和攻略以便他人查看和分享，当然您也可以将自己存入的旅行内容隐藏仅供自己记录与查看（如若想设置仅供自己查看，请去“我的”页面设置中修改）'
                  })
                })
            }
            .padding({ left: 10, right: 10 })
            .width('100%')
            .height(60)
            .zIndex(100)


            //主体
            Scroll() {
              Column() {
                Column() {
                  Row() {
                    Image($r('app.media.location'))
                      .fillColor('#fff')
                      .width(26)
                    Text('热门省份')
                      .fontSize(18)
                      .fontWeight(500)

                  }
                  Row({ space: 2 }) {
                    Text('北京').province()
                    Text('天津').province()
                    Text('上海').province()
                    Text('重庆').province()
                  }
                  .margin({ left: 10, right: 10, top: 7 })
                  Row({ space: 2 }) {
                    Text('湖北').province()
                    Text('湖南').province()
                    Text('陕西').province()
                    Text('四川').province()
                  }
                  .margin({ left: 10, right: 10, top: 15 })
                  Row({ space: 4 }) {
                    Text('云南').province()
                    Text('海南').province()
                    Text('新疆').province()
                  }
                  .margin({ left: 10, right: 10, top: 15 })
                }
              }
              .width('100%')
              .padding({ top: 60, bottom: 60 })
            }

          }
          .width('100%')
          .height('100%')


        }
        .backgroundImage($r('app.media.indexbj'))
        .width('100%')
        .height('100%')
      }
      .tabBar(this.myBuilder(0, '主页', $r('app.media.home')))


      TabContent() {
        recordCommunity()
      }
      .tabBar(this.myBuilder(1, '社区', $r('app.media.community')))


      TabContent() {
        Image($r('app.media.passion'))

      }
      .tabBar(this.centerBuilder())


      TabContent() {
        recordTrip()
      }
      .tabBar(this.myBuilder(3, '出行', $r('app.media.plane')))


      TabContent() {
        Column() {
          Row() {
            Image($r("app.media.envelope"))
              .width(35)
            Text('个人中心').fontSize(18)
            Image($r('app.media.helpone'))
              .width(30)
              .fillColor(Color.Grey)
              .onClick(() => {
                AlertDialog.show({
                  message: '个人中心可以帮助您整理并查看自己的足迹，点赞，收藏，方便您的出行与记录'
                })
              })
          }
          .justifyContent(FlexAlign.SpaceBetween)
          .width('100%')
          .height(50)
          .backgroundColor(Color.White)
          .padding({
            left: 10,
            right: 10
          })
          Column() {
            Row() {
              if (this.selectedImagePath) {
                // 如果有选择的图片路径，显示选择的图片
                Image(this.selectedImagePath)
                  .height(100)
                  .width(100)
                  .borderRadius(50)
                  .margin(20)
                  .onClick(() => this.selectImage());
              } else {
                Image($r('app.media.profile1'))
                  .height(80)
                  .width(80)
                  .backgroundColor(Color.White)
                  .borderRadius(40)
                  .padding(20)
                  .margin(20)
                  .onClick(() => this.selectImage());
              }
            }

            Text(this.username)
              .fontSize(20)
              .height(40)
              .borderRadius(20)
              .backgroundColor('#ccc')
              .textAlign(TextAlign.Center)
              .padding({ left: 20, right: 20, top: 5, bottom: 5 })
          }
          .width('100%')


          Column() {
            Row() {
              Image($r('app.media.location1')).height(30).width(30).margin({ left: 10 })
              Text('我的足迹').fontSize(23).fontColor(Color.White).fontWeight(500)
              Image($r('app.media.rightone')).height(30).width(30).margin({ left: 150, right: 10 })
            }
            .margin({ top: 10 })
            .height(80)
            .border({
              color: 'black',
              width: 2,
              radius: 10
            })
            .shadow({
              radius: 10,
              offsetY: 20
            })
            .onClick(() => {
              router.pushUrl({
                url: 'pages/trackPage',
                params: { user_id: this.user_id }
              })
              router.RouterMode.Single
            })

            Row() {
              Image($r('app.media.like')).height(30).width(30).margin({ left: 10 })
              Text('我的点赞').fontSize(23).fontColor(Color.White).fontWeight(500)
              Image($r('app.media.rightone')).height(30).width(30).margin({ left: 150, right: 10 })
            }
            .margin({ top: 20 })
            .height(80)
            .border({
              color: 'black',
              width: 2,
              radius: 10
            })
            .shadow({
              radius: 10,
              offsetY: 23
            })
            .onClick(() => {
              router.pushUrl({
                url: 'pages/myLikePage',
                params: { user_id: this.user_id }
              })
              router.RouterMode.Single
            })

            Row() {
              Image($r('app.media.collect')).height(30).width(30).margin({ left: 10 })
              Text('我的收藏').fontSize(23).fontColor(Color.White).fontWeight(500)
              Image($r('app.media.rightone')).height(30).width(30).margin({ left: 150, right: 10 })
            }
            .margin({ top: 20 })
            .height(80)
            .border({
              color: 'black',
              width: 2,
              radius: 10
            })
            .shadow({
              radius: 10,
              offsetY: 23
            })
            .onClick(() => {
              router.pushUrl({
                url: 'pages/myFavoritePage',
                params: { user_id: this.user_id }
              })
              router.RouterMode.Single
            })

            Row() {
              Image($r('app.media.settings')).height(30).width(30).margin({ left: 10 })
              Text('设置').fontSize(23).fontColor(Color.White).fontWeight(500)
              Image($r('app.media.rightone')).height(30).width(30).margin({ left: 200, right: 10 })
            }
            .margin({ top: 20 })
            .height(80)
            .border({
              color: 'black',
              width: 2,
              radius: 10
            })
            .shadow({
              radius: 10,
              offsetY: 23
            })
            .onClick(() => {
              router.pushUrl({
                url: 'pages/settingsPage',
                params: { user_id: this.user_id }
              })
              router.RouterMode.Single
            })


          }.padding({ top: 20 })
        }

        .width('100%')
        .height('100%')
        .backgroundImage($r('app.media.bj5'))
      }
      .tabBar(this.myBuilder(4, '我的', $r('app.media.me')))


    }
    .onChange((index: number) => {
      this.selectedIndex = index
    })
    .animationDuration(0)
    .scrollable(false)
  }
}