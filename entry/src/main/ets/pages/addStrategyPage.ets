import relationalStore from '@ohos.data.relationalStore'
import router from '@ohos.router'
import { testUtil } from '../utils/TestUtil'
import picker from '@ohos.file.picker'

interface ParamsObj {
  cityName: string;
  user_id: string;
  username: string;
}

@CustomDialog
struct ConfirmDateDialog {

  @Consume myDate:string
  private selectedDate: Date = new Date()

  controller: CustomDialogController = new CustomDialogController({
    builder: ConfirmDateDialog()
  });


  build() {
    Column() {
        // 日期选择器弹窗
      DatePicker({
        start: new Date('1970-1-1'),
        end: new Date('2100-1-1'),
        selected: this.selectedDate
      })
        .lunar(false)
        .onChange((value: DatePickerResult) => {

          this.selectedDate.setFullYear(value.year, value.month, value.day)
          console.info('select current date is: ' + JSON.stringify(this.selectedDate))
        })
        .margin({bottom:30})
        .width("100%")



      Text('是否确认您的攻略适用日期').fontSize(20).textAlign(TextAlign.Center).padding(20)
      Row({space:20}) {
        Button('确认').width(100)
          .onClick(() => {
            this.myDate = this.selectedDate.toISOString().split('T')[0]
            this.controller.close()
          }).margin({ top: 15,bottom:15 })
        Button('取消').width(100)
          .onClick(() => {
            this.controller.close()
        }).margin({ top: 15,bottom:15 })
      }.width("100%").justifyContent(FlexAlign.Center)
    }
  }
}


@Entry
@Component
struct addStrategyPage {

  @State user_id: string = '';
  @State myId: number = 0;  //攻略ID输入
  @State myStrategyName: string = '';
  @State myName: string = '';  //用户名即自己的用户名
  @State myContent: string = '';

  @State cityName: string = '';
  @State username: string = '';

  @State changeStrategyName: string = '';
  @State changeContent: string = '';
  @State changeImage: string = '';

  // 记录遮罩层透明度，初始为0表示隐藏
  @State maskOpacity: number = 0;
  // 记录遮罩层的层级，初始为 -1表示在底层（不可见）
  @State maskIndex: number = -1;
  // 记录当前点击图片的索引，初始为 -1表示没有图片被点击
  @State currentSelectedIndex: number = -1;
  // 用于控制动画进度，取值范围0 - 1，0表示动画开始，1表示动画结束
  @State animationProgress: number = 0;
  // 存储图片资源的数组，确保存储的是可被Image组件渲染的图片url格式
  @Provide imageResources: string[] = [];
  // 用于标识添加图片按钮是否显示，初始为true表示显示
  @State isAddButtonVisible: boolean = true;

  @State isDeleteAreaVisible: boolean =false;


  @State offsetX: number = 0;
  @State offsetY: number = 0;
  @State count: number = 0;
  @State positionX: number = 0;
  @State positionY: number = 0;

  // 新增：记录拖动开始时的图片索引
  @State draggingIndex: number = -1;
  // 新增：记录拖动图片的初始位置
  @State originalIndex: number = -1;

  @State deleteFc:boolean = false

  @State changeFc:boolean = false


  @Provide myDate: string = ''


  controller: CustomDialogController = new CustomDialogController({
    builder: ConfirmDateDialog()
  });

  aboutToAppear(): void {
    const params = router.getParams() as ParamsObj
    this.cityName = params.cityName
    this.user_id = params.user_id
    this.username = params.username
    console.log('我的攻略页传递过来的数据', JSON.stringify(router.getParams()))
  }

  insertStrategy = () => {
    let strategy_name = this.myStrategyName
    let author_name = this.myName
    let date = this.myDate
    let content = this.myContent
    let image_path = this.imageResources
    let cityName = this.cityName
    let username = this.username
    testUtil.insertStrategyData("MYSTRATEGY", strategy_name, author_name, date, content, image_path, cityName, username)
  }

  build() {
    Column() {
      Row() {
        Image($r('app.media.left1'))
          .width(30)
          .fillColor(Color.Grey)
          .onClick(() => {
            router.replaceUrl({
              url: 'pages/myStrategy',
              params: { cityName: this.cityName, user_id: this.user_id, username: this.username }
            })
            router.RouterMode.Single
          })
        Text('编辑我的攻略').fontSize(18).fontWeight(500)
        Image($r("app.media.helpone"))
          .fillColor(Color.Grey)
          .width(30)
          .onClick(() => {
            AlertDialog.show({
              message: "此页可以帮助您快速添加您想添加的攻略信息并为你自动排版并排序；" +
              "  删除信息和修改信息的方式都是根据您攻略的题目名称来修改的，" +
              "例如：如果想删除攻略题目为：大连的冬天，或者修改它的信息，" +
              "您只需要在输入攻略题目框中输入该题目即可完成删除或修改操作," +
              "完成您的操作后点击返回键即可看到您编辑完成的攻略信息"
            })
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

      // 根据当前点击图片的索引来显示对应大图以及遮罩效果，添加动画过渡，确保使用正确图片url格式
      if (this.currentSelectedIndex!== -1) {
        Column() {
          Image(this.imageResources[this.currentSelectedIndex])
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

      Column() {
        Row(){
          Image($r('app.media.delete')).width(25).onClick(() => this.deleteFc =!this.deleteFc);
          Text('添加攻略').fontSize(25).margin({ top: 10,bottom:5 }).fontWeight(600)
          Image($r('app.media.change')).width(25) .onClick(() => this.changeFc =!this.changeFc);
        }.width("100%").justifyContent(FlexAlign.SpaceBetween).padding({left:30,right:30})
        TextInput({ placeholder: '请输入要添加攻略的标题'})
          .backgroundColor(Color.White)
          .height(70)
          .placeholderFont({ size: 22, weight: 400 })
          .onChange((value: string) => {
            this.myStrategyName = value
          })

        TextInput({ placeholder: '请输入要添加攻略的作者名(您的用户名)', text: this.username })
          .onChange((value2: string) => {
            this.myName = value2
          })
          .visibility(Visibility.None)
          .backgroundColor(Color.White)

        TextInput({ placeholder: '请输入要添加攻略的适用日期',text:this.myDate })
          .onChange((value2: string) => {
            this.myDate = value2
          })
          .type(InputType.Number)
          .maxLength(10)
          .height(40)
          .placeholderFont({ size: 18, weight: 350 })
          .backgroundColor(Color.White)
          .onClick(() => {
            this.controller.open()
          });



        TextInput({ placeholder: '请输入要添加攻略的正文' })
          .onChange((value3: string) => {
            this.myContent = value3
          })
          .placeholderFont({ size: 18, weight: 400 })
          .height(50)
          .backgroundColor(Color.White)



        List({ space: 10 }) {
          if (this.imageResources.length === 0) {
            // 如果没有图片资源，先添加添加图片的svg图标
            ForEach([$r('app.media.add1')], (item: ResourceStr, index: number) => {
              ListItem() {
                Column() {
                  Image(item)
                    .width(40)
                    .height(40)
                    .onClick(() => {
                      this.addNewImage();
                    });
                }
                .width(120).height(120).backgroundColor("#ffe2dfdf").justifyContent(FlexAlign.Center);
              };
            });
          } else {
            ForEach(this.imageResources, (item: string, index: number) => {
              ListItem() {
                if (index === this.draggingIndex) {
                  Image(item)
                    .width(120)
                    .height(120)
                    .translate({ x: this.offsetX, y: this.offsetY, z: 0 })
                    .zIndex(999); // 提高zIndex确保拖动时始终可见
                } else {
                  Image(item)
                    .width(120)
                    .height(120)
                    .zIndex(99);
                }
              }
              .zIndex(99)
              .onClick(() => {
                // 记录当前点击图片的索引
                this.currentSelectedIndex = index;
                this.startShowAnimation();
              })
              //以下组合手势为顺序识别，当长按手势事件未正常触发时不会触发拖动手势事件
              .gesture(
                // 声明该组合手势的类型为Sequence类型
                GestureGroup(GestureMode.Sequence,
                  // 该组合手势第一个触发的手势为长按手势，且长按手势可多次响应
                  LongPressGesture({ repeat: true })
                    // 当长按手势识别成功，增加Text组件上显示的count次数
                    .onAction((event: GestureEvent) => {
                      if (index < this.imageResources.length) { // 确保不是svg图片对应的ListItem
                        this.draggingIndex = index;
                        this.originalIndex = index;
                        this.offsetX = 0;
                        this.offsetY = 0;
                        this.isDeleteAreaVisible = true; // 显示删除区域
                        console.info('图片长按开始');
                      }
                    })
                    .onActionEnd(() => {
                      if (this.draggingIndex === this.originalIndex) {
                        this.draggingIndex = -1;
                        this.originalIndex = -1;
                        this.offsetX = 0;
                        this.offsetY = 0;
                      }
                      console.info('图片长按结束');
                    }),
                  // 当长按之后进行拖动，PanGesture手势被触发
                  PanGesture()
                    .onActionStart(() => {
                      if (this.draggingIndex!== -1) {
                        console.info('拖动开始');
                      }
                    })
                      // 当该手势被触发时，根据回调获得拖动的距离，修改该组件的位移距离从而实现组件的移动
                    .onActionUpdate((event: GestureEvent) => {
                      if (this.draggingIndex!== -1) {
                        this.offsetX = event.offsetX;
                        this.offsetY = event.offsetY;
                        // 实时更新图片位置

                        // 查找可交换的目标图片索引
                        let targetIndex = this.findClosestIndex();
                        if (targetIndex!== -1 && targetIndex!== this.originalIndex) {

                        }
                        console.info('拖动更新');
                      }
                    })
                      // 修改 PanGesture 的 onActionEnd 回调，判断是否拖动到删除区域
                    .onActionEnd(() => {
                      if (this.draggingIndex!== -1) {
                        // 计算删除区域的位置和大小
                        const deleteAreaRect = {
                          x: 0,
                          y: 550,
                          width: 1228 / 3,
                          height: 140
                        };
                        const draggingImageRect = {
                          x: this.offsetX + (this.originalIndex * (120 + 10)),
                          y: this.offsetY,
                          width: 120,
                          height: 120
                        };

                        // 判断图片是否碰到删除区域
                        const isTouchingDeleteArea =!(
                          // 图片完全在删除区域左侧
                          draggingImageRect.x + draggingImageRect.width < deleteAreaRect.x ||
                          // 图片完全在删除区域右侧
                          draggingImageRect.x > deleteAreaRect.x + deleteAreaRect.width ||
                          // 图片完全在删除区域上方
                          draggingImageRect.y + draggingImageRect.height < deleteAreaRect.y ||
                          // 图片完全在删除区域下方
                          draggingImageRect.y > deleteAreaRect.y + deleteAreaRect.height
                        );

                        if (isTouchingDeleteArea) {
                          // 进入删除区域，删除图片
                          this.imageResources.splice(this.draggingIndex, 1);
                          // 判断是否显示添加按钮
                          if (this.imageResources.length < 5) {
                            this.isAddButtonVisible = true;
                          }
                        } else {
                          let targetIndex = this.findClosestIndex();
                          if (targetIndex!== -1 && targetIndex!== this.originalIndex) {
                            this.swapImages(this.draggingIndex, targetIndex);
                          }
                        }
                        this.draggingIndex = -1;
                        this.originalIndex = -1;
                        this.offsetX = 0;
                        this.offsetY = 0;
                      }
                      this.isDeleteAreaVisible = false;
                    })
                )
              )

            })
            // 单独判断是否显示添加按钮的格子（根据是否达到5张图片来决定）
            if (this.isAddButtonVisible) {
              ListItem() {
                Column() {
                  Image($r('app.media.add1'))
                    .width(30)
                    .height(30)
                    .onClick(() => {
                      this.addNewImage();
                    });
                }
                .width(120).height(120).backgroundColor("#ffe2dfdf").justifyContent(FlexAlign.Center);
              };
            }
          }
        }
        .listDirection(Axis.Horizontal)
        .height(120)
        .margin({ top: 8,bottom:3 });

        Button('发布攻略')
          .fontSize(20)
          .width('80%')
          .margin({ bottom: 15 })
          .onClick(() => {
            this.insertStrategy()
            AlertDialog.show({
              message: '添加攻略成功请返回查看'
            })
          })
          .margin({ top: 5 })

        if (this.deleteFc) {
          Text('删除攻略')
            .fontSize(25)
            .margin({ top: 20, bottom: 10 })
            .fontWeight(600);
          TextInput({ placeholder: "请输入要删除的攻略标题：" })
            .onChange((value4: string) => {
              this.myStrategyName = value4
            });
          Button('删除')
            .onClick(() => {
              testUtil.deleteByStrategyNameAndUsername("MYSTRATEGY", this.myStrategyName, this.user_id);
              AlertDialog.show({
                message: '删除攻略成功请返回查看'
              });
            })
            .width('50%')
            .margin({ top: 5 });
        }

        if (this.changeFc) {
          Text('修改攻略')
            .fontSize(25)
            .margin({ top: 20, bottom: 10 })
            .fontWeight(600);
          TextInput({ placeholder: "请输入你想修改的攻略标题：" })
            .onChange((value5: string) => {
              this.myStrategyName = value5
            });
          TextInput({ placeholder: "请输入修改后攻略的标题：" })
            .onChange((value6: string) => {
              this.changeStrategyName = value6
            });
          TextInput({ placeholder: "请输入修改攻略的正文：" })
            .onChange((value8: string) => {
              this.changeContent = value8
            });
          Button('修改')
            .onClick(() => {
              const updateContent: relationalStore.ValuesBucket = {
                STRATEGY_NAME: this.changeStrategyName,
                CONTENT: this.changeContent,
                IMAGE_PATH: this.changeImage
              };
              testUtil.updateByStrategyNameAndUsername("MYSTRATEGY", this.myStrategyName, this.user_id, updateContent);
              AlertDialog.show({
                message: '修改攻略信息成功请返回查看'
              });
            })
            .width('50%')
            .margin({ top: 5, bottom: 10 });
        }

        if (this.isDeleteAreaVisible) {
          Row() {
            Column({ space: 4 }) {
              Image($r('app.media.delete')).width(30)
              Text('拖动到此处删除').fontSize(15)
            }
          }.position({x:0,y:700}).width(1228/3).height(70).justifyContent(FlexAlign.Center).backgroundColor('#ff6cb1e0')
        }
      }
    }
  }

  // 新增：找到最近的图片索引
  findClosestIndex(): number {
    let closestIndex = -1;
    const itemWidth = 120;
    const gap = 10;
    const totalWidth = (itemWidth + gap) * this.imageResources.length - gap;
    const draggingX = this.offsetX + (this.originalIndex * (itemWidth + gap));
    const threshold = 150; // 可根据实际情况调整

    for (let i = 0; i < this.imageResources.length; i++) {
      if (i === this.originalIndex) {
        continue;
      }
      const targetX = i * (itemWidth + gap);
      let dx = Math.abs(draggingX - targetX);
      if (dx < threshold) {
        closestIndex = i;
        break;
      }
    }

    return closestIndex;
  }

  // 新增：交换图片位置
  swapImages(index1: number, index2: number) {
    if (index1!== -1 && index2!== -1) {
      const temp = this.imageResources[index1];
      this.imageResources[index1] = this.imageResources[index2];
      this.imageResources[index2] = temp;
      // 这里可以根据需要添加重新布局的逻辑，如果交换图片后需要重新调整布局
    }
  }

  addNewImage = async () => {
    try {
      let PhotoSelectOptions = new picker.PhotoSelectOptions();
      PhotoSelectOptions.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE;
      // 根据当前已有的图片数量计算还能添加的图片数量
      const remainingSlots = Math.max(5 - this.imageResources.length, 0);
      PhotoSelectOptions.maxSelectNumber = remainingSlots;

      let photoPicker = new picker.PhotoViewPicker();
      photoPicker.select(PhotoSelectOptions).then((PhotoSelectResult) => {
        // 将新选择的图片路径合并到已有的imageResources数组中
        this.imageResources = [...this.imageResources,...PhotoSelectResult.photoUris];
        console.info('图库获取到的图片路径是: ' + JSON.stringify(PhotoSelectResult));
        // 判断图片数量是否达到9张，若达到则隐藏添加图片按钮
        if (this.imageResources.length >= 5) {
          this.isAddButtonVisible = false;
        }
        // 重新赋值触发组件重新渲染，更新页面显示
        this.imageResources = [...this.imageResources];
      }).catch((err) => {
        console.error(`PhotoViewPicker.select failed with. Code: ${err.code}, message: ${err.message}`);
      });
    } catch (err) {
      console.error(`PhotoViewPicker.failed with. Code: ${err.code}, message: ${err.message}`);
    }
  }

  // 开始显示大图和遮罩层的动画
  startShowAnimation() {
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

    this.maskOpacity = this.calculateOpacity();
    this.maskIndex = this.calculateZIndex();
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