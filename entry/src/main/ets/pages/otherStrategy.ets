import router from '@ohos.router';
import StrategyModel from '../model/StrategyModel';
import { testUtil } from '../utils/TestUtil';
import emptyView3 from '../view/record/emptyView3';
import emitter from '@ohos.events.emitter';




// 用于接收传递过来的参数对象的类型定义
interface ParamsObj {
  cityName: string;
  user_id: string;
  username: string;
}

interface EventData {}

function handleReceivedEvent(eventData: EventData) {
  // 这里写具体的事件处理逻辑，比如重新查询数据并触发重新渲染
  this.showWaterfall().then(() => {
    Promise.all([
    this.initLikeStatus(),
    this.initLikeCount(),
    this.initFavoriteStatus(),
    this.initFavoriteCount()
    ]).then(() => {
      this.refresh();
    });
  });
}


@CustomDialog
@Component
struct SearchDialog {

  @Consume likeCountMap: { [key: string]: number }
  @Consume isLiked: boolean[]
  @Consume favoriteCountMap: { [key: string]: number } // 新增：收藏数量映射
  @Consume isFavorited: boolean[] // 新增：收藏状态数组
  @Consume  SearchResults: StrategyModel[]
  @State cityName: string = ''
  @State username: string = ''
  @State user_id: string = ''
  @State inputContent: string = ''

  aboutToAppear(): void {
    const params = router.getParams() as ParamsObj;
    this.cityName = params.cityName;
    this.user_id = params.user_id;
    this.username = params.username;
    console.log('(弹窗)总攻略页传递过来的数据', JSON.stringify(router.getParams()));
  }

  async doSearch() {
    const columns = ["STRATEGY_ID", "STRATEGY_NAME", "AUTHOR_NAME", "DATE", "CONTENT", "IMAGE_PATH"];
    const result = await testUtil.queryStrategyDataByKeyword(columns, "MYSTRATEGY", this.inputContent);
    this.SearchResults = result; // 更新查询结果数据

    // 遍历查询结果，更新点赞状态和点赞数量
    for (const item of result) {
      const index = this.SearchResults.indexOf(item);
      if (index!== -1) {
        // 更新点赞状态
        this.isLiked[index] = await testUtil.isUserLikedStrategy('STRATEGY_LIKES', item.strategy_id, this.user_id);
        // 更新点赞数量
        this.likeCountMap[item.strategy_id] = await testUtil.countLikesForStrategy('STRATEGY_LIKES', item.strategy_id);
        // 更新收藏状态
        this.isFavorited[index] = await testUtil.isUserFavoritedStrategy('STRATEGY_FAVORITES', item.strategy_id, this.user_id);
        // 更新收藏数量
        this.favoriteCountMap[item.strategy_id] = await testUtil.countFavoritesForStrategy('STRATEGY_FAVORITES', item.strategy_id);
      }
    }

    this.controller.close(); // 关闭弹窗
  }


  controller: CustomDialogController = new CustomDialogController({
    builder: SearchDialog()
  });

  async showEmpty(){
    if(this.SearchResults.length == 0){
      AlertDialog.show({
        message:'未查询到任何数据'
      })
    }
  }

  build() {
    Column() {
      TextInput({ placeholder: '请输入您想查询攻略的关键字' })
        .onChange((value: string) => {
          this.inputContent = value;
        })

      Row({ space: 10 }) {
        Button('搜索').width(100)
          .onClick(() => {
            this.doSearch()
              .then(() => {
                this.showEmpty();
              });
          });

        Button('取消').width(100)
          .onClick(() => {
            this.controller.close();
          });
      }.margin({ top: 10, bottom: 10 })
    }
  }
}



@Entry
@Component
struct OtherStrategy {

  myScroll: Scroller = new Scroller();

  controller: CustomDialogController = new CustomDialogController({
    builder: SearchDialog()
  });

  @Provide SearchResults: StrategyModel[] = []
  @State strategies: StrategyModel[] = []; // 用于存储查询到的攻略信息
  @State cityName: string = "";
  @State user_id: string = "";
  @State username: string = "";
  // 用于记录当前每个攻略是否被当前用户点赞，初始化为false，后续根据查询结果更新
  @Provide isLiked: boolean[] = [];
  // 新增一个映射关系，用于存储每条攻略已点赞的用户数量，以攻略ID为键，点赞数为值
  @Provide likeCountMap: { [key: string]: number } = {};
  @State isLikedCountSorted: boolean = false; // 新增状态变量，用于记录点赞数排序状态

  // 用于记录当前每个攻略是否被当前用户收藏，初始化为false，后续根据查询结果更新
  @Provide isFavorited: boolean[] = [];
  // 新增一个映射关系，用于存储每条攻略的收藏数量，以攻略ID为键，收藏数为值
  @Provide favoriteCountMap: { [key: string]: number } = {};
  @State isFavoritedCountSorted: boolean = false; // 新增状态变量，用于记录收藏数排序状态
  // 新增状态变量，用于记录时间排序状态
  @State isDateSorted: boolean = false;

  @State waterModel:boolean = false
  @State waterfallData :StrategyModel[]= [];
  @State minSize: number = 150
  @State maxSize: number = 200
  @State itemWidthArray: number[] = []
  @State itemHeightArray: number[] = []
  @State FirstColor: string = '#ff000000'
  @State ChangeColor: string = '#ff7e7a7a'

  // 记录当前点击图片所在的攻略以及图片在攻略中的索引
  @State currentSelectedStrategy: StrategyModel | null = null;
  @State currentSelectedIndex: number = -1;
  // 记录遮罩层透明度，初始为0表示隐藏
  @State maskOpacity: number = 0;
  // 记录遮罩层的层级，初始为 -1表示在底层（不可见）
  @State maskIndex: number = -1;
  // 用于控制动画进度，取值范围0 - 1，0表示动画开始，1表示动画结束
  @State animationProgress: number = 0;

  @State avatarList: string[] = [];

  @State avatars:string[] = []

  aboutToAppear(): void {
    const params = router.getParams() as ParamsObj;
    this.cityName = params.cityName;
    this.username = params.username;
    this.user_id = params.user_id;
    console.log(`(他人${this.cityName}攻略页) 总攻略页传递过来的城市名数据`, JSON.stringify(router.getParams()));

    testUtil.queryAllStrategyIds(this.cityName).then((strategyIds) => {
      const avatarPromises = strategyIds.map(async (strategyId) => {
        return await testUtil.queryUserProfileByStrategyId("MYSTRATEGY", "USER", strategyId);
      });

      Promise.allSettled(avatarPromises).then((results) => {
        this.avatarList = results.map((result) => {
          if (result.status === 'fulfilled') {
            return (result as PromiseFulfilledResult<string>).value;
          }
          return null;
        });
      });

      this.queryStrategies().then(() => {
        Promise.all([
        this.initLikeStatus(),
        this.initLikeCount(),
        this.initFavoriteStatus(),
        this.initFavoriteCount()
        ]).then(() => {
          this.refresh();
        });
      });
    });

    let innerEvent = { eventId: 1 };
    emitter.on(innerEvent, handleReceivedEvent.bind(this));
    console.log('接收订阅数据：' + JSON.stringify(innerEvent))
  }

  // 查询指定城市下所有攻略信息的方法
  queryStrategies = async () => {
    const res = await testUtil.queryStrategyDataByCityName(
      ["STRATEGY_ID", "STRATEGY_NAME", "AUTHOR_NAME", "DATE", "CONTENT", "IMAGE_PATH"],
      "MYSTRATEGY",
      this.cityName
    );
    console.log(`攻略数据库结果为：${JSON.stringify(res)}`);

    this.strategies = res;
    // 根据查询到的攻略结果，初始化点赞状态数组的长度，并初始化为false，后续会通过initLikeStatus方法从数据库更新真实状态
    this.isLiked = new Array(res.length).fill(false);
    // 初始化点赞数量映射表，初始值都设为0
    this.likeCountMap = this.strategies.reduce((acc, strategy) => {
      acc[strategy.strategy_id] = 0;
      return acc;
    }, {} as { [key: string]: number });

    // 重新获取头像信息
    const strategyIds = res.map(strategy => strategy.strategy_id);
    const avatarPromises = strategyIds.map(async (strategyId) => {
      return await testUtil.queryUserProfileByStrategyId("MYSTRATEGY", "USER", strategyId);
    });
    const avatarResults = await Promise.allSettled(avatarPromises);
    this.avatarList = avatarResults.map((result) => {
      if (result.status === 'fulfilled') {
        return (result as PromiseFulfilledResult<string>).value;
      }
      return null;
    });

    return res;
  }

  showWaterfall = async () => {
    const res = await testUtil.queryStrategyDataByCityName(
      ["STRATEGY_ID", "STRATEGY_NAME", "AUTHOR_NAME", "DATE", "CONTENT", "IMAGE_PATH"],
      "MYSTRATEGY",
      this.cityName
    );
    console.log(`攻略数据库结果为：${JSON.stringify(res)}`);
    this.waterModel = true;
    this.strategies = res;

    // 初始化点赞状态和点赞数量，根据已有状态对应赋值
    this.isLiked = [];
    this.likeCountMap = {};
    for (const item of res) {
      const index = this.strategies.indexOf(item);
      this.isLiked[index] = await testUtil.isUserLikedStrategy('STRATEGY_LIKES', item.strategy_id, this.user_id);
      this.likeCountMap[item.strategy_id] = await testUtil.countLikesForStrategy('STRATEGY_LIKES', item.strategy_id);
    }

    // 重新获取头像信息
    const strategyIds = res.map(strategy => strategy.strategy_id);
    const avatarPromises = strategyIds.map(async (strategyId) => {
      return await testUtil.queryUserProfileByStrategyId("MYSTRATEGY", "USER", strategyId);
    });
    const avatarResults = await Promise.allSettled(avatarPromises);
    this.avatarList = avatarResults.map((result) => {
      if (result.status === 'fulfilled') {
        return (result as PromiseFulfilledResult<string>).value;
      }
      return null;
    });

    this.myScroll.scrollToIndex(0)
    return res;
  }



  // 获取攻略对应的用户头像
  async getAvatarByStrategyId(strategyId: string): Promise<string | null> {
    return await testUtil.queryUserProfileByStrategyId("MYSTRATEGY", "USER", strategyId);
  }
  // 查询当前用户对所有展示攻略的点赞状态的方法，确保正确获取和设置每个攻略的点赞状态，添加日志打印每个攻略的点赞状态
  initLikeStatus = async () => {
    const userId = this.user_id;
    for (let i = 0; i < this.strategies.length; i++) {
      const isLiked = await testUtil.isUserLikedStrategy('STRATEGY_LIKES', this.strategies[i].strategy_id, userId);
      this.isLiked[i] = isLiked;
      console.log(`攻略 ${this.strategies[i].strategy_id} 的点赞状态为: ${isLiked? '已点赞' : '未点赞'}`);
    }
    return this.isLiked;
  }
  // 新增的初始化每条攻略点赞数量的方法，遍历所有攻略，查询并设置每条攻略的点赞数量
  async initLikeCount() {
    for (let i = 0; i < this.strategies.length; i++) {
      const count = await testUtil.countLikesForStrategy('STRATEGY_LIKES', this.strategies[i].strategy_id);
      this.likeCountMap[this.strategies[i].strategy_id] = count;
    }
    return this.likeCountMap;
  }
  // 新增方法，用于初始化查询结果攻略的点赞状态
  initLikeStatusForSearchResults = async (searchResults: StrategyModel[]) => {
    const userId = this.user_id;
    for (const item of searchResults) {
      const isLiked = await testUtil.isUserLikedStrategy('STRATEGY_LIKES', item.strategy_id, userId);
      const index = this.SearchResults.indexOf(item);
      if (index!== -1) {
        this.isLiked[index] = isLiked;
      }
    }
    return this.isLiked;
  }
  // 新增方法，用于初始化查询结果攻略的点赞数量
  initLikeCountForSearchResults = async (searchResults: StrategyModel[]) => {
    for (const item of searchResults) {
      const count = await testUtil.countLikesForStrategy('STRATEGY_LIKES', item.strategy_id);
      this.likeCountMap[item.strategy_id] = count;
    }
    return this.likeCountMap;
  }
  // 获取指定攻略点赞数的方法
  async getLikeCount(strategyId: string) {
    return await testUtil.countLikesForStrategy('STRATEGY_LIKES', strategyId);
  }
  getLikeColor(index: number): Color {
    return this.isLiked[index]? Color.Red : Color.Gray;
  }



  // 查询当前用户对所有展示攻略的收藏状态的方法，确保正确获取和设置每个攻略的收藏状态，添加日志打印每个攻略的收藏状态
  initFavoriteStatus = async () => {
    const userId = this.user_id;
    for (let i = 0; i < this.strategies.length; i++) {
      const isFavorited = await testUtil.isUserFavoritedStrategy('STRATEGY_FAVORITES', this.strategies[i].strategy_id, userId);
      this.isFavorited[i] = isFavorited;
      console.log(`攻略 ${this.strategies[i].strategy_id} 的收藏状态为: ${isFavorited? '已收藏' : '未收藏'}`);
    }
    return this.isFavorited;
  }
  // 新增的初始化每条攻略收藏数量的方法，遍历所有攻略，查询并设置每条攻略的收藏数量
  async initFavoriteCount() {
    for (let i = 0; i < this.strategies.length; i++) {
      const count = await testUtil.countFavoritesForStrategy('STRATEGY_FAVORITES', this.strategies[i].strategy_id);
      this.favoriteCountMap[this.strategies[i].strategy_id] = count;
    }
    return this.favoriteCountMap;
  }
  // 新增方法，用于初始化查询结果攻略的收藏状态
  initFavoriteStatusForSearchResults = async (searchResults: StrategyModel[]) => {
    const userId = this.user_id;
    for (const item of searchResults) {
      const isFavorited = await testUtil.isUserFavoritedStrategy('STRATEGY_FAVORITES', item.strategy_id, userId);
      const index = this.SearchResults.indexOf(item);
      if (index!== -1) {
        this.isFavorited[index] = isFavorited;
      }
    }
    return this.isFavorited;
  }
  // 新增方法，用于初始化查询结果攻略的收藏数量
  initFavoriteCountForSearchResults = async (searchResults: StrategyModel[]) => {
    for (const item of searchResults) {
      const count = await testUtil.countFavoritesForStrategy('STRATEGY_FAVORITES', item.strategy_id);
      this.favoriteCountMap[item.strategy_id] = count;
    }
    return this.favoriteCountMap;
  }
  // 获取指定攻略收藏数的方法
  async getFavoriteCount(strategyId: string) {
    return await testUtil.countFavoritesForStrategy('STRATEGY_FAVORITES', strategyId);
  }
  // 根据索引获取收藏图标颜色的方法
  getFavoriteColor(index: number): string {
    return this.isFavorited[index]? '#ffeeb406' : '#ff777474';
  }



  // 插入排序算法实现，用于按照点赞数降序排序，同时同步调整点赞状态数组和收藏状态数组，保持相同点赞数的相对顺序（稳定排序）
  async insertionSort() {
    const newStrategies = [...this.strategies];
    const newIsLiked = [...this.isLiked];
    const newIsFavorited = [...this.isFavorited];
    const newItemWidthArray = [...this.itemWidthArray];
    const newItemHeightArray = [...this.itemHeightArray];
    const newLikeCountMap = {...this.likeCountMap };
    const newFavoriteCountMap = {...this.favoriteCountMap };
    const newAvatarList = [...this.avatarList];

    for (let i = 1; i < newStrategies.length; i++) {
      const current = newStrategies[i];
      const currentIsLiked = newIsLiked[i];
      const currentIsFavorited = newIsFavorited[i];
      const currentItemWidth = newItemWidthArray[i];
      const currentItemHeight = newItemHeightArray[i];
      const currentLikeCount = newLikeCountMap[current.strategy_id];
      const currentFavoriteCount = newFavoriteCountMap[current.strategy_id];
      const currentAvatar = newAvatarList[i];
      let j = i - 1;
      while (j >= 0 && newLikeCountMap[newStrategies[j].strategy_id] < currentLikeCount) {
        newStrategies[j + 1] = newStrategies[j];
        newIsLiked[j + 1] = newIsLiked[j];
        newIsFavorited[j + 1] = newIsFavorited[j];
        newItemWidthArray[j + 1] = newItemWidthArray[j];
        newItemHeightArray[j + 1] = newItemHeightArray[j];
        newLikeCountMap[newStrategies[j + 1].strategy_id] = newLikeCountMap[newStrategies[j].strategy_id];
        newFavoriteCountMap[newStrategies[j + 1].strategy_id] = newFavoriteCountMap[newStrategies[j].strategy_id];
        newAvatarList[j + 1] = newAvatarList[j];
        j--;
      }
      newStrategies[j + 1] = current;
      newIsLiked[j + 1] = currentIsLiked;
      newIsFavorited[j + 1] = currentIsFavorited;
      newItemWidthArray[j + 1] = currentItemWidth;
      newItemHeightArray[j + 1] = currentItemHeight;
      newLikeCountMap[current.strategy_id] = currentLikeCount;
      newFavoriteCountMap[current.strategy_id] = currentFavoriteCount;
      newAvatarList[j + 1] = currentAvatar;
    }

    this.strategies = newStrategies;
    this.isLiked = newIsLiked;
    this.isFavorited = newIsFavorited;
    this.itemWidthArray = newItemWidthArray;
    this.itemHeightArray = newItemHeightArray;
    this.likeCountMap = newLikeCountMap;
    this.favoriteCountMap = newFavoriteCountMap;
    this.avatarList = newAvatarList;

    // 手动触发页面刷新，确保图标颜色能根据最新点赞和收藏状态正确显示
    this.refresh();
  }

  // 插入排序算法实现，用于按照收藏数降序排序，同时同步调整点赞状态数组和收藏状态数组，保持相同收藏数的相对顺序（稳定排序）
  async insertionSortByFavoriteCount() {
    const newStrategies = [...this.strategies];
    const newIsLiked = [...this.isLiked];
    const newIsFavorited = [...this.isFavorited];
    const newItemWidthArray = [...this.itemWidthArray];
    const newItemHeightArray = [...this.itemHeightArray];
    const newLikeCountMap = {...this.likeCountMap };
    const newFavoriteCountMap = {...this.favoriteCountMap };
    const newAvatarList = [...this.avatarList];

    for (let i = 1; i < newStrategies.length; i++) {
      const current = newStrategies[i];
      const currentIsLiked = newIsLiked[i];
      const currentIsFavorited = newIsFavorited[i];
      const currentItemWidth = newItemWidthArray[i];
      const currentItemHeight = newItemHeightArray[i];
      const currentLikeCount = newLikeCountMap[current.strategy_id];
      const currentFavoriteCount = newFavoriteCountMap[current.strategy_id];
      const currentAvatar = newAvatarList[i];
      let j = i - 1;
      while (j >= 0 && newFavoriteCountMap[newStrategies[j].strategy_id] < currentFavoriteCount) {
        newStrategies[j + 1] = newStrategies[j];
        newIsLiked[j + 1] = newIsLiked[j];
        newIsFavorited[j + 1] = newIsFavorited[j];
        newItemWidthArray[j + 1] = newItemWidthArray[j];
        newItemHeightArray[j + 1] = newItemHeightArray[j];
        newLikeCountMap[newStrategies[j + 1].strategy_id] = newLikeCountMap[newStrategies[j].strategy_id];
        newFavoriteCountMap[newStrategies[j + 1].strategy_id] = newFavoriteCountMap[newStrategies[j].strategy_id];
        newAvatarList[j + 1] = newAvatarList[j];
        j--;
      }
      newStrategies[j + 1] = current;
      newIsLiked[j + 1] = currentIsLiked;
      newIsFavorited[j + 1] = currentIsFavorited;
      newItemWidthArray[j + 1] = currentItemWidth;
      newItemHeightArray[j + 1] = currentItemHeight;
      newLikeCountMap[current.strategy_id] = currentLikeCount;
      newFavoriteCountMap[current.strategy_id] = currentFavoriteCount;
      newAvatarList[j + 1] = currentAvatar;
    }

    this.strategies = newStrategies;
    this.isLiked = newIsLiked;
    this.isFavorited = newIsFavorited;
    this.itemWidthArray = newItemWidthArray;
    this.itemHeightArray = newItemHeightArray;
    this.likeCountMap = newLikeCountMap;
    this.favoriteCountMap = newFavoriteCountMap;
    this.avatarList = newAvatarList;

    // 手动触发页面刷新，确保图标颜色能根据最新点赞和收藏状态正确显示
    this.refresh();
  }



  // 新增方法：按照时间对攻略进行排序
  async insertionSortByDate() {
    const newStrategies = [...this.strategies];
    const newIsLiked = [...this.isLiked];
    const newIsFavorited = [...this.isFavorited];
    const newItemWidthArray = [...this.itemWidthArray];
    const newItemHeightArray = [...this.itemHeightArray];
    const newLikeCountMap = {...this.likeCountMap };
    const newFavoriteCountMap = {...this.favoriteCountMap };
    const newAvatarList = [...this.avatarList];

    const dateNumbers = await testUtil.queryStrategyDatesAsNumber(this.cityName);
    if (dateNumbers.length === newStrategies.length) {
      for (let i = 1; i < newStrategies.length; i++) {
        const current = newStrategies[i];
        const currentIsLiked = newIsLiked[i];
        const currentIsFavorited = newIsFavorited[i];
        const currentItemWidth = newItemWidthArray[i];
        const currentItemHeight = newItemHeightArray[i];
        const currentLikeCount = newLikeCountMap[current.strategy_id];
        const currentFavoriteCount = newFavoriteCountMap[current.strategy_id];
        const currentAvatar = newAvatarList[i];
        const currentDateNumber = dateNumbers[i];
        let j = i - 1;
        while (j >= 0 && dateNumbers[j] < currentDateNumber) {
          newStrategies[j + 1] = newStrategies[j];
          newIsLiked[j + 1] = newIsLiked[j];
          newIsFavorited[j + 1] = newIsFavorited[j];
          newItemWidthArray[j + 1] = newItemWidthArray[j];
          newItemHeightArray[j + 1] = newItemHeightArray[j];
          newLikeCountMap[newStrategies[j + 1].strategy_id] = newLikeCountMap[newStrategies[j].strategy_id];
          newFavoriteCountMap[newStrategies[j + 1].strategy_id] = newFavoriteCountMap[newStrategies[j].strategy_id];
          newAvatarList[j + 1] = newAvatarList[j];
          j--;
        }
        newStrategies[j + 1] = current;
        newIsLiked[j + 1] = currentIsLiked;
        newIsFavorited[j + 1] = currentIsFavorited;
        newItemWidthArray[j + 1] = currentItemWidth;
        newItemHeightArray[j + 1] = currentItemHeight;
        newLikeCountMap[current.strategy_id] = currentLikeCount;
        newFavoriteCountMap[current.strategy_id] = currentFavoriteCount;
        newAvatarList[j + 1] = currentAvatar;
      }
    }

    this.strategies = newStrategies;
    this.isLiked = newIsLiked;
    this.isFavorited = newIsFavorited;
    this.itemWidthArray = newItemWidthArray;
    this.itemHeightArray = newItemHeightArray;
    this.likeCountMap = newLikeCountMap;
    this.favoriteCountMap = newFavoriteCountMap;
    this.avatarList = newAvatarList;

    // 手动触发页面刷新，确保图标颜色能根据最新点赞和收藏状态正确显示
    this.refresh();
  }

  // 切换指定攻略的点赞状态的具体方法，更新本地状态和数据库中的点赞状态，确保各攻略状态独立及图标颜色同步变化
  toggleLikeStatusForItem = async (strategyId: string, index: number) => {
    const userId = this.user_id;
    const currentLikeStatus = this.isLiked[index];
    const newLikeStatus =!currentLikeStatus;

    try {
      // 根据当前点赞状态决定是调用插入还是更新方法来处理数据库操作
      if (currentLikeStatus) {
        await testUtil.updateLikeStatus('STRATEGY_LIKES', strategyId, userId, false);
        // 更新点赞数量，点赞数减1
        this.likeCountMap[strategyId] -= 1;
      } else {
        await testUtil.insertLikeStatus('STRATEGY_LIKES', strategyId, userId);
        // 更新点赞数量，点赞数加1
        this.likeCountMap[strategyId] += 1;
      }

      this.isLiked[index] = newLikeStatus;
      console.log(`攻略 ${strategyId} 点赞状态切换成功，当前点赞状态为: ${this.isLiked[index]}，点赞数量更新为: ${this.likeCountMap[strategyId]}`);
      // 重新检查点赞数排序状态
      if (this.isLikedCountSorted) {
        this.insertionSort();
      }
      // 重新检查收藏数排序状态
      if (this.isFavoritedCountSorted) {
        this.insertionSortByFavoriteCount();
      }
      // 点击后手动触发页面刷新，确保图标颜色能及时更新，同时确保点赞数量也正确显示
      this.refresh();
    } catch (error) {
      console.error(`攻略 ${strategyId} 点赞操作出现错误: ${error}`);
      // 可以在这里根据实际情况考虑是否进行一些回滚操作或者提示用户等
    }
  };

  // 切换指定攻略的收藏状态的具体方法，更新本地状态和数据库中的收藏状态，确保各攻略状态独立及图标颜色同步变化
  toggleFavoriteStatusForItem = async (strategyId: string, index: number) => {
    const userId = this.user_id;
    const currentFavoriteStatus = this.isFavorited[index];
    const newFavoriteStatus =!currentFavoriteStatus;

    try {
      // 根据当前收藏状态决定是调用插入还是更新方法来处理数据库操作
      if (currentFavoriteStatus) {
        await testUtil.updateFavoriteStatus('STRATEGY_FAVORITES', strategyId, userId, false);
        // 更新收藏数量，收藏数减1
        this.favoriteCountMap[strategyId] -= 1;
      } else {
        await testUtil.insertFavoriteStatus('STRATEGY_FAVORITES', strategyId, userId);
        // 更新收藏数量，收藏数加1
        this.favoriteCountMap[strategyId] += 1;
      }

      this.isFavorited[index] = newFavoriteStatus;
      console.log(`攻略 ${strategyId} 收藏状态切换成功，当前收藏状态为: ${this.isFavorited[index]}，收藏数量更新为: ${this.favoriteCountMap[strategyId]}`);
      // 重新检查点赞数排序状态
      if (this.isLikedCountSorted) {
        this.insertionSort();
      }
      // 重新检查收藏数排序状态
      if (this.isFavoritedCountSorted) {
        this.insertionSortByFavoriteCount();
      }
      // 点击后手动触发页面刷新，确保图标颜色能及时更新，同时确保收藏数量也正确显示
      this.refresh();
    } catch (error) {
      console.error(`攻略 ${strategyId} 收藏操作出现错误: ${error}`);
      // 可以在这里根据实际情况考虑是否进行一些回滚操作或者提示用户等
    }
  };

  // 点赞数排序按钮的点击事件逻辑
  onClickLikeSort() {
    if (!this.isLikedCountSorted) {
      this.insertionSort();
      this.isLikedCountSorted = true;
    } else {
      if (this.waterModel === false) {
        this.queryStrategies().then(() => {
          Promise.all([
          this.initLikeStatus(),
          this.initLikeCount(),
          this.initFavoriteStatus(),
          this.initFavoriteCount()
          ]).then(() => {
            this.isLikedCountSorted = false;
            this.refresh();
          });
        });
      } else {
        this.showWaterfall().then(() => {
          Promise.all([
          this.initLikeStatus(),
          this.initLikeCount(),
          this.initFavoriteStatus(),
          this.initFavoriteCount()
          ]).then(() => {
            this.isLikedCountSorted = false;
            this.refresh();
          });
        });
      }
    }
    this.refresh();
    this.myScroll.scrollToIndex(0);
  }

  // 收藏数排序按钮的点击事件逻辑
  onClickFavoriteSort() {
    if (!this.isFavoritedCountSorted) {
      this.insertionSortByFavoriteCount();
      this.isFavoritedCountSorted = true;
    } else {
      if (this.waterModel === false) {
        this.queryStrategies().then(() => {
          Promise.all([
          this.initLikeStatus(),
          this.initLikeCount(),
          this.initFavoriteStatus(),
          this.initFavoriteCount()
          ]).then(() => {
            this.isFavoritedCountSorted = false;
            this.refresh();
          });
        });
      } else {
        this.showWaterfall().then(() => {
          Promise.all([
          this.initLikeStatus(),
          this.initLikeCount(),
          this.initFavoriteStatus(),
          this.initFavoriteCount()
          ]).then(() => {
            this.isFavoritedCountSorted = false;
            this.refresh();
          });
        });
      }
    }
    this.refresh();
    this.myScroll.scrollToIndex(0);
  }


  // 时间排序按钮的点击事件逻辑
  onClickDateSort() {
    if (!this.isDateSorted) {
      this.insertionSortByDate();
      this.isDateSorted = true;
    } else {
      if (this.waterModel === false) {
        this.queryStrategies().then(() => {
          Promise.all([
          this.initLikeStatus(),
          this.initLikeCount(),
          this.initFavoriteStatus(),
          this.initFavoriteCount()
          ]).then(() => {
            this.isDateSorted = false;
            this.refresh();
          });
        });
      } else {
        this.showWaterfall().then(() => {
          Promise.all([
          this.initLikeStatus(),
          this.initLikeCount(),
          this.initFavoriteStatus(),
          this.initFavoriteCount()
          ]).then(() => {
            this.isDateSorted = false;
            this.refresh();
          });
        });
      }
    }
    this.refresh();
    this.myScroll.scrollToIndex(0);
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
  // 开始隐藏大图和遮罩层的动画
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
        this.strategies = [...this.strategies];
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


  refresh() {
    // 使用ArkTS的@State修饰的变量，通过重新赋值来触发组件的重新渲染
    this.strategies = [...this.strategies];
  }


  // 计算flow item宽/高
  getSize() {
    let ret = Math.floor(Math.random() * this.maxSize)
    return (ret > this.minSize ? ret : this.minSize)
  }
  // 保存flow item宽/高
  getItemSizeArray() {
    for (let i = 0; i < this.strategies.length; i++) {
      this.itemWidthArray.push(this.getSize())
      this.itemHeightArray.push(this.getSize())
    }
  }
  //瀑布流底部组件
  @Builder itemFoot() {
    Row() {
      Text('您已经滑到底了~')
        .fontSize(18)
        .height(50)
        .margin({ top: 5 })
    }.width("100%").justifyContent(FlexAlign.Center)
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

              if (this.strategies.length>0) {
                if (this.SearchResults.length === 0) {
                  Row() {
                    Text('顺序流显示').fontSize(20).fontWeight(500).fontColor(this.FirstColor)
                      .onClick(() => {
                        this.waterModel = false;
                        this.FirstColor = '#ff000000';
                        this.ChangeColor = '#ff7e7a7a';
                        // 重新初始化数据
                        this.queryStrategies().then(() => {
                          Promise.all([
                          this.initLikeStatus(),
                          this.initLikeCount(),
                          this.initFavoriteStatus(),
                          this.initFavoriteCount()
                          ]).then(() => {
                            this.refresh();
                          });
                        });
                        this.myScroll.scrollToIndex(0);
                      });

                    Image($r('app.media.change')).width(22);

                    Text('瀑布流显示').fontSize(20).fontWeight(500).fontColor(this.ChangeColor)
                      .onClick(() => {
                        this.showWaterfall().then(() => {
                          Promise.all([
                          this.initLikeStatus(),
                          this.initLikeCount(),
                          this.initFavoriteStatus(),
                          this.initFavoriteCount()
                          ]).then(() => {
                            this.refresh();
                          });
                        });
                        this.ChangeColor = '#ff000000';
                        this.FirstColor = '#ff7e7a7a';
                      });
                  }
                  .zIndex(99)
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
                  });

                      Row() {
                        Text('喜欢').fontSize(20).fontWeight(500).onClick(() => this.onClickLikeSort()).fontColor(this.isLikedCountSorted? '#ff3a57a9': '#ff7e7a7a') // 根据排序状态设置文本颜色

                        Image($r('app.media.change')).width(22)

                        Text('收藏').fontSize(20).fontWeight(500).onClick(() => this.onClickFavoriteSort()).fontColor(this.isFavoritedCountSorted? '#ff3a57a9' : '#ff7e7a7a')

                        Image($r('app.media.change')).width(22)

                        Text('时间').fontSize(20).fontWeight(500).onClick(() => this.onClickDateSort()).fontColor(this.isDateSorted? '#ff3a57a9' : '#ff7e7a7a')
                      }
                      .zIndex(99)
                      .width('100%')
                      .justifyContent(FlexAlign.SpaceBetween)
                      .margin({ top: 90 })
                      .border({
                        width: 2,
                        color: Color.Gray
                      })
                      .borderRadius(15)
                      .padding({
                        left: 30,
                        right: 30
                      })
                    } else {
                      Row() {
                        Text('您查询到的内容如下：').fontSize(20).fontWeight(500).margin({ top: 60 });
                      }.width("100%").justifyContent(FlexAlign.Center)
                    }

                        if (this.SearchResults.length > 0) {
                            List({scroller:this.myScroll}) {
                              ForEach(this.SearchResults, (item: StrategyModel, index: number) => {
                                ListItem() {
                                  Column() {
                                    Text('攻略' + (index + 1).toString())
                                      .fontSize(30)
                                      .fontWeight(600);

                                    Text(item.strategy_name)
                                      .fontSize(30)
                                      .fontWeight(600)
                                      .margin({ left: 10, right: 10 });
                                    Text('来自用户：' + item.author_name)
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

                                    // 使用轮播组件渲染图片（多张图片时可轮播展示）
                                    if (item.image_path && Array.isArray(item.image_path) && item.image_path.length > 0) {
                                      Column() {
                                        Swiper() {
                                          ForEach(item.image_path, (imgPath: string, imgIndex: number) => {
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
                                      Row({space:8}){
                                        Image($r('app.media.xihuan'))
                                          .width(35)
                                          .onClick(() => {
                                            // 点击喜欢图标时，切换点赞状态（同时改变图标颜色和更新数据库中的点赞状态）
                                            this.toggleLikeStatusForItem(item.strategy_id, index);
                                          })
                                          .fillColor(this.getLikeColor(index))
                                        Text(`${this.likeCountMap[item.strategy_id]}`)
                                          .fontSize(18)
                                      }
                                      Row({space:8}){
                                        Image($r('app.media.shoucang'))
                                          .width(42)
                                          .onClick(() => {
                                            this.toggleFavoriteStatusForItem(item.strategy_id, index);
                                          })
                                          .fillColor(this.getFavoriteColor(index))

                                        Text(`${this.favoriteCountMap[item.strategy_id]}`)
                                          .fontSize(18)
                                      }

                                    }.margin({ bottom: 10 });

                                    Text(index === this.SearchResults.length - 1? '这是最后一条攻略' : '请查看下条攻略')
                                      .fontSize(20)
                                      .margin({ bottom: 30 })
                                      .border({
                                        width: { bottom: 3 },
                                        style: BorderStyle.Dashed
                                      })
                                      .width('100%');
                                  }
                                }
                              }, (item: StrategyModel) => item.strategy_id);
                            }

                          .margin({ top: 130 })
                          .scrollBar(BarState.Off)
                        } else if(this.waterModel === true){
                          Column() {
                            WaterFlow({ footer: this.itemFoot.bind(this),scroller:this.myScroll}) {
                              ForEach(this.strategies, (item,index:number) => {
                                FlowItem() {
                                  Column() {
                                    // 只展示图片数组的第一张图片（确保图片数组存在元素）
                                    if (item.image_path && Array.isArray(item.image_path) && item.image_path.length > 0) {
                                      Image(item.image_path[0]).borderRadius({topLeft:7,topRight:7}).objectFit(ImageFit.Fill).margin({ bottom: 10 })
                                    }
                                    Text(item.strategy_name.split('').join('\u200B'))
                                      .fontSize(19)
                                      .fontWeight(500)
                                      .maxLines(2)
                                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                                      .margin({ bottom: 8,left:10,right:10 })
                                   Row(){
                                     Row({space:4}){
                                       Image(this.avatarList[index]).width(30).height(30).borderRadius(15)
                                       Column(){
                                         Text(item.author_name.split('').join('\u200B'))
                                           .width("37%")
                                           .fontSize(14)
                                           .maxLines(1)
                                           .textOverflow({ overflow: TextOverflow.Ellipsis })

                                         Text(item.date)
                                           .fontSize(12)
                                           .fontColor("#ff807e7e")
                                       }
                                     }
                                     // 显示点赞数和点赞状态
                                     Row({ space: 6 }) {
                                       Row({space:3}){
                                         Image($r('app.media.xihuan'))
                                           .width(15)
                                           .fillColor(this.isLiked[index]? Color.Red : Color.Gray)
                                           .onClick(() => {
                                             this.toggleLikeStatusForItem(item.strategy_id,index);
                                           })
                                         Text(`${this.likeCountMap[item.strategy_id]}`)
                                           .fontSize(15)
                                           .fontWeight(400)
                                       }
                                       Row({space:3}){
                                         Image($r('app.media.shoucang'))
                                           .width(20)
                                           .fillColor(this.getFavoriteColor(index))
                                           .onClick(() => {
                                             this.toggleFavoriteStatusForItem(item.strategy_id,index);
                                           })
                                         Text(`${this.favoriteCountMap[item.strategy_id]}`)
                                           .fontSize(15)
                                           .fontWeight(400)
                                       }
                                     }
                                   }.width("100%").justifyContent(FlexAlign.SpaceBetween).padding({ left: 12, right: 12 }).margin({bottom:5})
                                  }
                                  .onClick(() => {
                                    // 跳转到新页面并传递攻略信息
                                    router.pushUrl({
                                      url: 'pages/WaterFlowInfo',
                                      params: {
                                        strategyId: item.strategy_id,
                                        strategyName: item.strategy_name,
                                        authorName: item.author_name,
                                        date: item.date,
                                        content: item.content,
                                        imagePath: item.image_path,
                                        isLiked: this.isLiked[index],
                                        likeCount: this.likeCountMap[item.strategy_id],
                                        isFavorited: this.isFavorited[index],
                                        favoriteCount: this.favoriteCountMap[item.strategy_id],
                                        cityName:this.cityName,
                                        user_id:this.user_id
                                      }
                                    })
                                    router.RouterMode.Single
                                  })
                                }

                                .backgroundColor(Color.White)
                                .width(this.itemWidthArray[item])
                                .height(this.itemHeightArray[item])
                                .borderRadius(7)
                              }, item => item.strategy_id);
                            }
                            .backgroundColor('#fff3f1f1')
                            .columnsTemplate('1fr 1fr')
                            .itemConstraintSize({
                              minWidth: 0,
                              maxWidth: '100%',
                              minHeight: 0,
                              maxHeight: '100%'
                            })
                            .columnsGap(10)
                            .rowsGap(5)
                            .layoutDirection(FlexDirection.Column)
                          }
                          .margin({ top: 130 })
                        }


                        else {
                             List({scroller:this.myScroll}) {
                               ForEach(this.strategies, (item: StrategyModel, index: number) => {
                                 ListItem() {
                                   Column() {
                                     Text('攻略' + (index + 1).toString())
                                       .fontSize(30)
                                       .fontWeight(600);

                                     Text(item.strategy_name)
                                       .fontSize(30)
                                       .fontWeight(600)
                                       .margin({ left: 10, right: 10 });
                                     Text('来自用户：' + item.author_name)
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

                                     // 使用轮播组件渲染图片（多张图片时可轮播展示）
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




                                     Row({ space: 40 }) {
                                       Row({space:8}){
                                         Image($r('app.media.xihuan'))
                                           .width(35)
                                           .onClick(() => {
                                             // 点击喜欢图标时，切换点赞状态（同时改变图标颜色和更新数据库中的点赞状态）
                                             this.toggleLikeStatusForItem(item.strategy_id, index);
                                           })
                                           .fillColor(this.getLikeColor(index))
                                         Text(`${this.likeCountMap[item.strategy_id]}`)
                                           .fontSize(18)
                                       }
                                       Row({space:8}){
                                         Image($r('app.media.shoucang'))
                                           .width(42)
                                           .onClick(() => {
                                             this.toggleFavoriteStatusForItem(item.strategy_id, index);
                                           })
                                           .fillColor(this.getFavoriteColor(index))

                                         Text(`${this.favoriteCountMap[item.strategy_id]}`)
                                           .fontSize(18)
                                       }

                                     }.margin({ bottom: 10 });

                                     Text(index === this.strategies.length - 1? '这是最后一条攻略' : '请查看下条攻略')
                                       .fontSize(20)
                                       .margin({ bottom: 30 })
                                       .border({
                                         width: { bottom: 3 },
                                         style: BorderStyle.Dashed
                                       })
                                       .width('100%');
                                   }
                                 }
                               }, (item: StrategyModel) => item.strategy_id);
                             }
                           .margin({ top: 130 })
                           .scrollBar(BarState.Off)
                        }
                } else {
                    emptyView3();
                }
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
      if (this.strategies.length > 0) {

        Image($r('app.media.rocket'))
          .zIndex(99)
          .width(50)
          .backgroundColor(Color.White)
          .borderRadius(25)
          .padding(5)
          .offset({ x: 145, y: -140 })
          .onClick(() => {
            this.myScroll.scrollToIndex(0)
          })

        Image($r('app.media.search'))
          .zIndex(99)
          .width(50)
          .backgroundColor(Color.White)
          .borderRadius(25)
          .padding(5)
          .offset({ x: 145, y: -260 })
          .onClick(() => {
            this.controller.open();
          });

      }
    }
  }

}