import router from '@ohos.router';
import PhotoModel from '../model/PhotoModel'; // 确保导入正确的PhotoModel路径
import { testUtil } from '../utils/TestUtil';
import emptyView4 from '../view/record/emptyView4';
import emitter from '@ohos.events.emitter';

interface ParamsObj {
  cityName: string;
  user_id: string;
  username: string;
}

function callback(eventData) {
  this.queryPhotosAndText().then(() => {
    this.refresh();
  });
}

@Entry
@Component
struct MyPhoto {
  @State cityName: string = "";
  @State user_id: string = "";
  @State username: string = "";
  @State photos: PhotoModel[] = []; // 存放查询到的图片信息
  @State textContent: string = ""; // 用于存放从数据库查询到的与图片对应的文本内容
  @State FirstColor: string = '#ff000000'
  @State ChangeColor: string = '#ff7e7a7a'

  // 用于标记当前是否处于轮播显示模式，初始为false表示宫格显示模式
  @State isCarouselMode: boolean = false;

  // 记录遮罩层透明度，初始为0表示隐藏
  @State maskOpacity: number = 0;
  // 记录遮罩层的层级，初始为 -1表示在底层（不可见）
  @State maskIndex: number = -1;
  // 记录当前点击图片的索引，初始为 -1表示没有图片被点击
  @State currentSelectedIndex: number = -1;
  // 用于控制动画进度，取值范围0 - 1，0表示动画开始，1表示动画结束
  @State animationProgress: number = 0;

  // 用于标识添加图片按钮是否显示，初始为true表示显示
  @State isAddButtonVisible: boolean = true;

  @State currentSelectedPhotoModel: PhotoModel | null = null;

  aboutToAppear() {
    const params = router.getParams() as ParamsObj;
    this.cityName = params.cityName;
    this.username = params.username;
    this.user_id = params.user_id;
    console.log(`(我的${this.cityName}图片页) 总图片页传递过来的城市名数据`, JSON.stringify(router.getParams()));

    let innerEvent = { eventId: 2 };
    emitter.on(innerEvent,callback.bind(this));
    console.log('接收订阅数据：'+JSON.stringify(innerEvent))


    this.queryPhotosAndText().then(() => {
      this.refresh();
    }).catch((error) => {
      console.error('查询图片信息出现错误:', error);
    })
  }



  queryPhotosAndText = async () => {
    try {
      // 假设查询所有列信息，实际可根据需求指定具体列，确保数据库表结构中有存储文本内容的字段且能通过该查询获取到
      const columns = ['PHOTO_ID', 'IMAGE', 'TEXT_CONTENT', 'CITY_ID', 'USER_ID'];
      const res = await testUtil.queryPhotoDataByCityNameAndUsername(columns, 'MYPHOTO', this.cityName, this.username);
      console.log('查询到的图片数据:', JSON.stringify(res));
      if (res) {
        // 直接赋值查询到的所有图片数据对象数组（每个对象包含一条文本和对应图片信息）
        this.photos = res;
        return res;
        // 取第一个对象的文本内容作为初始展示文本内容（可根据实际需求调整，比如如果每个对象文本内容不同，这里可能需要其他展示逻辑）
        if (this.photos.length > 0) {
          this.textContent = this.photos[0].text_content;
        }
      }
    } catch (error) {
      console.error('查询图片信息出现错误:', error);
    }
  }


  async queryPhotosAndText1() {
    try {
      // 假设查询所有列信息，实际可根据需求指定具体列，确保数据库表结构中有存储文本内容的字段且能通过该查询获取到
      const columns = ['PHOTO_ID', 'IMAGE', 'TEXT_CONTENT', 'CITY_ID', 'USER_ID'];
      const queriedPhotoData = await testUtil.queryPhotoDataByCityNameAndUsername(columns, 'MYPHOTO', this.cityName, this.username);
      console.log('查询到的图片数据:', JSON.stringify(queriedPhotoData));
      if (queriedPhotoData) {
        // 直接赋值查询到的所有图片数据对象数组（每个对象包含一条文本和对应图片信息）
        this.photos = queriedPhotoData;
        // 设置为轮播显示模式
        this.isCarouselMode = true;
      }
    } catch (error) {
      console.error('查询图片信息出现错误:', error);
    }
  }

  refresh() {
    // 使用ArkTS的@State修饰的变量，通过重新赋值来触发组件的重新渲染
    this.photos = [...this.photos];
  }

  build() {
    Column() {
      Stack({
        alignContent: Alignment.TopStart
      }) {
        Row() {
          Image($r('app.media.left1'))
            .width(30)
            .fillColor(Color.Grey)
            .onClick(() => {
              router.back();
              router.RouterMode.Single;
            })
          Text(`我的${this.cityName}图片`).fontSize(18).fontWeight(600);

          Image($r("app.media.add"))
            .width(30)
            .onClick(() => {
              router.pushUrl({
                url: 'pages/addPhotoPage',
                params: { cityName: this.cityName, user_id: this.user_id, username: this.username }
              });
              router.RouterMode.Single;
            })
        }
        .border({
          width: { bottom: 2 },
          color: Color.Gray
        })
        .borderRadius(15)
        .justifyContent(FlexAlign.SpaceBetween)
        .width('100%')
        .height(50)
        .backgroundColor(Color.White)
        .padding({
          left: 10,
          right: 10
        })

        if (this.photos.length > 0) {
          Row() {
            Text('宫格显示').fontSize(20).fontWeight(500).fontColor(this.FirstColor)
              .onClick(() => {
                this.isCarouselMode = false
                this.FirstColor = '#ff000000'
                this.ChangeColor = '#ff7e7a7a'
                this.queryPhotosAndText()
              })
            Image($r('app.media.change')).width(22)

            Text('轮播显示').fontSize(20).fontWeight(500).fontColor(this.ChangeColor)
              .onClick(() => {
                this.queryPhotosAndText1();
                this.ChangeColor = '#ff000000'
                this.FirstColor = '#ff7e7a7a'
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .margin({ top: 55 })
          .border({
            width: 2,
            color: Color.Gray
          })
          .borderRadius(15)
          .padding({
            left: 30,
            right: 30
          })

          // 根据是否处于轮播显示模式来决定使用不同的展示方式
          if (this.isCarouselMode) {
              List() {
                ForEach(this.photos, (photoModel: PhotoModel, index: number) => {
                  ListItem() {
                    Column() {
                      // 展示对应的文本内容
                      Row() {
                        Text(photoModel.text_content)
                          .fontSize(20).fontWeight(500)
                      }
                      // 使用Swiper组件来展示图片，实现轮播效果
                      Column() {
                        Swiper() {
                          ForEach(photoModel.image, (item, index1: number) => {
                            Image(item)
                              .width('100%').height('70%')
                              .onClick(() => {  // 传递图片所在的PhotoModel和索引
                                this.startShowAnimation(photoModel, index1);  // 传递正确参数给动画显示方法
                              });
                          })
                        }
                        .loop(true)
                        .autoPlay(true)
                        .interval(3000)
                      }.margin({ top: 20 ,bottom:20})

                      Text(index === this.photos.length - 1? '这是最后一组图片' : '请查看下组图片')
                        .fontSize(20)
                        .margin({ bottom: 30 })
                        .border({
                          width: { bottom: 3 },
                          style: BorderStyle.Dashed
                        }).width('100%')

                    }
                  }
                })
              }
            .scrollBar(BarState.Off)
            .margin({ top: 100 })
          } else {
              List() {
                ForEach(this.photos, (photoModel: PhotoModel, index: number) => {
                  ListItem() {
                    Column() {
                      // 展示对应的文本内容
                      Row() {
                        Text(photoModel.text_content)
                          .fontSize(20).fontWeight(500)
                      }

                      Grid() {

                        ForEach(photoModel.image, (item, index1: number) => {
                          GridItem() {
                            Image(item)
                              .width(120)
                              .height(120)
                              .onClick((imageData: any) => {  // 传递图片所在的PhotoModel和索引
                                this.startShowAnimation(photoModel, index1);  // 传递正确参数给动画显示方法
                              });
                          }
                        })
                      }
                      .rowsGap(8)
                      .columnsGap(8)
                      .margin({ top: 20 ,bottom:20})

                      Text(index === this.photos.length - 1? '这是最后一组图片' : '请查看下组图片')
                        .fontSize(20)
                        .margin({ bottom: 30 })
                        .border({
                          width: { bottom: 3 },
                          style: BorderStyle.Dashed
                        }).width('100%');
                    }.width("100%")
                  }
                })
              }
            .scrollBar(BarState.Off)
            .margin({ top:100 })
          }
        } else {
          emptyView4();
        }
        // 根据当前点击图片的索引来显示对应大图以及遮罩效果，添加动画过渡，确保使用正确图片url格式
        if (this.currentSelectedIndex!== -1) {
          Column() {
            Image(this.getImageByIndex(this.currentSelectedIndex))  // 修改此处获取图片的方式
              .width("100%")
              .opacity(this.calculateOpacity())
              .zIndex(this.calculateZIndex());
          }
          .justifyContent(FlexAlign.Center)
          .backgroundColor('#e6a7a4a4')
          .width("100%")
          .height("100%")
          .onClick(() => {
            this.startHideAnimation();
          });
        }
      }
    }
  }


  // 新增方法，根据索引从对应图片数据源获取图片数据（这里假设图片数据是个简单的地址字符串等形式，可根据实际情况调整）
  getImageByIndex(index: number): string {
    return this.currentSelectedPhotoModel && this.currentSelectedPhotoModel.image && this.currentSelectedPhotoModel.image.length > index? this.currentSelectedPhotoModel.image[index] : "";
  }

  startShowAnimation(photoModel: PhotoModel, index: number) {
    // 记录当前点击图片所在的PhotoModel和索引
    this.currentSelectedPhotoModel = photoModel;
    this.currentSelectedIndex = index;

    let intervalId = setInterval(() => {
      if (this.animationProgress < 1) {
        this.animationProgress = Math.min(1, this.animationProgress + 0.05); // 每次增加动画进度，步长调小为0.05，让变化更细腻
        // 根据动画进度更平滑地更新遮罩层透明度和层级，例如使用线性插值等方式
        this.maskOpacity = this.animationProgress;
        this.maskIndex = Math.floor(this.animationProgress * 100) - 1;
      } else {
        clearInterval(intervalId);
      }
    }, 16); // 提高定时器频率，每16毫秒更新一次动画，使动画更细腻，可按需调整

    // 可以添加额外的逻辑判断，确保在动画接近结束时，遮罩层属性准确达到预期值
    if (this.animationProgress === 1) {
      this.maskOpacity = 1;
      this.maskIndex = 99;
    }
  }

  startHideAnimation() {
    let intervalId = setInterval(() => {
      if (this.animationProgress > 0) {
        this.animationProgress = Math.max(0, this.animationProgress - 0.05); // 每次减小动画进度，步长调小为0.05，让变化更细腻
        // 根据动画进度更平滑地更新遮罩层透明度和层级，例如使用线性插值等方式
        this.maskOpacity = this.animationProgress;
        this.maskIndex = Math.floor(this.animationProgress * 100) - 1;
      } else {
        clearInterval(intervalId);
        // 动画结束后重置相关状态变量
        this.currentSelectedIndex = -1;
        this.currentSelectedPhotoModel = null;
        this.maskOpacity = 0;
        this.maskIndex = -1;
      }
    }, 16); // 提高定时器频率，每16毫秒更新一次动画，让动画更细腻，可按需调整

    // 这里可以额外添加一些逻辑，比如在动画即将结束时，做一些微调来确保完全隐藏等
    if (this.animationProgress === 0) {
      this.maskOpacity = 0;
      this.maskIndex = -1;
    }
  }

  // 根据动画进度计算遮罩层透明度，与原代码一致，此处省略部分重复代码注释
  calculateOpacity(): number {
    return this.animationProgress;
  }

  // 根据动画进度计算遮罩层层级，与原代码一致，此处省略部分重复代码注释
  calculateZIndex(): number {
    return Math.floor(this.animationProgress * 100) - 1;
  }
}