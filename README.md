## 工程配置

### Electron 环境配置

```
npm install --save-dev electron
```

### 编译 addon.node 文件

```
node-gyp clean
node-gyp configure
node-gyp build
```
如果没有安装 node-gyp，需要执行

```
npm install node-gyp --save-dev
或者
yarn add node-gyp --dev
```

### 运行工程

```
npm start
```