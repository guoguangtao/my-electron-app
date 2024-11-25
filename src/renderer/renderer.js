async function init() {
    console.log('通知主进程调用 init 方法');
    const result = await window.electronAPI.init();
    console.log('init 方法调用结果 : ', result);
}

async function cast() {
    console.log('通知主进程调用 cast 方法');
    const result = await window.electronAPI.cast();
    console.log('投屏方法调用结果 : ', result);
}

async function canSupportChangeAudioOutputDevice() {
    console.log('通知主进程调用 canSupportChangeAudioOutputDevice 方法');
    const result = await window.electronAPI.canSupportChangeAudioOutputDevice();
    console.log('canSupportChangeAudioOutputDevice 调用结果 : ', result);
}

async function canRecordScreen() {
    console.log('通知主进程调用 canRecordScreen 方法');
    const result = await window.electronAPI.canRecordScreen();
    console.log('canRecordScreen 调用结果 : ', result);
}

// 确保 DOM 加载完成后添加事件监听器
window.addEventListener('DOMContentLoaded', () => {
    console.log('给按钮添加点击事件');
    document.getElementById('initBtn').addEventListener('click', init);
    document.getElementById('castBtn').addEventListener('click', cast);
    document.getElementById('canRecordScreen').addEventListener('click', canRecordScreen);
});
