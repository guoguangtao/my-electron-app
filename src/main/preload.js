const { contextBridge, ipcRenderer } = require('electron');

// 安全地暴露方法
contextBridge.exposeInMainWorld('electronAPI', {
    init: () => ipcRenderer.invoke('init'),
    cast: () => ipcRenderer.invoke('cast'),
    canSupportChangeAudioOutputDevice: () => ipcRenderer.invoke('canSupportChangeAudioOutputDevice'),
    canRecordScreen: () => ipcRenderer.invoke('canRecordScreen'),
});
