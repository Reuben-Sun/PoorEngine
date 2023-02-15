# PoorEngine
基于Metal的小引擎

### 开发清单

- [x] TBDR
  - [x] 修复世界坐标
  - [ ] 阴影不遮挡高光
  - [ ] 提高阴影精度

- [ ] 材质逻辑
  - [ ] 材质参数
  - [ ] 贴图加载（贴图的Gamma矫正、贴图和参数的同时使用）
- [ ] usd场景管理
- [ ] 更好的PBR
- [ ] 模型切换
- [ ] Compute Shader
- [ ] Tile Base Culling Lighting
- [ ] Inspector Menu
- [ ] 管线配置
- [ ] Debug View
- [ ] Shadow map
- [ ] SSSR
- [ ] SPH流体

### 材质

#### MTL文件

### 贴图

使用Asset Catalog加载贴图，贴图类型应该为AR and Textures/New Texture Set，并将Interpretation设为Data，以防止伽马矫正导致过黑
