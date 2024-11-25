//
//  LBMacCastHandler.m
//  MacDemo
//
//  Created by guogt on 2024/11/19.
//

#import "LBMacCastHandler.h"
#import "AOCOutputSwitcher.h"
#import "HPSystemAuthorize.h"
#import <AVFoundation/AVFoundation.h>

@implementation LBMacCastHandler

static NSString *originalOutputDeviceName = nil;
static NSString *lbChangeOutputDeviceName = nil;

#pragma mark - Public

/// 判断当前设备是否支持改变音频输出设备
+ (BOOL)canSupportChangeAudioOutputDevice {
    
    NSString *outputDeviceName = [self p_getOutputDeviceName];
    if (outputDeviceName && [outputDeviceName isKindOfClass:[NSString class]] && outputDeviceName.length > 0) {
        return true;
    }
    
    return false;
}

/// 改变音频输出设备
+ (BOOL)changeAudioOutputDevice {
    
    NSString *originalOutputDeviceNameString = [AOCOutputSwitcher currentlySelectedOutputDeviceName];
    NSArray *outputDeviceNames = [AOCOutputSwitcher outputDeviceNames];
    NSString *outputDeviceName = [self p_getOutputDeviceName];
    if (outputDeviceName && [outputDeviceName isKindOfClass:[NSString class]] && outputDeviceName.length > 0) {
        // 选择可用的音频输出设备
        [AOCOutputSwitcher setDeviceByName:outputDeviceName];
        lbChangeOutputDeviceName = outputDeviceName;
        if ([outputDeviceName isEqualToString:originalOutputDeviceNameString]) {
            //设定的音频输出设备与现在的设备一致，投屏结束时应恢复为内置麦克风等
            for (NSString *tmpOutputDeviceName in outputDeviceNames) {
                if ([tmpOutputDeviceName rangeOfString:@"内建"].length || [tmpOutputDeviceName rangeOfString:@"Built-in"].length) {//内建 Built-in Output
                    //投屏结束时应恢复为内置麦克风等
                    originalOutputDeviceName = tmpOutputDeviceName;
                }
            }
        } else {
            //设定的音频输出设备与现在不一样
            originalOutputDeviceName = originalOutputDeviceNameString;
        }
        return true;
    }
    
    return false;
}

/// 恢复之前音频输出设备
+ (BOOL)restoreAudioOutputDevice {
    
    if (originalOutputDeviceName && [originalOutputDeviceName isKindOfClass:[NSString class]] && originalOutputDeviceName.length) {
        [AOCOutputSwitcher setDeviceByName:originalOutputDeviceName];
        originalOutputDeviceName = nil;
        return true;
    }
    
    return false;
}

/**
 是否能录制屏幕
 */
+ (BOOL)canRecordScreen {
  
  return [HPSystemAuthorize canRecordScreen];
}

/**
是否能录制屏幕新方式
*/
+ (BOOL)canRecordScreenNew {
  
  return [HPSystemAuthorize canRecordScreenNew];
}

/**
 打开系统设置录制屏幕授权
*/
+ (BOOL)openSystemSettingRecordScreenAuthorize {
  
  return [HPSystemAuthorize openSystemSettingRecordScreenAuthorize];
}

/**
 是否能录制系统声音
*/
+ (BOOL)canRecordAudio {
  
  return [HPSystemAuthorize canRecordAudio];
}

/**
 打开系统设置录制声音授权
*/
+ (BOOL)openSystemSettingRecordAudioAuthorize {
  
  return [HPSystemAuthorize openSystemSettingRecordAudioAuthorize];
}



#pragma mark - Private

/// 获取当前音频设备是否存在 cast audio
+ (NSString *)p_getOutputDeviceName {
    
    NSArray *outputDeviceNames = [AOCOutputSwitcher outputDeviceNames];
    NSArray *devices = [AVCaptureDevice devices];
    NSString *outputDeviceName = nil;
    for (AVCaptureDevice *captureDevice in devices) {
        NSLog(@"captureDevice %@",captureDevice);
        for (NSString *tmpOutputDeviceName in outputDeviceNames) {
            if ([captureDevice.localizedName isEqualToString:tmpOutputDeviceName]) {
                if (outputDeviceName == nil  && (![outputDeviceName containsString:@"UI Sounds"])) {
                    outputDeviceName = tmpOutputDeviceName;
                }
                if ([tmpOutputDeviceName isEqualToString:@"Cast Audio"]){
                    outputDeviceName = tmpOutputDeviceName;
                }
            }
        }
    }
    
    return outputDeviceName;
}

@end
