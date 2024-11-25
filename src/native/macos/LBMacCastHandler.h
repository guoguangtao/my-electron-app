//
//  LBMacCastHandler.h
//  MacDemo
//
//  Created by guogt on 2024/11/19.
//

#import <Foundation/Foundation.h>

@interface LBMacCastHandler : NSObject

/// 判断当前设备是否支持改变音频输出设备
+ (BOOL)canSupportChangeAudioOutputDevice;

/// 改变音频输出设备
+ (BOOL)changeAudioOutputDevice;

/// 恢复之前音频输出设备
+ (BOOL)restoreAudioOutputDevice;

/**
 是否能录制屏幕
 */
+ (BOOL)canRecordScreen;

/**
是否能录制屏幕新方式
*/
+ (BOOL)canRecordScreenNew;
/**
 打开系统设置录制屏幕授权
*/
+ (BOOL)openSystemSettingRecordScreenAuthorize;

/**
 是否能录制系统声音
*/
+ (BOOL)canRecordAudio;

/**
 打开系统设置录制声音授权
*/
+ (BOOL)openSystemSettingRecordAudioAuthorize;

@end
