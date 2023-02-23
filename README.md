# PoorEngine
基于Metal的小引擎

### 开发清单

- [x] TBDR
  - [x] 修复世界坐标
  - [ ] 阴影不遮挡高光
  - [ ] 提高阴影精度

- [ ] 材质逻辑
  - [x] 材质参数
  - [x] 贴图加载（贴图的Gamma矫正、贴图和参数的同时使用）
  - [ ] 材质编辑器
- [ ] 场景管理
  - [ ] usd/xml

- [ ] 更好的PBR
  - [ ] Stencil Light Pass

- [ ] 模型切换
- [x] Compute Shader
- [ ] Tile Base Culling Lighting
- [x] Inspector Menu
- [ ] 管线配置
- [x] Debug View
- [ ] Shadow map
- [ ] SSSR
- [ ] SPH流体
- [ ] Terrain
  - [x] 根据相机位置曲面细分
  - [x] 地表着色
  - [ ] 贴图融合（RVT）
- [ ] 截图
- [ ] 帧率显示
- [ ] 抗锯齿


### 材质

#### MTL文件

[MTL 意义](http://paulbourke.net/dataformats/mtl/)

### 贴图

使用Asset Catalog加载贴图，贴图类型应该为AR and Textures/New Texture Set，并将Interpretation设为Data，以防止伽马矫正导致过黑
