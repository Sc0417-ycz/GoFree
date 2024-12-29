import router from '@ohos.router';
import picker from '@ohos.file.picker';
import { testUtil } from '../utils/TestUtil';
import emitter from '@ohos.events.emitter';

interface ParamsObj {
  cityName: string;
  user_id: string;
  username: string;
}

@Component
@CustomDialog
struct Confirm {
  @Consume textContent: string;
  @Consume imageResources: string[];

  @State cityName: string = '';
  @State username: string = '';
  @State user_id: string = '';

  aboutToAppear(): void {
    const params = router.getParams() as ParamsObj;
    this.cityName = params.cityName;
    this.user_id = params.user_id;
    this.username = params.username;
    console.log('(弹窗)我的图片页传递过来的数据', JSON.stringify(router.getParams()));
    console.log('父组件传过来的文本内容是：' + this.textContent);
    console.log('父组件传过来的图片内容是：', JSON.stringify(this.imageResources));
  }

  // 修改insertPhoto方法，仅在点击确认按钮后调用插入数据逻辑，先收集当前页面相关数据
  insertPhoto = async () => {
    const textContent = this.textContent;
    const cityName = this.cityName;
    const username = this.username;
    const imageResources = this.imageResources;
    await testUtil.insertPhotoData("MYPHOTO", imageResources, textContent, cityName, username);
  }

  controller: CustomDialogController = new CustomDialogController({
    builder: Confirm()
  });

  build() {
    Row({ space: 10 }) {
      Button('确认').width(100)
        .onClick(() => {
          this.insertPhoto().then(() => {
            this.controller.close();
            AlertDialog.show({
             message:'添加图片成功请返回查看'
           })
          }).catch((error) => {
            console.error('插入图片时出现错误:', error);
          });
        });

      Button('取消').width(100)
        .onClick(() => {
          this.controller.close();
        });
    }.height(100).justifyContent(FlexAlign.Center);
  }
}

@Entry
@Component
struct AddPhotoPage {
  controller: CustomDialogController = new CustomDialogController({
    builder: Confirm()
  });

  @Provide textContent: string = '';
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

  @State cityName: string = '';
  @State username: string = '';
  @State user_id: string = '';

  @State offsetX: number = 0;
  @State offsetY: number = 0;
  @State count: number = 0;
  @State positionX: number = 0;
  @State positionY: number = 0;

  // 新增：记录拖动开始时的图片索引
  @State draggingIndex: number = -1;
  // 新增：记录拖动图片的初始位置
  @State originalIndex: number = -1;
  @State isDeleteAreaVisible: boolean = false;

  aboutToAppear(): void {
    const params = router.getParams() as ParamsObj;
    this.cityName = params.cityName;
    this.user_id = params.user_id;
    this.username = params.username;
    console.log('我的图片页传递过来的数据', JSON.stringify(router.getParams()));
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Image($r('app.media.left1'))
            .width(30)
            .fillColor(Color.Grey)
            .onClick(() => {
              const event = { eventId: 2 };
              console.log('添加图片页发布订阅数据：' + JSON.stringify(event));
              emitter.emit(event)
              router.back()
              router.RouterMode.Single;
            });
          Text('编辑我的图片').fontSize(18).fontWeight(500);
          Text('发表').fontSize(15).fontWeight(500).padding(2)
            .border({
              width: 2,
              color: Color.Gray
            })
            .borderRadius(5)
            .onClick(() => {
              this.controller.open();
            });

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
          left: 10, right: 8
        });

        // 输入框相关布局，与原代码一致，此处省略部分重复代码注释
        Row() {
          TextInput({ placeholder: '这一刻的想法...' })
            .placeholderFont({ size: 17 })
            .margin({ top: 30, left: 15 })
            .backgroundColor(Color.White)
            .onChange((value: string) => {
              this.textContent = value;
            });
        }.width('100%');

        // 图片展示网格，确保使用正确的图片url格式渲染图片
        Grid() {
          if (this.imageResources.length === 0) {
            // 如果没有图片资源，先添加添加图片的svg图标
            ForEach([$r('app.media.add1')], (item: ResourceStr, index: number) => {
              GridItem() {
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
              GridItem() {
                if (index === this.draggingIndex) {
                  Image(item)
                    .width(120)
                    .height(120)
                    .translate({ x: this.offsetX, y: this.offsetY, z: 0 });
                } else {
                  Image(item)
                    .width(120)
                    .height(120);
                }
              }
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
                      this.draggingIndex = index;
                      this.originalIndex = index;
                      this.offsetX = 0;
                      this.offsetY = 0;
                      this.isDeleteAreaVisible = true; // 显示删除区域
                      console.info('图片长按开始');
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
                        console.info('拖动更新');
                      }
                    })
                      // 修改 PanGesture 的 onActionEnd 回调，判断是否拖动到删除区域
                    .onActionEnd(() => {
                      if (this.draggingIndex!== -1) {
                        // 计算删除区域的位置和大小
                        const deleteAreaRect = {
                          x: 0,
                          y: 600,
                          width: 1228 / 3,
                          height: 140
                        };
                        const draggingImageRect = {
                          x: this.offsetX + (this.originalIndex % 3) * (120 + 10),
                          y: this.offsetY + Math.floor(this.originalIndex / 3) * (120 + 10),
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
                          if (this.imageResources.length < 9) {
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
            // 单独判断是否显示添加按钮的格子（根据是否达到9张图片来决定）
            if (this.isAddButtonVisible) {
              GridItem() {
                Column() {
                  Image($r('app.media.add1'))
                    .width(40)
                    .height(40)
                    .onClick(() => {
                      this.addNewImage();
                    });
                }
                .width(120).height(120).backgroundColor("#ffe2dfdf").justifyContent(FlexAlign.Center);
              };
            }
          }
        }
        .columnsGap(10)
        .rowsGap(10)
        .layoutWeight(1)
        .margin({ top: 25 });


        if (this.isDeleteAreaVisible) {
          Row() {
            Column({ space: 4 }) {
              Image($r('app.media.delete')).width(30)
              Text('拖动到此处删除').fontSize(15)
            }
          }.position({x:0,y:750}).width(1228/3).height(70).justifyContent(FlexAlign.Center).backgroundColor('#ff6cb1e0')
        }
      }
      .width("100%")
      .height("100%");

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
    }
  }


  addNewImage = async () => {
    try {
      let PhotoSelectOptions = new picker.PhotoSelectOptions();
      PhotoSelectOptions.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE;
      // 根据当前已有的图片数量计算还能添加的图片数量
      const remainingSlots = Math.max(9 - this.imageResources.length, 0);
      PhotoSelectOptions.maxSelectNumber = remainingSlots;

      let photoPicker = new picker.PhotoViewPicker();
      photoPicker.select(PhotoSelectOptions).then((PhotoSelectResult) => {
        // 将新选择的图片路径合并到已有的imageResources数组中
        this.imageResources = [...this.imageResources,...PhotoSelectResult.photoUris];
        console.info('图库获取到的图片路径是: ' + JSON.stringify(PhotoSelectResult));
        // 判断图片数量是否达到9张，若达到则隐藏添加图片按钮
        if (this.imageResources.length >= 9) {
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

  // 新增：找到最近的图片索引
  findClosestIndex(): number {
    let closestIndex = -1;
    let minDistance = Infinity;
    const gridItemWidth = 120;
    const gridItemHeight = 120;
    const columnsGap = 10;
    const rowsGap = 10;
    const startX = 0; // 假设Grid起始位置在X轴为0
    const startY = 0; // 假设Grid起始位置在Y轴为0

    const draggingX = startX + (this.originalIndex % 3) * (gridItemWidth + columnsGap);
    const draggingY = startY + Math.floor(this.originalIndex / 3) * (gridItemHeight + rowsGap);

    for (let i = 0; i < this.imageResources.length; i++) {
      const targetX = startX + (i % 3) * (gridItemWidth + columnsGap);
      const targetY = startY + Math.floor(i / 3) * (gridItemHeight + rowsGap);
      let dx = Math.abs(this.offsetX + draggingX - targetX);
      let dy = Math.abs(this.offsetY + draggingY - targetY);
      let distance = Math.sqrt(dx * dx + dy * dy);
      if (distance < minDistance) {
        minDistance = distance;
        closestIndex = i;
      }
    }

    // 检查是否拖动到了没有图片的位置
    const totalSlots = Math.min(9, this.imageResources.length + (this.isAddButtonVisible? 1 : 0));
    const targetColumn = Math.floor((this.offsetX + draggingX) / (gridItemWidth + columnsGap));
    const targetRow = Math.floor((this.offsetY + draggingY) / (gridItemHeight + rowsGap));
    const targetIndex = targetRow * 3 + targetColumn;
    if (targetIndex < 0 || targetIndex >= totalSlots || (targetIndex >= this.imageResources.length && this.isAddButtonVisible)) {
      closestIndex = -1;
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
}