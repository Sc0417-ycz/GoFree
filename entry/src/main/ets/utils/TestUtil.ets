
import relationalStore from '@ohos.data.relationalStore'
import ProvinceModel from '../model/ProvinceModel'
import CityModel from '../model/CityModel'
import StrategyModel from '../model/StrategyModel'
import UserModel from '../model/UserModel'
import PhotoModel from '../model/PhotoModel'


class TestUtil{
  private rdbStore:relationalStore.RdbStore | null = null
  initTestDB(context:Context,tableName1?:string,tableName2?:string,tableName3?:string,tableName4?:string,tableName5?:string,tableName6?:string,tableName7?:string){

    const STORE_CONFIG:relationalStore.StoreConfig={
      name:'Test.db',
      securityLevel:relationalStore.SecurityLevel.S1
    }


    relationalStore.getRdbStore(context,STORE_CONFIG,(err,store)=>{
      if(err){
        console.error(`获取RdbStore失败.Code:${err.code},message:${err.message}`)
        return;
      }
      console.info('获取RdbStore成功')
      this.rdbStore = store


      const SQL_CREATE_USERS_TABLE = `CREATE TABLE IF NOT EXISTS ${tableName1}(
      USER_ID INTEGER PRIMARY KEY AUTOINCREMENT,
      USERNAME TEXT NOT NULL,
      PASSWORD TEXT NOT NULL,
      USER_PROFILE TEXT
      )`;

      store.executeSql(SQL_CREATE_USERS_TABLE).then(() => {
        console.info('创建用户表成功');
      }).catch((err) => {
        console.error(`创建用户表失败。错误码: ${err.code}, 错误信息: ${err.message}`);
      });


      const SQL_CREATE_PROVINCES_TABLE = `CREATE TABLE IF NOT EXISTS ${tableName2}(
      PROVINCE_ID INTEGER PRIMARY KEY AUTOINCREMENT,
      PROVINCE_NAME TEXT NOT NULL,
      PROVINCE_IMAGE TEXT
      )`

      store.executeSql(SQL_CREATE_PROVINCES_TABLE).then(() => {
        console.info('创建省份表成功');
      }).catch((err) => {
        console.error(`创建省份表失败。错误码: ${err.code}, 错误信息: ${err.message}`);
      });


      const SQL_CREATE_CITIES_TABLE = `CREATE TABLE IF NOT EXISTS ${tableName3}(
      CITY_ID INTEGER PRIMARY KEY AUTOINCREMENT,
      CITY_NAME TEXT NOT NULL,
      CITY_CONTENT TEXT,
      CITY_IMAGE TEXT,
      PROVINCE_ID INTEGER NOT NULL,
      FOREIGN KEY (PROVINCE_ID) REFERENCES ${tableName2}(PROVINCE_ID)
      )`

      store.executeSql(SQL_CREATE_CITIES_TABLE).then(() => {
        console.info('创建城市表成功');
      }).catch((err) => {
        console.error(`创建城市表失败。错误码: ${err.code}, 错误信息: ${err.message}`);
      });


      const SQL_CREATE_STRATEGIES_TABLE = `CREATE TABLE IF NOT EXISTS ${tableName4}(
      STRATEGY_ID INTEGER PRIMARY KEY AUTOINCREMENT,
      STRATEGY_NAME TEXT NOT NULL,
      AUTHOR_NAME TEXT,
      DATE TEXT,
      CONTENT TEXT,
      IMAGE_PATH TEXT,
      CITY_ID INTEGER,
      USER_ID INTEGER,
      FOREIGN KEY (CITY_ID) REFERENCES ${tableName3}(CITY_ID),
      FOREIGN KEY (USER_ID) REFERENCES ${tableName1}(USER_ID)
      )`;

      store.executeSql(SQL_CREATE_STRATEGIES_TABLE).then(() => {
        console.info('创建攻略表成功');
      }).catch((err) => {
        console.error(`创建攻略表失败。错误码: ${err.code}, 错误信息: ${err.message}`);
      });

      const SQL_CREATE_STRATEGY_LIKES_TABLE =`CREATE TABLE IF NOT EXISTS ${tableName5}(
      LIKE_ID INTEGER PRIMARY KEY AUTOINCREMENT,
      STRATEGY_ID INTEGER NOT NULL,
      USER_ID INTEGER NOT NULL,
      IS_LIKED INTEGER NOT NULL DEFAULT 0,  -- 0表示未点赞，1表示点赞，用于记录点赞状态
      FOREIGN KEY (STRATEGY_ID) REFERENCES ${tableName4}(STRATEGY_ID),
      FOREIGN KEY (USER_ID) REFERENCES ${tableName1}(USER_ID)
      )`;

      store.executeSql(SQL_CREATE_STRATEGY_LIKES_TABLE).then(() => {
        console.info('创建攻略喜欢表成功');
      }).catch((err) => {
        console.error(`创建攻略喜欢表失败。错误码: ${err.code}, 错误信息: ${err.message}`);
      });



      const SQL_CREATE_PHOTO_TABLE = `CREATE TABLE IF NOT EXISTS ${tableName6}(
      PHOTO_ID INTEGER PRIMARY KEY AUTOINCREMENT,
      IMAGE TEXT,
      TEXT_CONTENT TEXT,
      CITY_ID INTEGER,
      USER_ID INTEGER,
      FOREIGN KEY (CITY_ID) REFERENCES ${tableName3}(CITY_ID),
      FOREIGN KEY (USER_ID) REFERENCES ${tableName1}(USER_ID)
     )`;

      store.executeSql(SQL_CREATE_PHOTO_TABLE).then(() => {
        console.info('创建图片表成功');
      }).catch((err) => {
        console.error(`创建图片表失败。错误码: ${err.code}, 错误信息: ${err.message}`);
      });

      const SQL_CREATE_STRATEGY_FAVORITES_TABLE = `CREATE TABLE IF NOT EXISTS ${tableName7}(
      FAVORITE_ID INTEGER PRIMARY KEY AUTOINCREMENT,
      STRATEGY_ID INTEGER NOT NULL,
      USER_ID INTEGER NOT NULL,
      IS_FAVORITE INTEGER NOT NULL DEFAULT 0,  -- 0表示未收藏，1表示收藏，用于记录收藏状态
      FOREIGN KEY (STRATEGY_ID) REFERENCES ${tableName4}(STRATEGY_ID),
      FOREIGN KEY (USER_ID) REFERENCES ${tableName1}(USER_ID)
     )`;

      store.executeSql(SQL_CREATE_STRATEGY_FAVORITES_TABLE).then(() => {
        console.info('创建攻略收藏表成功');
      }).catch((err) => {
        console.error(`创建攻略收藏表失败。错误码: ${err.code}, 错误信息: ${err.message}`);
      });

    })
  }



  //插入用户用户名和密码
  async insertUserData(tableName1: string, user: { username: string, password: string }) {
    if (this.rdbStore!= null) {
      const valueBucket: relationalStore.ValuesBucket = {
        USERNAME: user.username,
        PASSWORD: user.password
      };
      this.rdbStore.insert(tableName1, valueBucket, (err, rowId) => {
        if (err) {
          console.error(`插入用户数据失败.Code:${err.code},message:${err.message}`);
          return;
        }
        console.info(`成功插入用户数据.rowId:${rowId}`);
      });
    } else {
      console.error('数据库连接未建立，无法进行插入操作');
    }
  }

  // 插入用户头像的方法
  async insertUserProfile(tableName1: string, username: string, userProfile: string) {
    if (this.rdbStore!= null) {
      try {
        // 根据用户名查询用户ID
        const userResult = await this.queryUser(["USER_ID", "USERNAME", "PASSWORD"], tableName1, username);
        if (userResult.length > 0) {
          const userId = userResult[0].user_id;
          // 创建用于更新的ValuesBucket对象
          const updateValueBucket: relationalStore.ValuesBucket = {
            USER_PROFILE: userProfile
          };
          // 创建查询条件
          const predicates = new relationalStore.RdbPredicates(tableName1);
          predicates.equalTo('USER_ID', userId);
          // 执行更新操作
          const result = await this.rdbStore.update(updateValueBucket, predicates);
          console.info(`成功更新用户头像，影响行数: ${result}`);
        } else {
          console.error(`未找到用户名 "${username}" 对应的用户信息，无法插入头像。`);
        }
      } catch (error) {
        console.error(`查询用户信息或插入头像出现异常，错误信息: ${error}`);
      }
    } else {
      console.error('数据库连接未建立，无法进行操作');
    }
  }

  // 查询用户头像路径的方法
  async queryUserProfile(tableName1: string, user_id: string): Promise<string | null> {
    if (this.rdbStore!== null) {
      const predicates = new relationalStore.RdbPredicates(tableName1);
      predicates.equalTo('USER_ID', user_id);
      const resultSet = await this.rdbStore.query(predicates, ['USER_PROFILE']);
      if (resultSet.rowCount > 0) {
        resultSet.goToNextRow();
        const userProfile = resultSet.getString(resultSet.getColumnIndex('USER_PROFILE'));
        resultSet.close();
        return userProfile;
      }
      resultSet.close();
    }
    return null;
  }

  async queryUserProfileByStrategyId(tableName4: string, tableName1: string, strategyId: string): Promise<string | null> {
    if (this.rdbStore!== null) {
      // 首先根据攻略id查询发布该攻略的用户id
      const strategyPredicates = new relationalStore.RdbPredicates(tableName4);
      strategyPredicates.equalTo('STRATEGY_ID', strategyId);
      const strategyResultSet = await this.rdbStore.query(strategyPredicates, ['USER_ID']);
      if (strategyResultSet.rowCount > 0) {
        strategyResultSet.goToNextRow();
        const userId = strategyResultSet.getString(strategyResultSet.getColumnIndex('USER_ID'));
        strategyResultSet.close();

        // 使用查询到的用户id查询用户头像
        const userProfilePredicates = new relationalStore.RdbPredicates(tableName1);
        userProfilePredicates.equalTo('USER_ID', userId);
        const userProfileResultSet = await this.rdbStore.query(userProfilePredicates, ['USER_PROFILE']);
        if (userProfileResultSet.rowCount > 0) {
          userProfileResultSet.goToNextRow();
          const userProfile = userProfileResultSet.getString(userProfileResultSet.getColumnIndex('USER_PROFILE'));
          userProfileResultSet.close();
          return userProfile;
        }
        userProfileResultSet.close();
      }
      strategyResultSet.close();
    }
    return null;
  }

  // 查询用户数据方法（基于用户名查询）
  async queryUser(column:Array<string>,tableName1:string,username?: string) {
    let predicates1 = new relationalStore.RdbPredicates(tableName1)
    if (username) {
      predicates1.equalTo('USERNAME',username);
    }
    let user: UserModel[] = []
    const resultSet = await (this.rdbStore as relationalStore.RdbStore).query(predicates1,column)
    while (resultSet.goToNextRow()) {
      let user_id = resultSet.getString(resultSet.getColumnIndex('USER_ID'));
      let username = resultSet.getString(resultSet.getColumnIndex('USERNAME'));
      let password = resultSet.getString(resultSet.getColumnIndex('PASSWORD'));

      const temp:UserModel = new UserModel()
      temp.user_id = user_id
      temp.username = username
      temp.password = password

      user.push(temp)
    }
    resultSet.close();


    return user;
  }

  //插入中国所有省份数据
  async insertProvinceData(tableName2: string, value2: relationalStore.ValuesBucket[]) {
    if (this.rdbStore!= null) {
      this.rdbStore.batchInsert(tableName2, value2, (err: any) => {
        if (err) {
          console.error(`批量插入省份数据失败.Code:${err.code},message:${err.message}`);
          // 这里可以根据具体需求，进一步处理错误情况，比如抛出异常给上层调用者等
          return;
        }
        console.info('批量插入省份数据成功');
      });
    } else {
      console.error('数据库连接未建立，无法进行批量插入操作');
    }
  }

  //查询中国所有省份数据，并可以通过省份名称查询
  async queryProvincesData(column:Array<string>,tableName2:string,provinceName?: string) {
    let predicates1 = new relationalStore.RdbPredicates(tableName2)
    if (provinceName) {
      predicates1.equalTo('PROVINCE_NAME', provinceName);
    }
    let province: ProvinceModel[] = []
    const resultSet = await (this.rdbStore as relationalStore.RdbStore).query(predicates1,column)
    while (resultSet.goToNextRow()) {
      let province_id = resultSet.getString(resultSet.getColumnIndex('PROVINCE_ID'));
      let province_name = resultSet.getString(resultSet.getColumnIndex('PROVINCE_NAME'));
      let province_image = resultSet.getString(resultSet.getColumnIndex('PROVINCE_IMAGE'));

      const temp:ProvinceModel = new ProvinceModel()
      temp.province_id = province_id
      temp.province_name = province_name
      temp.province_image = province_image

      province.push(temp)
    }
    resultSet.close();


    return province;
  }

  //插入某一省份的所有城市数据
  async insertCityData(tableName3: string, cityData: relationalStore.ValuesBucket[]) {
    if (this.rdbStore!= null) {
      // 用于存储整理后的城市数据，每个元素包含城市数据和对应的省份ID
      let preparedCityData: { value: relationalStore.ValuesBucket, provinceId: number }[] = [];

      // 遍历要插入的城市数据数组
      for (let i = 0; i < cityData.length; i++) {
        const cityName = cityData[i].CITY_NAME as string;
        const cityContent = cityData[i].CITY_CONTENT as string;
        const cityImage = cityData[i].CITY_IMAGE as string;
        const provinceName = cityData[i].PROVINCE_NAME as string;


        // 先查询所有省份数据，获取省份ID和省份名称的对应关系
        const allProvincesData = await this.queryProvincesData(['PROVINCE_ID', 'PROVINCE_NAME','PROVINCE_IMAGE'],"MYPROVINCE");

        // 在所有省份数据中查找与当前城市数据中省份名称匹配的省份ID
        const matchingProvince = allProvincesData.find((province) => province.province_name === provinceName);

        if (matchingProvince) {
          const provinceId = matchingProvince.province_id;

          // 创建新的ValuesBucket对象，设置城市名称和省份ID
          const newCityValue: relationalStore.ValuesBucket = {
            CITY_NAME: cityName,
            CITY_CONTENT:cityContent,
            CITY_IMAGE:cityImage,
            PROVINCE_ID: provinceId
          };

          // 将整理好的城市数据和省份ID添加到数组中
          preparedCityData.push({ value: newCityValue, provinceId: Number(provinceId) });
        } else {
          console.error(`未找到与城市数据中省份名称 "${provinceName}" 对应的省份ID，无法插入城市数据。`);
        }
      }

      // 执行批量插入操作
      this.rdbStore.batchInsert(tableName3, preparedCityData.map(item => item.value), (err: any) => {
        if (err) {
          console.error(`批量插入城市数据失败.Code:${err.code},message:${err.message}`);
          // 这里可以根据具体需求，进一步处理错误情况，比如抛出经验给上层调用者等
          return;
        }
        console.info('批量插入城市数据成功');
      });
    } else {
      console.error('数据库连接未建立，无法进行批量插入操作');
    }
  }

  //查询某一省份的所有城市数据，并可以通过城市名称查询
  async queryCitiesDataByProvinceName(column: Array<string>, tableName3: string, provinceName?: string, cityName?: string) {
    let cities: CityModel[] = [];
    if (this.rdbStore!= null) {
      if (cityName) {
        // 根据城市名称查询城市信息
        let predicates = new relationalStore.RdbPredicates(tableName3);
        predicates.equalTo('CITY_NAME', cityName);

        const resultSet = await this.rdbStore.query(predicates, column);
        while (resultSet.goToNextRow()) {
          let city_id = resultSet.getString(resultSet.getColumnIndex('CITY_ID'));
          let city_name = resultSet.getString(resultSet.getColumnIndex('CITY_NAME'));
          let city_content = resultSet.getString(resultSet.getColumnIndex('CITY_CONTENT'));
          let city_image = resultSet.getString(resultSet.getColumnIndex('CITY_IMAGE'));
          let province_id = resultSet.getString(resultSet.getColumnIndex('PROVINCE_ID'));

          const temp: CityModel = new CityModel();
          temp.city_id = city_id;
          temp.city_name = city_name;
          temp.city_content = city_content;
          temp.city_image = city_image;
          temp.province_id = province_id;

          cities.push(temp);
        }
        resultSet.close();
      } else if (provinceName) {
        // 先查询省份ID
        const provinceIdResult = await this.queryProvincesData(['PROVINCE_ID', 'PROVINCE_NAME','PROVINCE_IMAGE'], "MYPROVINCE", provinceName);
        if (provinceIdResult.length > 0) {
          const provinceId = provinceIdResult[0].province_id;

          // 创建查询城市数据的条件对象
          let predicates2 = new relationalStore.RdbPredicates(tableName3);
          predicates2.equalTo('PROVINCE_ID', provinceId);

          // 执行查询城市数据的操作
          const resultSet = await this.rdbStore.query(predicates2, column);
          while (resultSet.goToNextRow()) {
            let city_id = resultSet.getString(resultSet.getColumnIndex('CITY_ID'));
            let city_name = resultSet.getString(resultSet.getColumnIndex('CITY_NAME'));
            let city_content = resultSet.getString(resultSet.getColumnIndex('CITY_CONTENT'));
            let city_image = resultSet.getString(resultSet.getColumnIndex('CITY_IMAGE'));
            let province_id = resultSet.getString(resultSet.getColumnIndex('PROVINCE_ID'));

            const temp: CityModel = new CityModel();
            temp.city_id = city_id;
            temp.city_name = city_name;
            temp.city_content = city_content;
            temp.city_image = city_image;
            temp.province_id = province_id;

            cities.push(temp);
          }
          resultSet.close();
        }
      }
    }

    return cities;
  }

  //插入攻略
  async insertStrategyData(tableName4: string, strategyName: string, authorName: string, date: string, content: string, imageResources: string[], cityName: string, username: string) {
    if (this.rdbStore!= null) {
      try {
        // 先根据用户名查询对应的USER_ID，这里使用try-catch捕获可能出现的其他异常
        const userResult = await this.queryUser(["USER_ID", "USERNAME", "PASSWORD"], "USER", username);
        if (userResult.length > 0) {
          const userId = userResult[0].user_id;

          // 先查询指定城市名称对应的城市ID
          const cityIdResult = await this.queryCitiesDataByProvinceName(['CITY_NAME', 'CITY_ID', "CITY_CONTENT", 'CITY_IMAGE', 'PROVINCE_ID'], "MYCITY", undefined, cityName);

          if (cityIdResult.length > 0) {
            const cityId = cityIdResult[0].city_id;

            const valueBucket: relationalStore.ValuesBucket = {
              STRATEGY_NAME: strategyName,
              AUTHOR_NAME: authorName,
              DATE: date,
              CONTENT: content,
              IMAGE_PATH: JSON.stringify(imageResources),
              CITY_ID: cityId,
              USER_ID: userId
            };

            // 执行插入攻略数据的操作
            this.rdbStore.insert(tableName4, valueBucket, (err, rowId) => {
              if (err) {
                console.error(`插入攻略数据失败.Code:${err.code},message:${err.message}`);
                return;
              }
              console.info(`成功插入攻略数据.rowId:${rowId}`);
            });
          } else {
            console.error(`未找到指定城市名称 "${cityName}" 对应的城市ID，无法插入攻略数据。`);
          }
        } else {
          console.error(`未找到用户名 "${username}" 对应的用户信息，无法插入攻略数据。`);
        }
      } catch (error) {
        console.error(`查询用户信息出现异常，导致无法插入攻略数据。错误信息: ${error}`);
        // 这里也可以根据实际情况，选择抛出异常给上层调用者等方式来进一步处理错误
        return;
      }
    } else {
      console.error('数据库连接未建立，无法进行插入操作');
    }
  }

  // 根据攻略名和用户名删除攻略
  async deleteByStrategyNameAndUsername(tableName4: string, strategyName: string, user_id: string) {
    let predicates1 = new relationalStore.RdbPredicates(tableName4);

    // 通过攻略名和用户名来构建筛选条件
    predicates1.equalTo('STRATEGY_NAME', strategyName).equalTo('USER_ID',user_id);
    if (this.rdbStore!== null) {
      try {
        const result = await this.rdbStore.delete(predicates1);
        console.info(`成功删除数据，影响行数:${result}`);
      } catch (err) {
        console.error(`删除数据失败 Code:${err.code},message:${err.message}`);
      }
    }
  }

  // 根据攻略名和用户名修改攻略
  async updateByStrategyNameAndUsername(tableName4: string, strategyName: string, user_id: string, value: relationalStore.ValuesBucket) {
    let predicates1 = new relationalStore.RdbPredicates(tableName4);

    // 通过攻略名和用户名来构建筛选条件
    predicates1.equalTo('STRATEGY_NAME', strategyName).equalTo('USER_ID', user_id);

    if (this.rdbStore!= null) {
      try {
        const result = await this.rdbStore.update(value, predicates1);
        console.info(`修改数据成功，影响行数:${result}`);
      } catch (err) {
        console.error(`修改数据失败 Code:${err.code},message:${err.message}`);
      }
    }
  }

  // 查询指定城市下所有攻略时间并转化为数值的方法
  async queryStrategyDatesAsNumber(cityName: string): Promise<number[]> {
    if (!this.rdbStore) {
      console.error('数据库连接未建立，无法进行操作');
      return [];
    }
    try {
      // 先查询指定城市名称对应的城市ID
      const cityIdResult = await this.queryCitiesDataByProvinceName(['CITY_NAME', 'CITY_ID', "CITY_CONTENT", 'CITY_IMAGE', 'PROVINCE_ID'], "MYCITY", undefined, cityName);
      if (cityIdResult.length > 0) {
        const cityId = cityIdResult[0].city_id;
        const predicates = new relationalStore.RdbPredicates("MYSTRATEGY");
        predicates.equalTo('CITY_ID', cityId);
        const resultSet = await this.rdbStore.query(predicates, ['DATE']);
        const dateNumbers: number[] = [];
        while (resultSet.goToNextRow()) {
          const dateStr = resultSet.getString(resultSet.getColumnIndex('DATE'));
          if (dateStr) {
            const dateNumber = parseInt(dateStr.replace(/-/g, ''), 10);
            dateNumbers.push(dateNumber);
          }
        }
        resultSet.close();
        return dateNumbers;
      }
    } catch (error) {
      console.error(`查询指定城市下所有攻略时间出现异常，错误信息: ${error}`);
    }
    return [];
  }

  // 根据城市名查询该城市下所有攻略信息的方法
  async queryStrategyDataByCityName(column: Array<string>, tableName4: string, cityName: string) {
    let strategies: StrategyModel[] = []; // 用于存储最终查询到的攻略信息
    if (this.rdbStore!= null) {
      try {
        // 先查询指定城市名称对应的城市ID
        const cityIdResult = await this.queryCitiesDataByProvinceName(['CITY_NAME', 'CITY_ID', "CITY_CONTENT", 'CITY_IMAGE', 'PROVINCE_ID'], "MYCITY", undefined, cityName);

        if (cityIdResult.length > 0) {
          const cityId = cityIdResult[0].city_id;

          const predicates = new relationalStore.RdbPredicates(tableName4);
          predicates.equalTo('CITY_ID', cityId);

          const resultSet = await this.rdbStore.query(predicates, column);
          while (resultSet.goToNextRow()) {
            const temp: StrategyModel = new StrategyModel();
            temp.strategy_id = resultSet.getString(resultSet.getColumnIndex('STRATEGY_ID'));
            temp.strategy_name = resultSet.getString(resultSet.getColumnIndex('STRATEGY_NAME'));
            temp.author_name = resultSet.getString(resultSet.getColumnIndex('AUTHOR_NAME'));
            temp.date = resultSet.getString(resultSet.getColumnIndex('DATE'));
            temp.content = resultSet.getString(resultSet.getColumnIndex('CONTENT'));
            temp.image_path = [];
            const imageStr = resultSet.getString(resultSet.getColumnIndex('IMAGE_PATH'));
            // 解析图片信息字符串为正确的数组格式，使用JSON.parse去除多余的引号等字符，使其变为真正的图片路径字符串数组
            const parsedImageArray = JSON.parse(imageStr) as string[];
            parsedImageArray.forEach((imgPath) => {
              (temp.image_path as string[]).push(imgPath);
            });

            strategies.push(temp);
          }
          resultSet.close();
        }
      } catch (error) {
        console.error(`查询城市下攻略信息出现异常，错误信息: ${error}`);
        // 可以根据实际需求进一步处理错误，比如返回一个默认的空数组等
        return strategies;
      }
    }
    return strategies;
  }


  // 新增方法：查询指定城市下所有攻略的id
  async queryAllStrategyIds(cityName: string): Promise<string[]> {
    const column = ["STRATEGY_ID"];
    const tableName4 = "MYSTRATEGY";
    if (!cityName) {
      return [];
    }
    try {
      // 先查询指定城市名称对应的城市ID
      const cityIdResult = await this.queryCitiesDataByProvinceName(['CITY_NAME', 'CITY_ID', "CITY_CONTENT", 'CITY_IMAGE', 'PROVINCE_ID'], "MYCITY", undefined, cityName);
      if (cityIdResult.length > 0) {
        const cityId = cityIdResult[0].city_id;
        const predicates = new relationalStore.RdbPredicates(tableName4);
        predicates.equalTo('CITY_ID', cityId);
        const resultSet = await this.rdbStore.query(predicates, column);
        const strategyIds: string[] = [];
        while (resultSet.goToNextRow()) {
          const strategyId = resultSet.getString(resultSet.getColumnIndex('STRATEGY_ID'));
          strategyIds.push(strategyId);
        }
        resultSet.close();
        return strategyIds;
      }
    } catch (error) {
      console.error(`查询攻略id出现异常，错误信息: ${error}`);
    }
    return [];
  }

  // 根据用户名和城市名称查询该用户在特定城市下对应的所有攻略数据（结合用户名和城市名进行关联查询）
  async queryStrategyDataByUsernameAndCityName(column: Array<string>, tableName4: string, cityName: string, username: string): Promise<StrategyModel[]> {
    let strategies: StrategyModel[] = []; // 用于存储最终查询到的攻略信息
    if (this.rdbStore!= null) {
      try {
        // 先查询指定城市名称对应的城市ID
        const cityIdResult = await this.queryCitiesDataByProvinceName(['CITY_NAME', 'CITY_ID', "CITY_CONTENT", 'CITY_IMAGE', 'PROVINCE_ID'], "MYCITY", undefined, cityName);

        if (cityIdResult.length > 0) {
          const cityId = cityIdResult[0].city_id;
          // 先根据用户名查询对应的USER_ID
          const userResult = await this.queryUser(["USER_ID", "USERNAME", "PASSWORD"], "USER", username);
          if (userResult.length > 0) {
            const userId = userResult[0].user_id;

            const predicates = new relationalStore.RdbPredicates(tableName4);
            predicates.equalTo('USER_ID', userId);
            predicates.equalTo('CITY_ID', cityId);

            const resultSet = await this.rdbStore.query(predicates, column);
            while (resultSet.goToNextRow()) {
              const temp: StrategyModel = new StrategyModel();
              temp.strategy_id = resultSet.getString(resultSet.getColumnIndex('STRATEGY_ID'));
              temp.strategy_name = resultSet.getString(resultSet.getColumnIndex('STRATEGY_NAME'));
              temp.author_name = resultSet.getString(resultSet.getColumnIndex('AUTHOR_NAME'));
              temp.date = resultSet.getString(resultSet.getColumnIndex('DATE'));
              temp.content = resultSet.getString(resultSet.getColumnIndex('CONTENT'));
              temp.image_path = [];
              const imageStr = resultSet.getString(resultSet.getColumnIndex('IMAGE_PATH'));
              // 解析图片信息字符串为正确的数组格式，使用JSON.parse去除多余的引号等字符，使其变为真正的图片路径字符串数组
              const parsedImageArray = JSON.parse(imageStr) as string[];
              parsedImageArray.forEach((imgPath) => {
                (temp.image_path as string[]).push(imgPath);
              });

              strategies.push(temp);
            }
            resultSet.close();
          }
        }
      } catch (error) {
        console.error(`查询用户信息或相关数据出现异常，无法完成攻略数据查询。错误信息: ${error}`);
        // 可以根据实际需求进一步处理错误，比如返回一个默认的空数组等
        return strategies;
      }
    }
    return strategies;
  }

  // 修改后的queryStrategyCountByUserIdProvinceAndCity方法，返回值为数组
  async queryStrategyCountByUserIdProvinceAndCity(userId: string, provinceName: string, cityName: string) {
    let count = 0;
    let province = "";
    let city = "";
    if (this.rdbStore!= null) {
      try {
        // 先查询省份ID及省份名称
        const provinceIdResult = await this.queryProvincesData(['PROVINCE_ID', 'PROVINCE_NAME', 'PROVINCE_IMAGE'], "MYPROVINCE", provinceName);
        if (provinceIdResult.length > 0) {
          province = provinceIdResult[0].province_name;
          const provinceId = provinceIdResult[0].province_id;

          // 再查询城市ID及城市名称
          const cityIdResult = await this.queryCitiesDataByProvinceName(['CITY_NAME', 'CITY_ID', "CITY_CONTENT", 'CITY_IMAGE', 'PROVINCE_ID'], "MYCITY", provinceName, cityName);
          if (cityIdResult.length > 0) {
            city = cityIdResult[0].city_name;
            const cityId = cityIdResult[0].city_id;

            const predicates = new relationalStore.RdbPredicates("MYSTRATEGY");
            predicates.equalTo('USER_ID', userId);
            predicates.equalTo('CITY_ID', cityId);

            const resultSet = await this.rdbStore.query(predicates, []);
            count = resultSet.rowCount;
            resultSet.close();
          }
        }
      } catch (error) {
        console.error(`查询攻略条数出现异常，错误信息: ${error}`);
      }
    }
    return [province, city, count.toString()]
  }

  // 新增方法：通过关键字对攻略信息实现模糊查询
  async queryStrategyDataByKeyword(column: Array<string>, tableName4: string, keyword: string): Promise<StrategyModel[]> {
    let strategies: StrategyModel[] = [];
    if (this.rdbStore!= null) {
      try {
        const predicates = new relationalStore.RdbPredicates(tableName4);
        // 使用like方法进行模糊匹配，% 表示匹配任意字符（前缀、后缀或中间包含都可匹配）
        predicates.like('STRATEGY_NAME', `%${keyword}%`)
          .or()
          .like('AUTHOR_NAME', `%${keyword}%`)
          .or()
          .like('CONTENT', `%${keyword}%`)
          .or()
          .like('DATE', `%${keyword}%`);

        const resultSet = await this.rdbStore.query(predicates, column);
        while (resultSet.goToNextRow()) {
          const temp: StrategyModel = new StrategyModel();
          temp.strategy_id = resultSet.getString(resultSet.getColumnIndex('STRATEGY_ID'));
          temp.strategy_name = resultSet.getString(resultSet.getColumnIndex('STRATEGY_NAME'));
          temp.author_name = resultSet.getString(resultSet.getColumnIndex('AUTHOR_NAME'));
          temp.date = resultSet.getString(resultSet.getColumnIndex('DATE'));
          temp.content = resultSet.getString(resultSet.getColumnIndex('CONTENT'));
          temp.image_path = [];
          const imageStr = resultSet.getString(resultSet.getColumnIndex('IMAGE_PATH'));
          // 解析图片信息字符串为正确的数组格式，使用JSON.parse去除多余的引号等字符，使其变为真正的图片路径字符串数组
          const parsedImageArray = JSON.parse(imageStr) as string[];
          parsedImageArray.forEach((imgPath) => {
            (temp.image_path as string[]).push(imgPath);
          });

          strategies.push(temp);
        }
        resultSet.close();
      } catch (error) {
        console.error(`通过关键字查询攻略信息出现异常，错误信息: ${error}`);
        // 可以根据实际需求进一步处理错误，比如返回一个默认的空数组等
        return strategies;
      }
    }
    return strategies;
  }

  // 插入点赞状态的方法，用于向数据库插入新的点赞记录（初始点赞状态设为未点赞，即 IS_LIKED 为 0）
  async insertLikeStatus(tableNameLikes: string, strategyId: string, userId: string) {
    if (this.rdbStore!= null) {
      const insertValueBucket: relationalStore.ValuesBucket = {
        STRATEGY_ID: strategyId,
        USER_ID: userId,
        IS_LIKED: 1 // 修改此处，插入时直接设为已点赞，符合点赞操作逻辑
      };
      try {
        const result = await this.rdbStore.insert(tableNameLikes, insertValueBucket);
        console.info(`成功插入点赞数据，影响行数: ${result}`);
        return true;
      } catch (err) {
        console.error(`插入点赞数据失败.Code:${err.code},message:${err.message}`);
        return false;
      }
    } else {
      console.error('数据库连接未建立，无法进行操作');
      return false;
    }
  }

  // 更新点赞状态的方法，根据传入的新状态值来更新数据库中指定攻略、用户的点赞记录
  async updateLikeStatus(tableNameLikes: string, strategyId: string, userId: string, newLikeStatus: boolean) {
    if (this.rdbStore!= null) {
      const existingLikePredicates = new relationalStore.RdbPredicates(tableNameLikes);
      existingLikePredicates.equalTo('STRATEGY_ID', strategyId).equalTo('USER_ID', userId);
      const existingLikeResultSet = await this.rdbStore.query(existingLikePredicates, []);

      const updateValueBucket: relationalStore.ValuesBucket = {
        IS_LIKED: newLikeStatus? 1 : 0
      };

      if (existingLikeResultSet.rowCount > 0) {
        const updateResult = await this.rdbStore.update(updateValueBucket, existingLikePredicates);
        console.info(`更新点赞状态成功，影响行数:${updateResult}`);
      } else {
        if (newLikeStatus) {
          const insertValueBucket: relationalStore.ValuesBucket = {
            STRATEGY_ID: strategyId,
            USER_ID: userId,
            IS_LIKED: 1
          };
          this.rdbStore.insert(tableNameLikes, insertValueBucket, (err, rowId) => {
            if (err) {
              console.error(`插入点赞数据失败.Code:${err.code},message:${err.message}`);
              return;
            }
            console.info(`成功插入点赞数据.rowId:${rowId}`);
          });
        }
      }
      existingLikeResultSet.close();
    } else {
      console.error('数据库连接未建立，无法进行操作');
    }
  }

  // 判断用户是否点赞指定攻略的方法，确保准确根据用户ID和攻略ID查询点赞状态
  async isUserLikedStrategy(tableNameLikes: string, strategyId: string, userId: string): Promise<boolean> {
    if (this.rdbStore!= null) {
      const likePredicates = new relationalStore.RdbPredicates(tableNameLikes);
      likePredicates.equalTo('STRATEGY_ID', strategyId).equalTo('USER_ID', userId).equalTo('IS_LIKED', 1);
      const resultSet = await this.rdbStore.query(likePredicates, []);
      const isLiked = resultSet.rowCount > 0;
      resultSet.close();
      return isLiked;
    } else {
      console.error('数据库连接未建立，无法进行操作');
      return false;
    }
  }

  // 新增方法：统计指定攻略的点赞数
  async countLikesForStrategy(tableNameLikes: string, strategyId: string) {
    let count = 0;
    if (this.rdbStore!= null) {
      const predicates = new relationalStore.RdbPredicates(tableNameLikes);
      predicates.equalTo('STRATEGY_ID', strategyId).equalTo('IS_LIKED', 1);

      const resultSet = await this.rdbStore.query(predicates, []);
      count = resultSet.rowCount;
      resultSet.close();
    }
    return count;
  }

  // 查询已点赞攻略信息的方法，根据传入的用户ID精确查询该用户已点赞的攻略信息
  async queryLikedStrategyData(column: Array<string>, tableName4: string, tableNameLikes: string, userId: string): Promise<StrategyModel[]> {
    let likedStrategies: StrategyModel[] = [];
    if (this.rdbStore!= null) {
      try {
        const likePredicates = new relationalStore.RdbPredicates(tableNameLikes);
        likePredicates.equalTo('USER_ID', userId).equalTo('IS_LIKED', 1);
        const likeResultSet = await this.rdbStore.query(likePredicates, []);
        while (likeResultSet.goToNextRow()) {
          const strategyId = likeResultSet.getString(likeResultSet.getColumnIndex('STRATEGY_ID'));

          const strategyPredicates = new relationalStore.RdbPredicates(tableName4);
          strategyPredicates.equalTo('STRATEGY_ID', strategyId);

          const strategyResultSet = await this.rdbStore.query(strategyPredicates, column);
          while (strategyResultSet.goToNextRow()) {
            const temp: StrategyModel = new StrategyModel();
            temp.strategy_id = strategyResultSet.getString(strategyResultSet.getColumnIndex('STRATEGY_ID'));
            temp.strategy_name = strategyResultSet.getString(strategyResultSet.getColumnIndex('STRATEGY_NAME'));
            temp.author_name = strategyResultSet.getString(strategyResultSet.getColumnIndex('AUTHOR_NAME'));
            temp.date = strategyResultSet.getString(strategyResultSet.getColumnIndex('DATE'));
            temp.content = strategyResultSet.getString(strategyResultSet.getColumnIndex('CONTENT'));
            temp.image_path = [];
            const imageStr = strategyResultSet.getString(strategyResultSet.getColumnIndex('IMAGE_PATH'));
            // 解析图片信息字符串为正确的数组格式，使用JSON.parse去除多余的引号等字符，使其变为真正的图片路径字符串数组
            const parsedImageArray = JSON.parse(imageStr) as string[];
            parsedImageArray.forEach((imgPath) => {
              (temp.image_path as string[]).push(imgPath);
            });

            likedStrategies.push(temp);
          }
          strategyResultSet.close();
        }
        likeResultSet.close();
      } catch (error) {
        console.error(`查询已点赞攻略信息出现异常，错误信息: ${error}`);
        return likedStrategies;
      }
    }
    return likedStrategies;
  }


  // 新增方法：插入收藏状态的方法，用于向数据库插入新的收藏记录
  async insertFavoriteStatus(tableName7: string, strategyId: string, userId: string) {
    if (this.rdbStore!= null) {
      const insertValueBucket: relationalStore.ValuesBucket = {
        STRATEGY_ID: strategyId,
        USER_ID: userId,
        IS_FAVORITE: 1 // 1 表示已收藏
      };
      try {
        const result = await this.rdbStore.insert(tableName7, insertValueBucket);
        console.info(`成功插入收藏数据，影响行数: ${result}`);
        return true;
      } catch (err) {
        console.error(`插入收藏数据失败.Code:${err.code},message:${err.message}`);
        return false;
      }
    } else {
      console.error('数据库连接未建立，无法进行操作');
      return false;
    }
  }

  // 新增方法：更新收藏状态的方法，根据传入的新状态值来更新数据库中指定攻略、用户的收藏记录
  async updateFavoriteStatus(tableName7: string, strategyId: string, userId: string, newFavoriteStatus: boolean) {
    if (this.rdbStore!= null) {
      const existingFavoritePredicates = new relationalStore.RdbPredicates(tableName7);
      existingFavoritePredicates.equalTo('STRATEGY_ID', strategyId).equalTo('USER_ID', userId);
      const existingFavoriteResultSet = await this.rdbStore.query(existingFavoritePredicates, []);

      const updateValueBucket: relationalStore.ValuesBucket = {
        IS_FAVORITE: newFavoriteStatus? 1 : 0
      };

      if (existingFavoriteResultSet.rowCount > 0) {
        const updateResult = await this.rdbStore.update(updateValueBucket, existingFavoritePredicates);
        console.info(`更新收藏状态成功，影响行数:${updateResult}`);
      } else {
        if (newFavoriteStatus) {
          const insertValueBucket: relationalStore.ValuesBucket = {
            STRATEGY_ID: strategyId,
            USER_ID: userId,
            IS_FAVORITE: 1
          };
          this.rdbStore.insert(tableName7, insertValueBucket, (err, rowId) => {
            if (err) {
              console.error(`插入收藏数据失败.Code:${err.code},message:${err.message}`);
              return;
            }
            console.info(`成功插入收藏数据.rowId:${rowId}`);
          });
        }
      }
      existingFavoriteResultSet.close();
    } else {
      console.error('数据库连接未建立，无法进行操作');
    }
  }

  // 新增方法：判断用户是否收藏指定攻略的方法，确保准确根据用户ID和攻略ID查询收藏状态
  async isUserFavoritedStrategy(tableName7: string, strategyId: string, userId: string): Promise<boolean> {
    if (this.rdbStore!= null) {
      const favoritePredicates = new relationalStore.RdbPredicates(tableName7);
      favoritePredicates.equalTo('STRATEGY_ID', strategyId).equalTo('USER_ID', userId).equalTo('IS_FAVORITE', 1);
      const resultSet = await this.rdbStore.query(favoritePredicates, []);
      const isFavorited = resultSet.rowCount > 0;
      resultSet.close();
      return isFavorited;
    } else {
      console.error('数据库连接未建立，无法进行操作');
      return false;
    }
  }

  // 新增方法：统计指定攻略的收藏数
  async countFavoritesForStrategy(tableName7: string, strategyId: string) {
    let count = 0;
    if (this.rdbStore!= null) {
      const predicates = new relationalStore.RdbPredicates(tableName7);
      predicates.equalTo('STRATEGY_ID', strategyId).equalTo('IS_FAVORITE', 1);

      const resultSet = await this.rdbStore.query(predicates, []);
      count = resultSet.rowCount;
      resultSet.close();
    }
    return count;
  }

  // 新增方法：查询已收藏攻略信息的方法，根据传入的用户ID精确查询该用户已收藏的攻略信息
  async queryFavoritedStrategyData(column: Array<string>, tableName4: string, tableName7: string, userId: string): Promise<StrategyModel[]> {
    let favoritedStrategies: StrategyModel[] = [];
    if (this.rdbStore!= null) {
      try {
        const favoritePredicates = new relationalStore.RdbPredicates(tableName7);
        favoritePredicates.equalTo('USER_ID', userId).equalTo('IS_FAVORITE', 1);
        const favoriteResultSet = await this.rdbStore.query(favoritePredicates, []);
        while (favoriteResultSet.goToNextRow()) {
          const strategyId = favoriteResultSet.getString(favoriteResultSet.getColumnIndex('STRATEGY_ID'));

          const strategyPredicates = new relationalStore.RdbPredicates(tableName4);
          strategyPredicates.equalTo('STRATEGY_ID', strategyId);

          const strategyResultSet = await this.rdbStore.query(strategyPredicates, column);
          while (strategyResultSet.goToNextRow()) {
            const temp: StrategyModel = new StrategyModel();
            temp.strategy_id = strategyResultSet.getString(strategyResultSet.getColumnIndex('STRATEGY_ID'));
            temp.strategy_name = strategyResultSet.getString(strategyResultSet.getColumnIndex('STRATEGY_NAME'));
            temp.author_name = strategyResultSet.getString(strategyResultSet.getColumnIndex('AUTHOR_NAME'));
            temp.date = strategyResultSet.getString(strategyResultSet.getColumnIndex('DATE'));
            temp.content = strategyResultSet.getString(strategyResultSet.getColumnIndex('CONTENT'));
            temp.image_path = [];
            const imageStr = strategyResultSet.getString(strategyResultSet.getColumnIndex('IMAGE_PATH'));
            // 解析图片信息字符串为正确的数组格式，使用JSON.parse去除多余的引号等字符，使其变为真正的图片路径字符串数组
            const parsedImageArray = JSON.parse(imageStr) as string[];
            parsedImageArray.forEach((imgPath) => {
              (temp.image_path as string[]).push(imgPath);
            });

            favoritedStrategies.push(temp);
          }
          strategyResultSet.close();
        }
        favoriteResultSet.close();
      } catch (error) {
        console.error(`查询已收藏攻略信息出现异常，错误信息: ${error}`);
        return favoritedStrategies;
      }
    }
    return favoritedStrategies;
  }



  // 插入多张图片及对应文本内容数据，实现一条文本对应多张图片的插入逻辑（多条图片作为一组整体插入，共用一条文本信息，每次插入一个包含这些信息的对象）
  async insertPhotoData(tableName6: string, imageResources: string[], textContent: string, cityName: string, username: string) {
    if (this.rdbStore!= null) {
      try {
        // 先根据用户名查询对应的USER_ID
        const userResult = await this.queryUser(["USER_ID", "USERNAME", "PASSWORD"], "USER", username);
        if (userResult.length > 0) {
          const userId = userResult[0].user_id;

          // 先查询指定城市名称对应的城市ID
          const cityIdResult = await this.queryCitiesDataByProvinceName(['CITY_NAME', 'CITY_ID', "CITY_CONTENT", 'CITY_IMAGE', 'PROVINCE_ID'], "MYCITY", undefined, cityName);
          if (cityIdResult.length > 0) {
            const cityId = cityIdResult[0].city_id;

            // 构建一个ValuesBucket对象用于插入，包含一条文本信息以及多条图片信息
            const valueBucket: relationalStore.ValuesBucket & { [key: string]: any } = {
              TEXT_CONTENT: textContent,
              CITY_ID: cityId,
              USER_ID: userId,
              IMAGE:JSON.stringify(imageResources)
            }


            // 执行插入操作（假设rdbStore有插入单个对象的方法，比如insert之类的，具体根据实际数据库操作库来调整）
            this.rdbStore.insert(tableName6, valueBucket, (err, rowId) => {
              if (err) {
                console.error(`插入图片数据失败.Code:${err.code},message:${err.message}`);
                return;
              }
              console.info(`成功插入图片数据，行ID: ${rowId}`);
            });
          } else {
            console.error(`未找到指定城市名称 "${cityName}" 对应的城市ID，无法插入图片数据。`);
          }
        } else {
          console.error(`未找到用户名 "${username}" 对应的用户信息，无法插入图片数据。`);
        }
      } catch (error) {
        console.error(`查询用户信息出现异常，导致无法插入图片数据。错误信息: ${error}`);
        // 这里也可以根据实际情况，选择抛出异常给上层调用者等方式来进一步处理错误
        return;
      }
    } else {
      console.error('数据库连接未建立，无法进行插入操作');
    }
  }

  // 根据城市名和用户名查询图片信息的方法，查询结果整合为一个包含一条文本信息以及多条图片信息的对象
  async queryPhotoDataByCityNameAndUsername(column: Array<string>, tableName6: string, cityName: string, username: string): Promise<PhotoModel[] | null> {
    if (this.rdbStore!= null) {
      try {
        // 先根据用户名查询对应的USER_ID
        const userResult = await this.queryUser(["USER_ID", "USERNAME", "PASSWORD"], "USER", username);
        if (userResult.length > 0) {
          const userId = userResult[0].user_id;

          // 先查询指定城市名称对应的城市ID
          const cityIdResult = await this.queryCitiesDataByProvinceName(['CITY_NAME', 'CITY_ID', "CITY_CONTENT", 'CITY_IMAGE', 'PROVINCE_ID'], "MYCITY", undefined, cityName);
          if (cityIdResult.length > 0) {
            const cityId = cityIdResult[0].city_id;

            const predicates = new relationalStore.RdbPredicates(tableName6);
            predicates.equalTo('USER_ID', userId);
            predicates.equalTo('CITY_ID', cityId);

            const resultSet = await this.rdbStore.query(predicates, column);
            const photoModels: PhotoModel[] = [];
            while (resultSet.goToNextRow()) {
              const temp: PhotoModel = new PhotoModel();
              // 获取文本信息，假设所有记录的文本信息是相同的，取当前记录的文本信息
              temp.text_content = resultSet.getString(resultSet.getColumnIndex('TEXT_CONTENT'));
              temp.city_id = cityId;
              temp.user_id = userId;
              temp.image = [];
              const imageStr = resultSet.getString(resultSet.getColumnIndex('IMAGE'));
              // 解析图片信息字符串为正确的数组格式，使用JSON.parse去除多余的引号等字符，使其变为真正的图片路径字符串数组
              const parsedImageArray = JSON.parse(imageStr) as string[];
              parsedImageArray.forEach((imgPath) => {
                (temp.image as string[]).push(imgPath);
              });
              photoModels.push(temp);
            }
            resultSet.close();
            return photoModels;
          }
        }
      } catch (error) {
        console.error(`查询图片信息出现异常，错误信息: ${error}`);
        // 可以根据实际需求进一步处理错误，比如返回null表示查询失败等
        return null;
      }
    }
    return null;
  }

  // 根据城市名查询该城市下所有图片信息的方法
  async queryPhotoDataByCityName(column: Array<string>, tableName6: string, cityName: string): Promise<PhotoModel[] | null> {
    if (this.rdbStore!= null) {
      try {
        // 先查询指定城市名称对应的城市ID
        const cityIdResult = await this.queryCitiesDataByProvinceName(['CITY_NAME', 'CITY_ID', "CITY_CONTENT", 'CITY_IMAGE', 'PROVINCE_ID'], "MYCITY", undefined, cityName);
        if (cityIdResult.length > 0) {
          const cityId = cityIdResult[0].city_id;

          const predicates = new relationalStore.RdbPredicates(tableName6);
          predicates.equalTo('CITY_ID', cityId);

          const resultSet = await this.rdbStore.query(predicates, column);
          const photoModels: PhotoModel[] = [];
          while (resultSet.goToNextRow()) {
            const temp: PhotoModel = new PhotoModel();
            // 获取文本信息，假设所有记录的文本信息是相同的，取当前记录的文本信息
            temp.text_content = resultSet.getString(resultSet.getColumnIndex('TEXT_CONTENT'));
            temp.city_id = cityId;
            temp.user_id = null; // 这里用户ID不确定，先设为null
            temp.image = [];
            const imageStr = resultSet.getString(resultSet.getColumnIndex('IMAGE'));
            // 解析图片信息字符串为正确的数组格式，使用JSON.parse去除多余的引号等字符，使其变为真正的图片路径字符串数组
            const parsedImageArray = JSON.parse(imageStr) as string[];
            parsedImageArray.forEach((imgPath) => {
              (temp.image as string[]).push(imgPath);
            });
            photoModels.push(temp);
          }
          resultSet.close();
          return photoModels;
        }
      } catch (error) {
        console.error(`查询图片信息出现异常，错误信息: ${error}`);
        // 可以根据实际需求进一步处理错误，比如返回null表示查询失败等
        return null;
      }
    }
    return null;
  }

}

//导出testUtil方法
let testUtil: TestUtil=new TestUtil()
export {testUtil}