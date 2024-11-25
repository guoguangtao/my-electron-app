#import <Foundation/Foundation.h>
#import <napi.h>
#import "LBMacCastHandler.h"

// 模拟网络请求
void simulateNetworkRequest(void (^completion)(NSString *)) {

  NSLog(@"开始模拟网络请求");
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"模拟网络请求完成");
        if (completion) {
          completion(@"OC 使用 GCD 延迟 2s 返回结果");
        }
    });
}

void cast(const Napi::CallbackInfo &info) {
  NSLog(@"调用 cast 方法");

  Napi::Env env = info.Env();
  Napi::Function callback = info[0].As<Napi::Function>();

  // 创建一个 tsfn 用于线程间通信
  auto tsfn = Napi::ThreadSafeFunction::New(
      env,                                  // Napi 环境
      callback,                             // JS 回调函数
      "Network Request Callback",          // 资源名称
      0,                                   // 队列限制（0 = 不限制）
      1                                    // 初始化线程数
  );

  simulateNetworkRequest(^(NSString *result) {
    tsfn.BlockingCall([result copy], [](Napi::Env env, Napi::Function jsCallback, NSString *data) {
      jsCallback.Call({Napi::String::New(env, [data UTF8String])});
      [data release];  // 内存管理
    });

    // 在后台任务完成后释放 tsfn
    tsfn.Release();
  });

  // 无需返回值
}

Napi::Value canSupportChangeAudioOutputDevice(const Napi::CallbackInfo &info) {
  NSLog(@"调用 canSupportChangeAudioOutputDevice 方法");
  BOOL result = [LBMacCastHandler canSupportChangeAudioOutputDevice];
  return Napi::Boolean::New(info.Env(), result);
}

Napi::Value canRecordScreen(const Napi::CallbackInfo &info) {
  NSLog(@"调用 canRecordScreen 方法");
  BOOL result = [LBMacCastHandler canRecordScreen];
  return Napi::Boolean::New(info.Env(), result);
}

Napi::Value init(const Napi::CallbackInfo &info) {
  NSLog(@"调用 init 方法");
  Napi::Env env = info.Env();
  return Napi::String::New(env, "macOS init completed");
}

Napi::Object Init(Napi::Env env, Napi::Object exports) {
  exports.Set("cast", Napi::Function::New(env, cast));
  exports.Set("init", Napi::Function::New(env, init));
  exports.Set("canSupportChangeAudioOutputDevice", Napi::Function::New(env, canSupportChangeAudioOutputDevice));
  exports.Set("canRecordScreen", Napi::Function::New(env, canRecordScreen));
  return exports;
}

NODE_API_MODULE(addon, Init)
