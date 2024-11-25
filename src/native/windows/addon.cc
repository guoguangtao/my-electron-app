#include <napi.h>
#include <windows.h>
#include <string>
#include <thread>

// 模拟网络请求
std::string performNetworkRequest() {
    Sleep(2000); // 模拟2秒网络延迟
    return "Windows cast result";
}

void cast(const Napi::CallbackInfo& info) {
    Napi::Env env = info.Env();
    auto callback = info[0].As<Napi::Function>();

    // 异步处理
    std::thread([callback, env]() {
        std::string result = performNetworkRequest();
        callback.Call(env.Global(), { Napi::String::New(env, result) });
    }).detach();
}

Napi::Value init(const Napi::CallbackInfo& info) {
    Napi::Env env = info.Env();
    return Napi::String::New(env, "Windows init completed");
}

Napi::Object Init(Napi::Env env, Napi::Object exports) {
    exports.Set("cast", Napi::Function::New(env, cast));
    exports.Set("init", Napi::Function::New(env, init));
    return exports;
}

NODE_API_MODULE(addon, Init)
