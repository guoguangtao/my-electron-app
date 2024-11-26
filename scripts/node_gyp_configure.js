const { execSync } = require('child_process');
const path = require('path');
// 如果 遇到 Error: Cannot find module 'minimist'，这意味着你尚未安装 minimist 库，需要安装 minimist `npm install minimist --save-dev`
const minimist = require('minimist');

// 解析命令行参数
const args = minimist(process.argv.slice(2));

// 获取命令参数，默认为 'dev'
const command = args._[0] || 'dev';

// 获取当前环境变量，默认为 'development'（用于调试模式）
const buildType = process.env.NODE_ENV === 'production' ? 'Release' : 'Debug';

// 设置 node-gyp 的构建命令
const configureCommand = `node-gyp configure --${buildType.toLowerCase()}`;

// 根据传入的命令执行不同的操作
if (command === 'rebuild') {
  console.log('Running: node-gyp configure and build');
  
  // 执行 node-gyp configure
  execSync(configureCommand, { stdio: 'inherit' });

  // 执行 node-gyp rebuild
  execSync('node-gyp build', { stdio: 'inherit' });
} else if (command === 'dev') {
  console.log('Running: node-gyp build and electron .');
  
  // 执行 node-gyp build
  execSync('node-gyp build', { stdio: 'inherit' });
  
  // 启动 electron
  execSync('electron .', { stdio: 'inherit' });
} else if (command == 'release') {
  console.log('Running: node-gyp clean, configure --release, build and production electron .');

  // 执行 node-gyp clean
  execSync('node-gyp clean', { stdio: 'inherit' });

  // 执行 node-gyp clean
  execSync('node-gyp configure --release', { stdio: 'inherit' });
  
  // 执行 node-gyp build
  execSync('node-gyp build', { stdio: 'inherit' });
  
  // 启动 electron
  execSync('NODE_ENV=production electron .', { stdio: 'inherit' });
} else {
  console.log(`Running: ${configureCommand}`);

  console.log('Running: node-gyp clean, configure, and build');
  
  // 执行 node-gyp clean
  execSync('node-gyp clean', { stdio: 'inherit' });

  // 执行 node-gyp configure
  execSync(configureCommand, { stdio: 'inherit' });

  // 执行 node-gyp build
  execSync('node-gyp build', { stdio: 'inherit' });
}
