import router from '@ohos.router';
import { testUtil } from '../utils/TestUtil';
import emitter from '@ohos.events.emitter';

interface ParamsObj {
  strategyId: string;
  strategyName: string;
  authorName: string;
  date: string;
  content: string;
  imagePath: string[];
  isLiked: boolean;
  likeCount: number;
  cityName: string;
  user_id: string;
  isFavorited: boolean; // 新增：收藏状态
  favoriteCount: number; // 新增：收藏数量
}

@Entry
@Component
struct WaterFlowInfo {
  @State strategyId: string = '';
  @State strategyName: string = '';
  @State authorName: string = '';
  @State date: string = '';
  @State content: string = '';
  @State imagePath: string[] = [];
  @State isLiked: boolean = false;
  @State likeCount: number = 0;
  @State isFavorited: boolean = false; // 新增：收藏状态
  @State favoriteCount: number = 0;
  @State likeCountMap: { [key: string]: number } = {}; // 点赞数映射表
  @State favoriteCountMap: { [key: string]: number } = {}; // 新增：收藏数映射表

  @State cityName: string = '';
  @State user_id: string = '';


  aboutToAppear() {
    const params = router.getParams() as ParamsObj;
    this.strategyId = params.strategyId;
    this.strategyName = params.strategyName;
    this.authorName = params.authorName;
    this.date = params.date;
    this.content = params.content;
    this.imagePath = params.imagePath;


    this.isLiked = params.isLiked;
    this.likeCount = params.likeCount;
    this.likeCountMap[this.strategyId] = this.likeCount; // 初始化点赞数映射表
    this.isFavorited = params.isFavorited; // 初始化收藏状态
    this.favoriteCount = params.favoriteCount;
    this.favoriteCountMap[this.strategyId] = this.favoriteCount // 初始化收藏数映射表

    this.cityName = params.cityName;
    this.user_id = params.user_id;
  }

  // 切换指定攻略的点赞状态的具体方法，更新本地状态和数据库中的点赞状态，确保各攻略状态独立及图标颜色同步变化
  toggleLikeStatusForItem = async () => {
    const userId = this.user_id;
    const currentLikeStatus = this.isLiked;
    const newLikeStatus =!currentLikeStatus;

    try {
      // 根据当前点赞状态决定是调用插入还是更新方法来处理数据库操作
      if (currentLikeStatus) {
        await testUtil.updateLikeStatus('STRATEGY_LIKES', this.strategyId, userId, false);
        // 更新点赞数量，点赞数减1
        this.likeCountMap[this.strategyId] -= 1;
      } else {
        await testUtil.insertLikeStatus('STRATEGY_LIKES', this.strategyId, userId);
        // 更新点赞数量，点赞数加1
        this.likeCountMap[this.strategyId] += 1;
      }

      // 更新本地点赞状态
      this.isLiked = newLikeStatus;
      console.log(`攻略 ${this.strategyId} 点赞状态切换成功，当前点赞状态为: ${this.isLiked}，点赞数量更新为: ${this.likeCountMap[this.strategyId]}`);
      // 点击后手动触发页面刷新，确保图标颜色能及时更新，同时确保点赞数量也正确显示
      this.refresh();
    } catch (error) {
      console.error(`攻略 ${this.strategyId} 点赞操作出现错误: ${error}`);
      // 可以在这里根据实际情况考虑是否进行一些回滚操作或者提示用户等
    }
  }

  // 新增：切换指定攻略的收藏状态的具体方法，更新本地状态和数据库中的收藏状态
  toggleFavoriteStatusForItem = async () => {
    const userId = this.user_id;
    const currentFavoriteStatus = this.isFavorited;
    const newFavoriteStatus =!currentFavoriteStatus;

    try {
      // 根据当前收藏状态决定是调用插入还是更新方法来处理数据库操作
      if (currentFavoriteStatus) {
        await testUtil.updateFavoriteStatus('STRATEGY_FAVORITES', this.strategyId, userId, false);
        // 更新收藏数量，收藏数减1
        this.favoriteCountMap[this.strategyId] -= 1;
      } else {
        await testUtil.insertFavoriteStatus('STRATEGY_FAVORITES', this.strategyId, userId);
        // 更新收藏数量，收藏数加1
        this.favoriteCountMap[this.strategyId] += 1;
      }

      // 更新本地收藏状态
      this.isFavorited = newFavoriteStatus;
      console.log(`攻略 ${this.strategyId} 收藏状态切换成功，当前收藏状态为: ${this.isFavorited}，收藏数量更新为: ${this.favoriteCountMap[this.strategyId]}`);
      // 点击后手动触发页面刷新，确保图标颜色能及时更新，同时确保收藏数量也正确显示
      this.refresh();
    } catch (error) {
      console.error(`攻略 ${this.strategyId} 收藏操作出现错误: ${error}`);
      // 可以在这里根据实际情况考虑是否进行一些回滚操作或者提示用户等
    }
  }

  refresh() {
    // 使用ArkTS的@State修饰的变量，通过重新赋值来触发组件的重新渲染
    this.strategyName = this.strategyName;
  }

  getLikeColor(): Color {
    return this.isLiked? Color.Red : Color.Gray;
  }

  getFavoriteColor(): string {
    return this.isFavorited? '#ffeeb406' : '#ff777474';
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
              router.back()
              const event = { eventId: 1 }
              console.log('瀑布流攻略查看页发布订阅数据：'+JSON.stringify(event))
              emitter.emit(event);

              router.RouterMode.Single;
            })
          Text(`他人${this.cityName}攻略`).fontSize(18).fontWeight(600)

          Image('images/helpone.svg')
            .width(30);
        }
        .zIndex(99)
        .border({
          width: { bottom: 2 },
          color: Color.Gray
        })
        .borderRadius(15)
        .justifyContent(FlexAlign.SpaceBetween)
        .width('100%')
        .height(50)
        .backgroundColor(Color.White)
        .padding({ left: 10, right: 10 })

        Column() {
          Text('攻略详情')
            .fontSize(24)
            .fontWeight(600)
            .margin({ top: 20, bottom: 10 });

          Text(this.strategyName)
            .fontSize(30)
            .fontWeight(600)
            .margin({ left: 10, right: 10 });
          Text('来自用户：' + this.authorName)
            .fontWeight(600)
            .fontSize(20)
            .margin({ left: 10, right: 10 });
          Text('攻略适用时间: ' + this.date)
            .fontSize(15)
            .fontWeight(400)
            .margin({ bottom: 10, left: 10, right: 10 });
          Text('攻略内容：' + this.content)
            .fontSize(20)
            .margin({ bottom: 20, left: 10, right: 10 })
            .fontWeight(600)
            .lineHeight(30);

          // 使用轮播组件渲染图片（多张图片时可轮播展示）
          if (this.imagePath && Array.isArray(this.imagePath) && this.imagePath.length > 0) {
            Column() {
              Swiper() {
                ForEach(this.imagePath, (imgPath: string, imgIndex: number) => {
                  Image(imgPath)
                    .width('100%')
                    .height('50%')
                })
              }
              .loop(true)
              .autoPlay(true)
              .interval(3000)
            }.margin({ top: 10, bottom: 10 })
          }

          Row({ space: 40 }) {
            Row({ space: 8 }) {
              Image($r('app.media.xihuan'))
                .width(35)
                .onClick(() => {
                  this.toggleLikeStatusForItem();
                })
                .fillColor(this.getLikeColor());
              Text(`${this.likeCountMap[this.strategyId]}`)
                .fontSize(18);
            }
            Row({ space: 8 }) {
              Image($r('app.media.shoucang'))
                .width(42)
                .onClick(() => {
                  this.toggleFavoriteStatusForItem();
                })
                .fillColor(this.getFavoriteColor());
              Text(`${this.favoriteCountMap[this.strategyId]}`)
                .fontSize(18);
            }
          }.margin({ bottom: 10 });
        }
        .margin({ top: 40 })
      }
    }
  }
}