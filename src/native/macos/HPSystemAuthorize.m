//
//  HPSystemAuthorize.m
//  HPOfficeCastSDKMac
//
//  Created by wangzhijun on 2019/11/20.
//  Copyright © 2019 王志军. All rights reserved.
//

#import "HPSystemAuthorize.h"

#import <AppKit/AppKit.h>
#import <CoreVideo/CoreVideo.h>
#import <AVFoundation/AVFoundation.h>
#import "HPCastFoundationTool.h"

@implementation HPSystemAuthorize

+ (BOOL)canRecordScreen{
    BOOL canRecordScreen = YES;
    NSString *systemVersion = [HPCastFoundationTool getSystemVersion];
    if ([systemVersion doubleValue] >= 10.15) {
        [self showScreenRecordingPrompt];
        canRecordScreen = NO;
        NSRunningApplication *runningApplication = NSRunningApplication.currentApplication;
        NSNumber *ourProcessIdentifier = [NSNumber numberWithInteger:runningApplication.processIdentifier];

        CFArrayRef windowList = CGWindowListCopyWindowInfo(kCGWindowListOptionOnScreenOnly, kCGNullWindowID);
        NSUInteger numberOfWindows = CFArrayGetCount(windowList);
        for (int index = 0; index < numberOfWindows; index++) {
           // get information for each window
           NSDictionary *windowInfo = (NSDictionary *)CFArrayGetValueAtIndex(windowList, index);
           NSString *windowName = windowInfo[(id)kCGWindowName];
           NSNumber *processIdentifier = windowInfo[(id)kCGWindowOwnerPID];

           // don't check windows owned by this process
           if (! [processIdentifier isEqual:ourProcessIdentifier]) {
               // get process information for each window
               pid_t pid = processIdentifier.intValue;
               NSRunningApplication *windowRunningApplication = [NSRunningApplication runningApplicationWithProcessIdentifier:pid];
               if (! windowRunningApplication) {
                   // ignore processes we don't have access to, such as WindowServer, which manages the windows named "Menubar" and "Backstop Menubar"
               }
               else {
                   NSString *windowExecutableName = windowRunningApplication.executableURL.lastPathComponent;
                   if (windowName) {
                       if ([windowExecutableName isEqual:@"Dock"]) {
                           // ignore the Dock, which provides the desktop picture
                       }
                       else {
                           canRecordScreen = YES;
                           break;
                       }
                   }
               }
           }
        }
        CFRelease(windowList);
    }
    NSLog(@"canRecordScreen:%d",canRecordScreen);
    return canRecordScreen;
}

+ (BOOL)canRecordScreenNew{
    BOOL canRecordScreen = YES;
       NSString *systemVersion = [HPCastFoundationTool getSystemVersion];
    if ([systemVersion doubleValue] >= 10.15) {
        CGDisplayStreamRef stream = CGDisplayStreamCreate(CGMainDisplayID(), 1, 1, kCVPixelFormatType_32BGRA, nil, ^(CGDisplayStreamFrameStatus status, uint64_t displayTime, IOSurfaceRef frameSurface, CGDisplayStreamUpdateRef updateRef) {
                ;
            });
            BOOL canRecord = stream != NULL;
            if (stream) {
              CFRelease(stream);
            }
            canRecordScreen = canRecord;
    }
    NSLog(@"canRecordScreenNew:%d",canRecordScreen);
    return canRecordScreen;
}
//void (^CGDisplayStreamFrameAvailableHandler)(CGDisplayStreamFrameStatus status, uint64_t displayTime,
//IOSurfaceRef __nullable frameSurface,
//CGDisplayStreamUpdateRef __nullable updateRef);

+ (BOOL)canRecord{
    BOOL canRecordScreen = YES;
    NSString *systemVersion = [HPCastFoundationTool getSystemVersion];
    if ([systemVersion doubleValue] >= 10.15) {
        canRecordScreen = NO;
        NSRunningApplication *runningApplication = NSRunningApplication.currentApplication;
        NSNumber *ourProcessIdentifier = [NSNumber numberWithInteger:runningApplication.processIdentifier];

        CFArrayRef windowList = CGWindowListCopyWindowInfo(kCGWindowListOptionOnScreenOnly, kCGNullWindowID);
        NSUInteger numberOfWindows = CFArrayGetCount(windowList);
        for (int index = 0; index < numberOfWindows; index++) {
            // get information for each window
            NSDictionary *windowInfo = (NSDictionary *)CFArrayGetValueAtIndex(windowList, index);
            NSString *windowName = windowInfo[(id)kCGWindowName];
            NSNumber *processIdentifier = windowInfo[(id)kCGWindowOwnerPID];

            // don't check windows owned by this process
            if (! [processIdentifier isEqual:ourProcessIdentifier]) {
                // get process information for each window
                pid_t pid = processIdentifier.intValue;
                NSRunningApplication *windowRunningApplication = [NSRunningApplication runningApplicationWithProcessIdentifier:pid];
                if (! windowRunningApplication) {
                    // ignore processes we don't have access to, such as WindowServer, which manages the windows named "Menubar" and "Backstop Menubar"
                }
                else {
                    NSString *windowExecutableName = windowRunningApplication.executableURL.lastPathComponent;
                    if (windowName) {
                        if ([windowExecutableName isEqual:@"Dock"]) {
                            // ignore the Dock, which provides the desktop picture
                        }
                        else {
                            NSLog(@"windowExecutableName %@",windowExecutableName);
                            canRecordScreen = YES;
                            break;
                        }
                    }
                }
            }
        }
        CFRelease(windowList);
    }
    return canRecordScreen;
}

+ (void)showScreenRecordingPrompt{
  
  /* macos 10.14 and lower do not require screen recording permission to get window titles */
//  if(@available(macos 10.15, *)) {
    /*
     To minimize the intrusion just make a 1px image of the upper left corner
     This way there is no real possibilty to access any private data
     */
    CGImageRef screenshot = CGWindowListCreateImage(
                                                    CGRectInfinite,
                                                    kCGWindowListOptionOnScreenOnly,
                                                    kCGNullWindowID,
                                                    kCGWindowImageDefault);
    if (screenshot) {
        CFRelease(screenshot);
    }
}

+ (BOOL)openSystemSettingRecordScreenAuthorize{
    NSString *urlString = @"x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture";
       BOOL isOpen = [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:urlString]];
    NSLog(@"isOpen : %zd",isOpen);
    return isOpen;
}

+ (BOOL)canRecordAudio{

    NSString *systemVersion = [HPCastFoundationTool getSystemVersion];
    if ([systemVersion doubleValue] >= 10.14) {
//        NSString * mediaTypeAudio = AVMediaTypeAudio;
           AVAuthorizationStatus authorizationAudioStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
          if (authorizationAudioStatus == AVAuthorizationStatusNotDetermined) {
         //发起请求鉴权(系统弹窗)
             [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
                 
             }];
         } else if (authorizationAudioStatus == AVAuthorizationStatusRestricted || authorizationAudioStatus == AVAuthorizationStatusDenied) {
             NSLog(@"麦克风权限被限制");         //可以做一些自定义的操作: 提醒用户打开设置面板 勾选麦克风权限
             return NO;
         } else {
         //已经授权
         }
//          AVAuthorizationStatus authorizationAudioStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaTypeAudio];
//        if (authorizationAudioStatus == AVAuthorizationStatusRestricted  || authorizationAudioStatus == AVAuthorizationStatusDenied) {
//            return NO;
//        }
    }else{
        NSError *error = nil;
        AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
        AVCaptureDeviceInput *deviceInput= [[AVCaptureDeviceInput alloc] initWithDevice:captureDevice error:&error];
        if (error) {
             NSLog(@"canRecordAudio:NO 录音设备出错 error:%@ deviceInput:%@",error,deviceInput);
             return NO;
         }
    }
    NSLog(@"canRecordAudio:YES");
    return YES;
}

+ (BOOL)openSystemSettingRecordAudioAuthorize{
    NSString *urlString = @"x-apple.systempreferences:com.apple.preference.security?Privacy_Microphone";
    BOOL isOpen = [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:urlString]];
    NSLog(@"isOpen : %zd",isOpen);
    return isOpen;
}

@end
