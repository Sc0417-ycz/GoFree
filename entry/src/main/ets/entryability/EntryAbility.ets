import UIAbility from '@ohos.app.ability.UIAbility';
import hilog from '@ohos.hilog';
import window from '@ohos.window';
import {testUtil} from '../utils/TestUtil';
import Want from '@ohos.app.ability.Want';
import AbilityConstant from '@ohos.app.ability.AbilityConstant';
import PreferencesUtil from '../utils/PreferencesUtil';



export default class EntryAbility extends UIAbility {

  async onCreate(want:Want, launchParam:AbilityConstant.LaunchParam){

    //加载Preferences
    await PreferencesUtil.loadPreference(this.context,"MyPreferences")
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');

  }

  onDestroy():void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage) {

    //加载数据库
    testUtil.initTestDB(this.context,"USER","MYPROVINCE","MYCITY","MYSTRATEGY","STRATEGY_LIKES","MYPHOTO","STRATEGY_FAVORITES")


    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/login', (err, data) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content. Data: %{public}s', JSON.stringify(data) ?? '');
    });
  }

  onWindowStageDestroy() {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground() {
    // Ability has brought to foreground
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground() {
    // Ability has back to background
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }
}




