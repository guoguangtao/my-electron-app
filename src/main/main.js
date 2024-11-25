const { app, BrowserWindow, ipcMain } = require('electron');
const path = require('path');
const addon = require(path.resolve(__dirname, '../../build/Release/addon.node'));

let mainWindow;

app.on('ready', () => {
    mainWindow = new BrowserWindow({
        webPreferences: {
            preload: path.join(__dirname, './preload.js'), // 使用预加载脚本
            contextIsolation: true, // 启用上下文隔离
            nodeIntegration: false, // 禁用 Node.js 集成
        },
    });
    mainWindow.loadFile(path.join(__dirname, '../ui/index.html'));

    ipcMain.handle('init', async () => {
        let ret = addon.init();
        console.log('主进程调用 init 方法 : ' + ret);
        return ret;
    });

    ipcMain.handle('cast', async () => {
        return new Promise((resolve) => {
            addon.cast((result) => {
                console.log("主进程调用 cast 方法 : ", result);
                resolve(result);
            });
        });
    });

    ipcMain.handle('canSupportChangeAudioOutputDevice', async () => {
        let ret = addon.canSupportChangeAudioOutputDevice();
        console.log('主进程调用 canSupportChangeAudioOutputDevice 方法 : ' + ret);
        return ret;
    });

    ipcMain.handle('canRecordScreen', async () => {
        let ret = addon.canRecordScreen();
        console.log('主进程调用 canRecordScreen 方法 : ' + ret);
        return ret;
    });

    console.log('主进程任务执行完毕');
});
