import router from '@ohos.router';
import StrategyModel from '../model/StrategyModel';
import { testUtil } from '../utils/TestUtil';
import emptyView from '../view/record/emptyView';

interface ParamsObj {
  cityName: string;
  user_id: string;
  username: string;
}

@Entry
@Component
struct myStrategy {
  onPageShow() {
    this.myScroll;
  }

  myScroll: Scroller = new Scroller();
  @State strategy: StrategyModel[] = [];
  @State cityName: string = "";
  @State user_id: string = "";
  @State username: string = "";

  // 记录当前点击图片所在的攻略以及图片在攻略中的索引
  @State currentSelectedStrategy: StrategyModel | null = null;
  @State currentSelectedIndex: number = -1;

  // 记录遮罩层透明度，初始为0表示隐藏
  @State maskOpacity: number = 0;
  // 记录遮罩层的层级，初始为 -1表示在底层（不可见）
  @State maskIndex: number = -1;
  // 用于控制动画进度，取值范围0 - 1，0表示动画开始，1表示动画结束
  @State animationProgress: number = 0;

  // 用于记录当前每个攻略是否被当前用户点赞，初始化为false，后续根据查询结果更新
  @State isLiked: boolean[] = [];

  @State isshoucangClicked: boolean = false;

  aboutToAppear(): void {
    const params = router.getParams() as ParamsObj;
    this.cityName = params.cityName;
    this.username = params.username;
    this.user_id = params.user_id;
    console.log(`(我的${this.cityName}攻略页) 总攻略页传递过来的城市名数据`, JSON.stringify(router.getParams()));

    // 页面即将显示时，先查询攻略数据，在攻略数据查询完成后再去查询点赞状态并显示日志
    this.queryStrategy().then(() => {
      this.initLikeStatus().then(() => {
        // 手动触发页面刷新，确保图标颜色能根据最新点赞状态正确显示
        this.refresh();
      });
    });
  }

  // 查询当前用户对所有展示攻略的点赞状态的方法，确保正确获取和设置每个攻略的点赞状态，添加日志打印每个攻略的点赞状态
  initLikeStatus = async () => {
    const userId = this.user_id;
    for (let i = 0; i < this.strategy.length; i++) {
      const isLiked = await testUtil.isUserLikedStrategy('STRATEGY_LIKES', this.strategy[i].strategy_id, userId);
      this.isLiked[i] = isLiked;
      console.log(`攻略 ${this.strategy[i].strategy_id} 的点赞状态为: ${isLiked? '已点赞' : '未点赞'}`);
    }
    return this.isLiked;
  }

  queryStrategy = async () => {
    const res = await testUtil.queryStrategyDataByUsernameAndCityName(
      ["STRATEGY_ID", "STRATEGY_NAME", "AUTHOR_NAME", "DATE", "CONTENT", "IMAGE_PATH"],
      "MYSTRATEGY",
      this.cityName,
      this.username
    );
    console.log(`攻略数据库结果为：${JSON.stringify(res)}`);

    this.strategy = res;
    // 根据查询到的攻略结果，初始化点赞状态数组的长度，并初始化为false，后续会通过initLikeStatus方法从数据库更新真实状态
    this.isLiked = new Array(res.length).fill(false);
    return res;
  }

  // 开始显示大图和遮罩层的动画
  startShowAnimation = (strategyModel: StrategyModel, index: number) => {
    // 再次确认传入的strategyModel不为null
    if (strategyModel) {
      // 记录当前点击图片所在的攻略以及图片在攻略中的索引
      this.currentSelectedStrategy = strategyModel;
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
  }

  startHideAnimation = () => {
    let intervalId = setInterval(() => {
      if (this.animationProgress > 0) {
        this.animationProgress = Math.max(0, this.animationProgress - 0.05); // 每次减小动画进度，步长调小为0.05，让变化更细腻
        // 根据动画进度更平滑地更新遮罩层透明度和层级，例如使用线性插值等方式
        this.maskOpacity = this.animationProgress;
        this.maskIndex = Math.floor(this.animationProgress * 100) - 1;
      } else {
        clearInterval(intervalId);
        // 触发页面重新渲染，确保在重置状态后UI能正确更新
        this.currentSelectedIndex = -1;
        this.maskOpacity = 0;
        this.maskIndex = -1;
        this.animationProgress = 0;
        this.strategy = [...this.strategy];
      }
    }, 16); // 提高定时器频率，每16毫秒更新一次动画，使动画更细腻，可按需调整

    // 这里可以额外添加一些逻辑，比如在动画即将结束时，做一些微调来确保完全隐藏等
    if (this.animationProgress === 0) {
      this.maskOpacity = 0;
      this.maskIndex = -1;
    }
  }

  // 根据动画进度计算遮罩层透明度
  calculateOpacity = (): number => {
    return this.animationProgress;
  }

  // 根据动画进度计算遮罩层层级
  calculateZIndex = (): number => {
    return Math.floor(this.animationProgress * 100) - 1;
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
          Text(`我的${this.cityName}攻略`).fontSize(18).fontWeight(600);

          Image($r("app.media.add"))
            .width(30)
            .onClick(() => {
              router.replaceUrl({
                url: 'pages/addStrategyPage',
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


        if (this.strategy.length > 0) {
          Scroll(this.myScroll) {
            List() {
              ForEach(this.strategy, (item: StrategyModel, index: number) => {
                ListItem() {
                  Column() {
                    Text('攻略' + (index + 1).toString())
                      .fontSize(30)
                      .fontWeight(600);

                    Text(item.strategy_name)
                      .fontSize(30)
                      .fontWeight(600)
                      .margin({ left: 10, right: 10 });
                    Text('来自用户：' + this.username)
                      .fontWeight(600)
                      .fontSize(20)
                      .margin({ left: 10, right: 10 });
                    Text('攻略适用时间: ' + item.date)
                      .fontSize(15)
                      .fontWeight(400)
                      .margin({ bottom: 10, left: 10, right: 10 });
                    Text('攻略内容：' + item.content)
                      .fontSize(20)
                      .margin({ bottom: 20, left: 10, right: 10 })
                      .fontWeight(600)
                      .lineHeight(30);

                    // 处理图片数据，确保image_path是数组格式，且正确渲染轮播组件
                    if (item.image_path && Array.isArray(item.image_path) && item.image_path.length > 0) {
                      Column() {
                        Swiper() {
                          ForEach(item.image_path, (imgPath: string, index1: number) => {
                            Image(imgPath)
                              .width('100%')
                              .height('40%')
                              .onClick(() => {
                                if (item && item.image_path && item.image_path.length > index1) {
                                  this.startShowAnimation(item, index1);
                                }
                              })
                          })
                        }
                        .loop(true)
                        .autoPlay(true)
                        .interval(3000)
                      }.margin({ top: 10, bottom: 10 })
                    }

                    // Row({ space: 40 }) {
                    //   Image($r('app.media.xihuan'))
                    //.width(35)
                    //.onClick(() => {
                    //       // 点击喜欢图标时，切换点赞状态（同时改变图标颜色和更新数据库中的点赞状态）
                    //       this.toggleLikeStatusForItem(item.strategy_id, index);
                    //     })
                    //.fillColor(this.getLikeColor(index))
                    //   // 这里通过调用方法来获取颜色，确保每次渲染都能正确获取最新状态对应的颜色
                    //
                    //   Image($r('app.media.shoucang'))
                    //.width(42)
                    //.fillColor((this.isshoucangClicked? '#ffcc00' : Color.Gray))
                    //.onClick(() => {
                    //       this.isshoucangClicked =!this.isshoucangClicked;
                    //     })
                    // }.margin({ bottom: 10 });

                    Text(index === this.strategy.length - 1? '这是最后一条攻略' : '请查看下条攻略')
                      .fontSize(20)
                      .margin({ bottom: 30 })
                      .border({
                        width: { bottom: 3 },
                        style: BorderStyle.Dashed
                      }).width('100%');
                  }
                }
              }, (item: StrategyModel) => item.strategy_id);


            }

          }
          .margin({ top: 55 })
          .scrollBar(BarState.Off);

        } else {
          emptyView();
        }
        // 根据当前点击图片的索引来显示对应大图以及遮罩效果，添加动画过渡，确保使用正确图片url格式
        if (this.currentSelectedStrategy && this.currentSelectedIndex!== -1) {
          Column() {
            Image(this.currentSelectedStrategy.image_path[this.currentSelectedIndex])
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
      if (this.strategy.length > 0) {
        Image($r('app.media.rocket'))
          .width(50)
          .backgroundColor(Color.White)
          .borderRadius(25)
          .padding(5)
          .offset({ x: 145, y: -140 })
          .onClick(() => {
            this.myScroll.scrollEdge(Edge.Top);
          })
      }

    }

  }

  // 切换指定攻略的点赞状态的具体方法，更新本地状态和数据库中的点赞状态，确保各攻略状态独立及图标颜色同步变化
  toggleLikeStatusForItem = async (strategyId: string, index: number) => {
    const userId = this.user_id;
    const currentLikeStatus = this.isLiked[index];
    const newLikeStatus =!currentLikeStatus;
    await testUtil.updateLikeStatus('STRATEGY_LIKES', strategyId, userId, newLikeStatus);
    this.isLiked[index] = newLikeStatus;
    console.log(`攻略 ${strategyId} 点赞状态切换成功，当前点赞状态为: ${this.isLiked[index]}`);
    // 点击后手动触发页面刷新，确保图标颜色能及时更新
    this.refresh();
  }

  refresh() {
    // 使用ArkTS的@State修饰的变量，通过重新赋值来触发组件的重新渲染
    this.strategy = [...this.strategy];
  }

  getLikeColor(index: number): Color {
    return this.isLiked[index]? Color.Red : Color.Gray;
  }
}