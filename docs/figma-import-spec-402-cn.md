# Glug & Poop Figma 导入规范（402 宽）

最后更新：2026-05-14

本规范基于当前实现文件 `GlugPoop/GlugPoop/ContentView.swift` 整理，用于把现有 iOS UI 导入到 Figma。目标画面宽度统一为 `402`。

## 交付范围

- 目标画板宽度：`402`
- 推荐静态画板尺寸：
  - 首页：`402 x 874`
  - Dashboard：`402 x 874`
  - Calendar：`402 x 874`
  - Water Sheet：`402 x 600`
  - Drink Sheet：`402 x 620`
  - Food Sheet：`402 x 720`
  - Poop Sheet：`402 x 760`
- 推荐 Figma 页面：
  - `01 Foundations`
  - `02 Components`
  - `03 Home`
  - `04 Input Sheets`
  - `05 Dashboard`
  - `06 Calendar`

## 设计基础

### 颜色 Token

- `App/Black`: `#1C1C1E`
- `App/LightGray`: `#F2F2F7`
- `App/White`: `#FFFFFF`
- `Type/Water`: `#007AFF`
- `Type/Drink`: `#AF52DE`
- `Type/Food`: `#FF2D55`
- `Type/Poop`: `#FFCC00`
- `Vibe/Level1`: `#FF2D55`，透明度 `80%`
- `Vibe/Level2`: `#FFCC00`，透明度 `80%`
- `Vibe/Level3`: `#AF52DE`，透明度 `60%`
- `Vibe/Level4`: `#34C759`，透明度 `80%`
- `Vibe/Level5`: `#007AFF`，透明度 `80%`

### 便便颜色 Token

- `Poop/LightTan`: `#E4D7B4`
- `Poop/Yellow`: `#FFCC33`
- `Poop/Tan`: `#CFA766`
- `Poop/Coffee`: `#7B4308`
- `Poop/DarkBrown`: `#5A3217`
- `Poop/Green`: `#005A21`
- `Poop/Black`: `#000000`
- `Poop/Red`: `#C70000`

### 字体层级

- 首页主标题：`34 / Black / Rounded`
- 弹层标题：`26 / Black / Rounded`
- 页面分区标题：`20 / Bold / Rounded`
- 强调数值：`28 / Black / Rounded`
- 主按钮文字：`17 / Bold`
- 卡片标题：`17 / Bold`
- 小标签：`11-13 / Bold`
- 辅助文字：`12-17 / Medium or Semibold`

### 圆角与阴影

- 首页功能卡：`32`
- 底部弹层：`28`
- 水量面板：`24`
- Dashboard 大卡片：`28`
- 中型组件：`18-22`
- 小型控件：`12-16`
- 胶囊按钮：`100`
- 标准卡片阴影：黑色 `5%`，模糊 `10`，Y `10`
- 浮层 AI 卡片阴影：黑色 `8%`，模糊 `20`，Y `10`

## 402 宽布局规则

- 页面左右边距：`24`
- 主内容有效宽度：`354`
- 首页 2 列卡片间距：`20`
- 首页单张入口卡尺寸：`167 x 167`
- 双按钮底栏间距：`15`
- 双按钮单个宽度：`169.5`
- 弹层主堆叠间距：`16`
- Sheet 内部网格间距：`10`
- Calendar 日历左右边距：`16`
- Calendar 记录区左右边距：`24`

## 首页 Home

- 画板：`402 x 874`
- 背景：白底 + 极浅灰网格
- 顶部文案块：
  - 上边距：`50`
  - 标题：`VIBE CHECK`
  - 副标题：`Log your daily inputs & outputs.`
  - 标题间距：`5`
- 中部功能区：
  - `2 x 2` 网格
  - 卡片尺寸：`167 x 167`
  - 卡片 padding：`20`
  - 右上 emoji：`40`
  - 底部标题：`20 / Bold / Rounded`
- 卡片文案：
  - `WATER`
  - `DRINKS`
  - `FOOD`
  - `POOP`
- 底部操作区：
  - `Dashboard` 黑底白字
  - `Calendar` 浅灰底黑字
  - 高度约 `56`
  - 底部 padding：`40`

## 通用录入弹层外壳

- 统一宽度：`402`
- 白色背景
- 顶部标题上边距：`40`
- 主内容垂直间距：`16`
- 提交按钮高度：`56`
- 相机按钮：`50 x 50`
- 备注输入框高度：`50`
- 图片缩略图：`54 x 54`
- 图片缩略图圆角：`13`

### 元信息面板 Meta Panel

- 外层为浅灰容器
- 内部字段圆角：`16`
- 内部左右 padding：`14`
- 内部上下 padding：`12`
- 外层面板圆角：`22`

### 主 CTA

- 文案：`LOG IT` 或 `UPDATE IT`
- 黑底白字
- 圆角：`100`

## Water Log Sheet

- 画板：`402 x 600`
- 标题：`HYDRATE!`

### 快捷水量行

- 选项：
  - `100ml`
  - `300ml`
  - `500ml`
  - `750ml`
  - `1000ml`
- 高度：`38`
- 间距：`10`
- 选中态：Water 蓝
- 未选中：浅灰

### 水量波形面板

- 高度：`168`
- 圆角：`24`
- 左右 padding：`18`
- 上 padding：`18`
- 下 padding：`14`
- 顶部标签：
  - 左：`0ml`
  - 右：`1500ml`
- 中部主值：`28 / Black / Rounded`
- 中轴线：
  - 宽 `3`
  - 高 `68`
- 条形波纹贴底排列，越靠边越淡
- 背景是低透明度的蓝色横向渐变

## Drink Log Sheet

- 画板：`402 x 620`
- 标题：`CHOOSE POISON`

### 饮品网格

- 两列
- 间距：`10`
- 单元格高度：`50`
- 圆角：`16`
- 左侧 emoji + 右侧文字
- 文字：`15 / Bold`
- 选中态：Drink 紫
- 未选中：浅灰

### 选项

- `Coffee`
- `Boba`
- `Soda`
- `Matcha`
- `Wine`
- `Beer`

## Food Log Sheet

- 画板：`402 x 720`
- 标题：`FEED ME`

### 食物网格

- 两列
- 间距：`10`
- 单元格高度：`46`
- 圆角：`100`
- 文字：`15 / Bold`
- 选中态：Food 粉
- 未选中：浅灰

### 选项

- `Burger🍔`
- `Salad🥗`
- `Pizza🍕`
- `Sushi🍣`
- `Tacos🌮`
- `Ramen🍜`
- `Meat🥩`
- `Sweet🍩`

### 额外字段

- 元信息面板里需要包含 `Duration`

## Poop Log Sheet

- 画板：`402 x 760`
- 标题：`CAPTAIN'S LOG`

### 形状选择区

- 四列网格
- 间距：`10`
- 方形卡片
- 圆角：`16`
- 图像内边距：`8`
- 选中态底色：Poop 黄
- 未选中底色：浅灰

### 颜色选择区

- 标签：`COLOR`
- `4 x 2` 网格
- 间距：`10`
- 单元格高度：`52`
- 圆角：`14`
- 圆形色块：`26 x 26`
- 选中态：
  - 浅黄色背景，Poop 黄 `24%`
  - `2px` Poop 黄描边

### 图像资源

- `poop_1.png`
- `poop_2.png`
- `poop_3.png`
- `poop_4.png`
- `poop_5.png`
- `poop_6.png`
- `poop_7.png`
- `poop_8.png`

资源路径：

- `GlugPoop/GlugPoop/BristolStoolScale`

## Dashboard

- 画板：`402 x 874`
- 白底

### 顶部区域

- 左右边距：`24`
- 顶部 padding：`10`
- 返回按钮：
  - 圆形
  - 图标约 `20`
  - 内 padding：`14`
  - 浅灰填充
- 标题：
  - `TODAY!`
  - 副标题：`今天过得像个人样吗？`
- 分区标题：`TODAY'S LOGS`

### 日志大卡片

- 圆角：`28`
- 内边距：`16`
- 头部：
  - 左侧 emoji 在白色 `30%` 透明底圆片中
  - 标题 `17 / Bold`
  - 时间 `12 / Medium`
- 普通 detail pill：
  - 白底
  - 左右 padding：`15`
  - 上下 padding：`8`
- Poop detail pill：
  - 白底胶囊
  - 图片 `46 x 32`
  - 颜色点 `14 x 14`
- 可选图片：
  - 通栏
  - 高度 `150`
  - 圆角 `16`

### AI 浮层卡片

- 底部 padding：`40`
- 左右边距：`24`
- 使用模糊材质效果
- 圆角：`24`

## Calendar

- 画板：`402 x 874`

### 顶部区域

- 左右边距：`24`
- 顶部 padding：`10`
- 返回按钮样式同 Dashboard
- 中间月份切换器宽度：`120`
- 左右箭头与标题组间距：`20`
- 月份标题：`20 / Black / Rounded`

### 星期栏

- 左右边距：`16`
- 文案：`12 / Bold`

### 日期网格

- 七列
- 间距：`10`
- 左右边距：`16`
- 日期格：
  - 正方形
  - 圆角：`12`
  - 选中态：黑底白字
  - 有活跃度数据时：使用 Vibe 色
  - 无数据时：浅灰底
  - 文案：`17 / Bold / Rounded`

## Calendar Records Panel

### 头部

- 左右边距：`24`
- 标题：`RECORDS`
- 日期：`18 / Black / Rounded`
- 数量 badge：
  - `34 x 34`
  - 黑底白字
  - 圆形

### 新增按钮行

- 左右边距：`24`
- 间距：`10`
- 按钮高度：`46`
- 圆角：`14`
- 用各类型色的浅色透明版本做填充

### 当日记录区

- 双列卡片
- 间距：`14`
- 左右边距：`24`
- 底部 padding：`30`

## Calendar Record Card

- 双列自适应卡片
- 圆角：`18`
- 最小视觉高度约 `118`
- 背景使用类型色浅色版
- 左上角：类型 emoji
- 右上角：时间
- 中部：详情文本或便便图 + 色点
- 次级信息：
  - `duration`
  - `note`
- 可选图片缩略图：
  - `46 x 46`
  - 白色 `2px` 描边
  - 放在右下角

## 建议组件集

- `Quick Entry Card`
- `Primary Pill Button`
- `Secondary Pill Button`
- `Meta Panel`
- `Date Time Field`
- `Image Thumbnail`
- `Drink Option Pill`
- `Food Option Pill`
- `Poop Shape Tile`
- `Poop Color Tile`
- `Dashboard Log Card`
- `Calendar Day Cell`
- `Calendar Add Action`
- `Calendar Record Card`

## 推荐导入顺序

1. 先建 `01 Foundations`，录入颜色、字体、圆角、阴影 token。
2. 再建 `02 Components`，把通用按钮、卡片、Meta Panel、记录卡抽成组件。
3. 完成 `03 Home`，画板使用 `402 x 874`。
4. 在 `04 Input Sheets` 中按代码高度建立 4 个弹层。
5. 完成 `05 Dashboard`，复用大记录卡组件。
6. 完成 `06 Calendar`，最后补齐记录区和双列记录卡。

## 当前限制

本次会话没有暴露可执行的 Figma MCP 写入工具，所以我无法直接把这些画板写进你给的 Figma 文件。

目标文件仍然是：

- `https://www.figma.com/design/g9DbEKBWbtinQgMPtJtDkv/Untitled?node-id=0-1&t=XOSzcK45uL1Zt3l3-1`

一旦后续会话具备 `use_figma` / `search_design_system` 能力，这份规范可以直接按页落进该文件。
