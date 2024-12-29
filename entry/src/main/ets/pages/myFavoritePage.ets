import router from '@ohos.router';
import StrategyModel from '../model/StrategyModel';
import { testUtil } from '../utils/TestUtil';
import emptyView6 from '../view/record/emptyView6';

// 用于接收传递过来的参数对象的类型定义
interface ParamsObj {
  user_id: string;
}

@Entry
@Component
struct MyFavoritePage {
  @State favoritedStrategies: StrategyModel[] = []; // 用于存储已收藏攻略信息的状态变量
  @State user_id: string = '';

  aboutToAppear() {
    const params = router.getParams() as ParamsObj;
    this.user_id = params.user_id;
    console.log('主页(个人)传过来的用户ID数据', JSON.stringify(router.getParams()));

    // 调用查询已收藏攻略信息的方法，传入获取到的用户ID进行查询
    this.queryFavoritedStrategies();
  }

  // 封装的查询已收藏攻略信息的方法，确保能准确查询当前用户收藏过的所有攻略信息
  async queryFavoritedStrategies() {
    const column: string[] = ['STRATEGY_ID', 'STRATEGY_NAME', 'AUTHOR_NAME', 'DATE', 'CONTENT', 'IMAGE_PATH'];
    const tableName4 = "MYSTRATEGY";
    const tableName7 = "STRATEGY_FAVORITES";

    try {
      const result = await testUtil.queryFavoritedStrategyData(column, tableName4, tableName7, this.user_id);
      console.info('查询到的已收藏攻略信息如下:');
      result.forEach((strategy) => {
        console.info(`攻略ID: ${strategy.strategy_id}, 攻略名称: ${strategy.strategy_name}, 作者: ${strategy.author_name}, 日期: ${strategy.date}`);
      });
      // 获取每条已收藏攻略的收藏数量并添加到策略对象中
      const strategiesWithFavoriteCount = await this.addFavoriteCountToStrategies(result);
      this.favoritedStrategies = strategiesWithFavoriteCount;
    } catch (error) {
      console.error('查询已收藏攻略信息出现错误:', error);
    }
  }

  // 新增方法：获取每条已收藏攻略的收藏数量并添加到策略对象中
  async addFavoriteCountToStrategies(strategies: StrategyModel[]): Promise<StrategyModel[]> {
    const strategiesWithCount: StrategyModel[] = [];
    for (let i = 0; i < strategies.length; i++) {
      const count = await testUtil.countFavoritesForStrategy('STRATEGY_FAVORITES', strategies[i].strategy_id);
      const strategyWithCount = {
        ...strategies[i],
        favoriteCount: count
      };
      strategiesWithCount.push(strategyWithCount);
    }
    return strategiesWithCount;
  }

  build() {
    Column() {
      Row() {
        Image($r('app.media.left1'))
          .width(30)
          .fillColor(Color.Grey)
          .onClick(() => {
            router.back();
            router.RouterMode.Single;
          })
        Text(`我的收藏`).fontSize(18).fontWeight(600);

        Image($r("app.media.helpone"))
          .width(30)
          .onClick(() => {
            AlertDialog.show({
              message: '此页可以帮助您记录您到访过我国的哪些城市，并在此留下了哪些信息'
            });
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

      // 根据获取到的已收藏攻略信息进行循环渲染
      if (this.favoritedStrategies.length === 0) {
        emptyView6();
      } else {
        List({ space: 10, initialIndex: 0 }) {
          ForEach(this.favoritedStrategies, (strategy) => {
            ListItem() {
              Column() {
                Row({space:7}){
                  Image($r('app.media.collect')).width(50);
                  // 显示收藏数量
                  Text(`${strategy.favoriteCount}`).fontSize(18).fontWeight(400);
                }
                Text(`攻略名称: ${strategy.strategy_name}`).fontSize(25).fontWeight(500);
                Text(`作者: ${strategy.author_name}`).fontSize(25).fontWeight(500);
                Text(`日期: ${strategy.date}`).fontSize(20).fontWeight(500);
              }
              .width("100%")
              .margin({ top: 15 })
              .onClick(() => {
                // 这里添加点击事件，传递攻略信息到下一个页面
                router.pushUrl({
                  url: 'pages/myFavoriteContentPage',
                  params: {
                    strategyId: strategy.strategy_id,
                    strategyName: strategy.strategy_name,
                    authorName: strategy.author_name,
                    date: strategy.date,
                    content: strategy.content,
                    imagePath: strategy.image_path
                  }
                });
                router.RouterMode.Single;
              })
            }
          }, item => item.strategy_id); // 这里根据攻略ID作为ForEach的key
        }
        .width('100%')
        .height('100%')
        .divider({
          strokeWidth: 1,
          startMargin: 15,
          endMargin: 15,
          color: '#ff7b8080'
        });
      }
    }
  }
}