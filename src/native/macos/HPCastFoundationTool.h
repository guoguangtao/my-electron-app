//
//  HPCastFoundationTool.h
//  HPBaseLibrary
//
//  Created by Moss1on on 2017/6/23.
//  Copyright © 2017年 HPPlay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HPCastKeyChainStore : NSObject

@end


@interface HPCastFoundationTool : NSObject


/**
获取系统版本

@return SystemVersion
*/
+ (NSString *)getSystemVersion;
/**
 获取设备型号
 
 @return 设备型号
 */
+ (NSString *)getDeviceModel;

/**
 获取设备名称
 
 @return 设备名称
 */
+ (NSString *)getIphoneName;

/**
 获取Mac地址
 
 @return 返回Mac地址
 */
+ (NSString *)getMacAddress;

/**
 获取手机版本
 
 @return 返回手机版本
 */
+ (NSString *)getIphoneVersion;

/**
 获取ip
 
 @return 返回设备ip
 */
+ (NSString *)getDeviceIPAddress;

/**
 获取CPU总数目
 
 @return CPU数
 */
+ (NSUInteger)getCPUCount;

/**
 获取系统总内存空间
 
 @return 系统总内存
 */
+ (int64_t)getTotalMemory;

/**
 获得UUID
 
 @return UUID
 */
+ (NSString *)getUUID;

/**
 获取client id
 
 IOS:cut+UUID+bundleid 大写后md5大写（16字节生成）取32位LONG型 hashcode
 cut:1 安卓  2iOS
 @return cu
 */
+ (NSString *)getCU;

/**
 获取client id
 
 IOS:cut+UUID+bundleid 大写后md5（16位）转64位long
 cut:1 安卓  2iOS

 @return cu
 */
+ (NSString *)getCU64;

/**
 获取手机的IDFA
 
 @return 手机的IDFA
 */
+ (NSString *)getIDFA;

/**
 获取本地时间戳
 
 @return 13位本地时间戳
 */
+ (NSString *)getLocal_stamp;

/**
 获取sessionid
 (cu + timestamp)大写，然后32位MD5,再转大写
 
 @return 本次连接的sessionID
 */
+ (NSString *)getSessionID;

/**
 获取bundle id
 
 @return bundle id
 */
+ (NSString *)getPackage;

/**
 32位 md5 加密
 
 @param string 需要加密的字符串
 @return 加密后返回的字符串
 */
+ (NSString *)stringToMD5:(NSString *)string;

/**
 32位 md5 加密
 
 @param data 需要加密的data
 @return 加密后返回的字符串
 */
+ (NSString *)stringToMD5WithData:(NSData *)data;

/**
 异或加密(该方法内不能加密包含中文字符)

 @param input 要加密的字符串
 @param keyCode 私钥
 @return 加密后返回的字符串
 */
+ (NSString *)stringToXOR:(NSString *)input keyCode:(NSString *)keyCode;

/**
 异或加密

 @param plainText 要加密的字符串
 @param secretKey 秘钥
 @return 加密后返回的字符传
 */
//+ (NSString *)stringXOREncryptWithPlainText:(NSString *)plainText secretKey:(NSString *)secretKey;

/**
 获取WiFi名称
 
 @return 当前WiFi名称
 */
+ (NSString *)getWifiName;

/**
 获取bssid

 @return 当前WiFi的bssid
 */
+ (NSString *)getBssid;

/**
 获取设备硬件id
 
 @return 设备硬件id
 ios: 取得到IDFA的情况：3+(IDFA转大写)MD5转大写.16位md5
 取不到IDFA的情况：4+（UUID转大写）MD5转大写.16位md5
 */
+ (NSString *)getHid;

/**
 获取url id
 
 @param sid 当前sessionId
 @return url id
 */
+ (NSString *)getUrlId:(NSString *)sid;

/**
 获取媒体uuid
 
 @param sid 当前sessionId
 @param content 媒体url/data
 @return url str
 */

+ (NSString *)getMediaUuId:(NSString *)sid content:(id)content;

/**
 获取SDK的版本号

 @return SDK的版本号
 */
+ (NSString *)getSDKVersion;

/**
 获取App的版本号
 
 @return App的版本号
 */
+ (NSString *)getAppVersion;

/**
 获取tuid

 @return tuid，用户唯一标识
 */
+ (NSString *)getTuid;

/**
 获取bundle identifier

 @return bundle identifier
 */
+ (NSString *)getBundleIdentifier;

/**
 判断是否是乐播投屏APP

 @return YES代表是乐播投屏APP，NO代表不是
 */
+ (BOOL)isLeBoAPP;

/**
 判断是不是乐播demo

 @return YES代表是，NO代表不是
 */
+ (BOOL)isLeBoDemoApp;


/**
 柱形位移加密，加密和解密的列顺序必须相同

 @param forEncryptStr 待加密字符串
 @param orderStr 列顺序，注意列顺序字符串的每个字符均为0~9
 @return 加密后的字符串
 */
+ (NSString *)cylindricalDisplacementEncryptWithString:(NSString *)forEncryptStr columnOrder:(NSString *)orderStr;

/**
 柱形位移解密，加密和解密的列顺序必须相同，解密用于验证加密是否OK

 @param forDecryptStr 待解密字符串
 @param orderStr 列顺序，注意列顺序字符串的每个字符均为0~9
 @return 解密后的字符串
 */
+ (NSString *)cylindricalDisplacementDecryptWithString:(NSString *)forDecryptStr columnOrder:(NSString *)orderStr;

@end

#pragma mark - C code

#ifndef LB_OUT
#define LB_OUT
#endif

#ifndef LB_IN
#define LB_IN
#endif

/**
 柱形位移加密，加密和解密的列顺序必须相同
 
 @param forEncrypt 待加密字符串
 @param columOrder 列顺序，注意列顺序字符串的每个字符均为0~9,必须能重新排列为0~n的自然数
 @param encryptedPtr 加密后的字符串，注意，该字符串在使用后需要释放，free（）
 @return 0代表加密成功，-1代表失败
 */
int cylindricalDisplacementEncrypt(LB_IN const char * forEncrypt, LB_IN const char * columOrder, LB_OUT char ** encryptedPtr);

/**
 柱形位移解密，加密和解密的列顺序必须相同，解密用于验证加密是否OK
 
 @param forDecrypt 待解密字符串
 @param columOrder 列顺序，注意列顺序字符串的每个字符均为0~9,必须能重新排列为0~n的自然数
 @param decryptedPtr 解密后的字符串，注意，该字符串在使用后需要释放，free（）
 @return 0代表加密成功，-1代表失败
 */
int cylindricalDisplacementDecrypt(LB_IN const char * forDecrypt, LB_IN const char * columOrder, LB_OUT char ** decryptedPtr);

