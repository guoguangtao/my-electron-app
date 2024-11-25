//
//  HPCastFoundationTool.m
//  HPBaseLibrary
//
//  Created by Moss1on on 2017/6/23.
//  Copyright © 2017年 HPPlay. All rights reserved.
//

#import "HPCastFoundationTool.h"
//#import <UIKit/UIKit.h>
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <net/if.h>
#import "sys/utsname.h"
#import <CommonCrypto/CommonDigest.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#include <sys/socket.h> // Per msqr
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#import <SystemConfiguration/CaptiveNetwork.h>
// 是否获取idfa开关,1：采集idfa； 0：不采集idfa
#define USEIDFA 0

#if USEIDFA
#import <AdSupport/AdSupport.h>
#endif

#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
#define IOS_VPN         @"utun0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"

// SDK内UUID的key值
static NSString * const key_username_password = @"com.hpplay.castsdk";

@implementation HPCastKeyChainStore

+ (NSMutableDictionary *)getKeychainQuery:(NSString *)service{
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
            (id)kSecClassGenericPassword,(id)kSecClass,
            service,(id)kSecAttrService,
            service,(id)kSecAttrAccount,
            (id)kSecAttrAccessibleAfterFirstUnlock,(id)kSecAttrAccessible,
            nil];
}

+ (void)save:(NSString *)service data:(id)data{
    
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    SecItemDelete((CFDictionaryRef)keychainQuery);
    NSString *systemVersion = [HPCastFoundationTool getSystemVersion];
    if ([systemVersion doubleValue] >= 10.11) {
        [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:data] forKey:(id)kSecValueData];
    } else {
        // Fallback on earlier versions
    }
    SecItemAdd((CFDictionaryRef)keychainQuery, NULL);
}

+ (id)load:(NSString *)service{
    id ret = nil;
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    [keychainQuery setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
    [keychainQuery setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
    CFDataRef keyData = NULL;
        @try {
            if (SecItemCopyMatching((CFDictionaryRef)keychainQuery, (CFTypeRef *)&keyData) == noErr) {
                ret = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge NSData *)keyData];
            }
        } @catch (NSException *exception) {
            NSLog(@"unarchive of %@ failed:%@",service,exception);
        } @finally {
        }
    if (keyData) {
        CFRelease(keyData);
    }
    return ret;
}

+ (void)deleteKeyData:(NSString *)service{
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    SecItemDelete((CFDictionaryRef)keychainQuery);
}


@end


@implementation HPCastFoundationTool

+ (NSString *)getSystemVersion{
    NSDictionary *sysVersion = [NSDictionary dictionaryWithContentsOfFile: @"/System/Library/CoreServices/SystemVersion.plist"];
    NSString *versionStr = [sysVersion objectForKey: @"ProductVersion"];
    return versionStr;
}

// 获取设备型号
+ (NSString *)getDeviceModel
{
    // 需要#import "sys/utsname.h"
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    /*
    if ([deviceString isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone3,2"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone3,3"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([deviceString isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPhone5,3"])    return @"iPhone 5c (GSM)";
    if ([deviceString isEqualToString:@"iPhone5,4"])    return @"iPhone 5c (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPhone6,1"])    return @"iPhone 5s (GSM)";
    if ([deviceString isEqualToString:@"iPhone6,2"])    return @"iPhone 5s (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([deviceString isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([deviceString isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([deviceString isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    if ([deviceString isEqualToString:@"iPhone8,4"])    return @"iPhone SE";
    // 日行两款手机型号均为日本独占，可能使用索尼FeliCa支付方案而不是苹果支付
    if ([deviceString isEqualToString:@"iPhone9,1"])    return @"国行、日版、港行iPhone 7";
    if ([deviceString isEqualToString:@"iPhone9,2"])    return @"港行、国行iPhone 7 Plus";
    if ([deviceString isEqualToString:@"iPhone9,3"])    return @"美版、台版iPhone 7";
    if ([deviceString isEqualToString:@"iPhone9,4"])    return @"美版、台版iPhone 7 Plus";
    
    if ([deviceString isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([deviceString isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([deviceString isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([deviceString isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([deviceString isEqualToString:@"iPod5,1"])      return @"iPod Touch (5 Gen)";
    
    if ([deviceString isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([deviceString isEqualToString:@"iPad1,2"])      return @"iPad 3G";
    if ([deviceString isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([deviceString isEqualToString:@"iPad2,2"])      return @"iPad 2";
    if ([deviceString isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([deviceString isEqualToString:@"iPad2,4"])      return @"iPad 2";
    if ([deviceString isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    if ([deviceString isEqualToString:@"iPad2,6"])      return @"iPad Mini";
    if ([deviceString isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([deviceString isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPad3,3"])      return @"iPad 3";
    if ([deviceString isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([deviceString isEqualToString:@"iPad3,5"])      return @"iPad 4";
    if ([deviceString isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPad4,1"])      return @"iPad Air (WiFi)";
    if ([deviceString isEqualToString:@"iPad4,2"])      return @"iPad Air (Cellular)";
    if ([deviceString isEqualToString:@"iPad4,4"])      return @"iPad Mini 2 (WiFi)";
    if ([deviceString isEqualToString:@"iPad4,5"])      return @"iPad Mini 2 (Cellular)";
    if ([deviceString isEqualToString:@"iPad4,6"])      return @"iPad Mini 2";
    if ([deviceString isEqualToString:@"iPad4,7"])      return @"iPad Mini 3";
    if ([deviceString isEqualToString:@"iPad4,8"])      return @"iPad Mini 3";
    if ([deviceString isEqualToString:@"iPad4,9"])      return @"iPad Mini 3";
    if ([deviceString isEqualToString:@"iPad5,1"])      return @"iPad Mini 4 (WiFi)";
    if ([deviceString isEqualToString:@"iPad5,2"])      return @"iPad Mini 4 (LTE)";
    if ([deviceString isEqualToString:@"iPad5,3"])      return @"iPad Air 2";
    if ([deviceString isEqualToString:@"iPad5,4"])      return @"iPad Air 2";
    if ([deviceString isEqualToString:@"iPad6,3"])      return @"iPad Pro 9.7";
    if ([deviceString isEqualToString:@"iPad6,4"])      return @"iPad Pro 9.7";
    if ([deviceString isEqualToString:@"iPad6,7"])      return @"iPad Pro 12.9";
    if ([deviceString isEqualToString:@"iPad6,8"])      return @"iPad Pro 12.9";
    
    if ([deviceString isEqualToString:@"AppleTV2,1"])      return @"Apple TV 2";
    if ([deviceString isEqualToString:@"AppleTV3,1"])      return @"Apple TV 3";
    if ([deviceString isEqualToString:@"AppleTV3,2"])      return @"Apple TV 3";
    if ([deviceString isEqualToString:@"AppleTV5,3"])      return @"Apple TV 4";
    
    if ([deviceString isEqualToString:@"i386"])         return @"Simulator";
    if ([deviceString isEqualToString:@"x86_64"])       return @"Simulator";
    */
    return deviceString;
}

// 获取设备名称
+ (NSString *)getIphoneName{
//    NSString *iphoneName = [UIDevice currentDevice].name;
    NSString *iphoneName = @"";

    return iphoneName;
}

/**
 获取Mac地址
 
 @return 返回Mac地址
 */
+ (NSString *)getMacAddress
{
    int                 mib[6];
    size_t              len;
    char                *buf;
    unsigned char       *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl  *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1\n");
        return NULL;
    }
    
    if ((buf = malloc(len)) == NULL) {
        printf("Could not allocate memory. error!\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2");
        free(buf);
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSString *outstring = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                           *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    free(buf);
    
    return outstring;
}

/**
 获取手机版本
 
 @return 返回手机版本
 */
+ (NSString *)getIphoneVersion{
//    NSString *version = [UIDevice currentDevice].systemVersion;
    NSString *version = @"";
    return version;
}


/**
 获取ip
 
 @return 返回设备ip
 */
+ (NSString *)getDeviceIPAddress{
    NSArray *searchArray = @[ IOS_VPN @"/" IP_ADDR_IPv4, IOS_VPN @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6 ];
    
    
    NSDictionary *addresses = [self getIPAddresses];
    
    __block NSString *address;
    [searchArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop)
     {
         address = addresses[key];
         //筛选出IP地址格式
         if([self isValidatIP:address]) *stop = YES;
     } ];
    return address ? address : @"0.0.0.0";
}

+ (BOOL)isValidatIP:(NSString *)ipAddress {
    if (ipAddress.length == 0) {
        return NO;
    }
    NSString *urlRegEx = @"^([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])$";
    
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:urlRegEx options:0 error:&error];
    
    if (regex != nil) {
        NSTextCheckingResult *firstMatch=[regex firstMatchInString:ipAddress options:0 range:NSMakeRange(0, [ipAddress length])];
        
        if (firstMatch) {
            NSRange resultRange = [firstMatch rangeAtIndex:0];
            NSString *result=[ipAddress substringWithRange:resultRange];
            //输出结果
            NSLog(@"%@",result);
            return YES;
        }
    }
    return NO;
}

+ (NSDictionary *)getIPAddresses
{
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
    
    // retrieve the current interfaces - returns 0 on success
    struct ifaddrs *interfaces;
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        struct ifaddrs *interface;
        for(interface=interfaces; interface; interface=interface->ifa_next) {
            if(!(interface->ifa_flags & IFF_UP) /* || (interface->ifa_flags & IFF_LOOPBACK) */ ) {
                continue; // deeply nested code harder to read
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
            char addrBuf[ MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN) ];
            if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                NSString *type;
                if(addr->sin_family == AF_INET) {
                    if(inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv4;
                    }
                } else {
                    const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)interface->ifa_addr;
                    if(inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv6;
                    }
                }
                if(type) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    return [addresses count] ? addresses : nil;
}

// CPU总数目
+ (NSUInteger)getCPUCount {
    return [NSProcessInfo processInfo].activeProcessorCount;
}

// 系统总内存空间
+ (int64_t)getTotalMemory {
    int64_t totalMemory = [[NSProcessInfo processInfo] physicalMemory];
    if (totalMemory < -1) totalMemory = -1;
    return totalMemory;
}

+ (NSString *)getUUID{
//    NSString *strUUID = (NSString *)[HPCastKeyChainStore load:key_username_password];
    NSString *strUUID = [[NSUserDefaults standardUserDefaults] valueForKey:key_username_password];
    if ([strUUID isEqualToString:@""] || !strUUID) {
        CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
        strUUID = (NSString *)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, uuidRef));
        //        [HPCastKeyChainStore save:key_username_password data:strUUID];
        [[NSUserDefaults standardUserDefaults] setValue:strUUID forKey:key_username_password];
    }
    return strUUID;
}

+ (NSString *)getCU{
    NSString *tempCu = [NSString stringWithFormat:@"2%@%@",[self getUUID],[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"]];
    NSString *bateTmp = [self MD5For16Bate:[tempCu uppercaseString]];
    NSString *tmpup = [bateTmp uppercaseString];
    int hashcu = [self intFNVHash:tmpup];
    NSString *cu = [NSString stringWithFormat:@"%d", hashcu];
    
    // 将发送端的cu缓存到本地，以方便DLNA使用
    NSUserDefaults *sharedDefault = [[NSUserDefaults alloc] initWithSuiteName:@"group.hpplay.com.asstant"];
    [sharedDefault setValue:cu forKey:@"cu"];
    [sharedDefault synchronize];
    
    return cu;
}

/**
 获取client id
 
 IOS:cut+UUID+bundleid 大写后md5（16位）转64位long
 cut:1 安卓  2iOS
 
 @return cu
 */
+ (NSString *)getCU64 {
    // cut+UUID+bundleid
    NSString *tempCu = [NSString stringWithFormat:@"2%@%@",[self getUUID],[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"]];
    // 大写后转md5 16位
    NSString * md5Str = [self MD5For16Bate:[tempCu uppercaseString]];
    // 转64位long
    NSString * cu64 = [self parseMd5L16ToLong:md5Str];
    
    return cu64;
}

+ (NSString *)getIDFA {
    NSString *idfa = nil;
#if USEIDFA
    idfa = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
#else
    idfa = [self stringToMD5:[self getMacAddress]];
#endif
    if (idfa == nil) {
        idfa = @"";
    }
    if ([idfa isEqualToString:@"00000000-0000-0000-0000-000000000000"] || [idfa isEqualToString:@"00000000000000000000000000000000"]) {
        idfa = @"";
    }
    
    return idfa;
}

+ (NSString *)getLocal_stamp {
    NSString * ls = [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970]*1000];
    if (ls == nil) {
        ls = @"";
    }
    return ls;
}

+ (NSString *)getSessionID {
//    NSString *cu = [self getCU];
    NSString *cu = [self getCU64];
    NSString *ls = [self getLocal_stamp];
    NSString *tmpSessionid = [NSString stringWithFormat:@"%@%@",cu,ls];
    tmpSessionid = [tmpSessionid uppercaseString];
    NSString *mdSessionid = [self stringToMD5:tmpSessionid];
    NSString *sessionid = [NSString stringWithFormat:@"%@",mdSessionid];
    sessionid = [sessionid uppercaseString];
    return sessionid;
}

+ (NSString *)getPackage {
    NSString *package = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
    if (package == nil) {
        package = @"";
    }
    return package;
}

+ (NSString *)getWifiName {
    NSString *wifi = nil;
    
    CFArrayRef wifiInterfaces = CNCopySupportedInterfaces();
    
    if (!wifiInterfaces) {
        
        return nil;
    }
    
//    NSArray *interfaces = (__bridge NSArray *)wifiInterfaces;
    
//    for (NSString *interfaceName in interfaces) {
//        CFDictionaryRef dictRef = CNCopyCurrentNetworkInfo((__bridge CFStringRef)(interfaceName));
//
//        if (dictRef) {
//            NSDictionary *networkInfo = (__bridge NSDictionary *)dictRef;
////            NSLog(@"network info -> %@", networkInfo);
//            wifi = [networkInfo objectForKey:(__bridge NSString *)kCNNetworkInfoKeySSID];
//
//            CFRelease(dictRef);
//        }
//    }
    
    CFRelease(wifiInterfaces);
    return wifi;
}

+ (NSString *)getBssid {
    NSString *bid = nil;
    CFArrayRef wifiInterfaces = CNCopySupportedInterfaces();
    
    if (!wifiInterfaces) {
        
        return nil;
    }
    
//    NSArray *interfaces = (__bridge NSArray *)wifiInterfaces;
    
//    for (NSString *interfaceName in interfaces) {
//        CFDictionaryRef dictRef = CNCopyCurrentNetworkInfo((__bridge CFStringRef)(interfaceName));
//        
//        if (dictRef) {
//            NSDictionary *networkInfo = (__bridge NSDictionary *)dictRef;
////            NSLog(@"network info -> %@", networkInfo);
//            bid = [networkInfo objectForKey:(__bridge NSString *)kCNNetworkInfoKeyBSSID];
//            
//            CFRelease(dictRef);
//        }
//    }
    
    CFRelease(wifiInterfaces);
    
    NSString * tempBssid = @"";
    if (bid != nil && bid.length < 17) {
        NSArray * arr = [bid componentsSeparatedByString:@":"];
        for (NSInteger i = 0; i < arr.count; i++) {
            NSString * temStr = arr[i];
            if (i == 0) {
                if (temStr.length == 2) {
                    tempBssid = [tempBssid stringByAppendingString:temStr];
                }else if (temStr.length == 1){
                    tempBssid = [tempBssid stringByAppendingString:[NSString stringWithFormat:@"0%@",temStr]];
                }
                continue;
            }
            if (temStr.length == 2) {
                tempBssid = [tempBssid stringByAppendingString:[NSString stringWithFormat:@":%@",temStr]];
            }else if (temStr.length == 1){
                tempBssid = [tempBssid stringByAppendingString:[NSString stringWithFormat:@":0%@",temStr]];
            }
        }
    }
    bid = tempBssid;
    
    return bid;
    
}

+ (NSString *)getHid {
    NSString *hid;
    NSString *idfa = [self getIDFA];
    if (idfa != nil && idfa.length > 0) {
        // 将IDFA 转大写
        NSString *upperidfa = [idfa uppercaseString];
        // 大写MDFA MD532位加密
        NSString *md5idfa = [self stringToMD5:upperidfa];
        // 加密后再转大写
        NSString *uppermd5 = [md5idfa uppercaseString];
//         再16位 md5加密
//        NSString *tmpidfa = [self MD5For16Bate:uppermd5];
        // 再转大写
//        uppermd5 = [uppermd5 uppercaseString];
        // 拼接 3
        hid = [NSString stringWithFormat:@"3%@",uppermd5];
        
    }
    else {
        NSString *uuid = [self getUUID];
        // 将uuid 转大写
        NSString *upperuuid = [uuid uppercaseString];
        // 大写MDFA MD532位加密
        NSString *md5uuid = [self stringToMD5:upperuuid];
        // 加密后再转大写
        NSString *uppermd5 = [md5uuid uppercaseString];
//        // 再16位 md5加密
//        NSString *tmpuuid = [self MD5For16Bate:uppermd5];
//         再转大写
//        tmpuuid = [tmpuuid uppercaseString];
        // 拼接 4
        hid = [NSString stringWithFormat:@"4%@",uppermd5];
    }
    return hid;
}

+ (NSString *)getUrlId:(NSString *)sid {
    NSString *urlid;
    if (sid == nil) {
        char data[6];
        for (int x=0;x<6;data[x++] = (char)('A' + (arc4random_uniform(26))));
        NSString * tempStr = [[NSString alloc] initWithBytes:data length:6 encoding:NSUTF8StringEncoding];
        urlid = [[self getSessionID] stringByAppendingString:tempStr];
    }
    else {
        char data[6];
        for (int x=0;x<6;data[x++] = (char)('A' + (arc4random_uniform(26))));
        NSString * tempStr = [[NSString alloc] initWithBytes:data length:6 encoding:NSUTF8StringEncoding];
        urlid = [sid stringByAppendingString:tempStr];
    }
    return urlid;
}

+ (NSString *)getMediaUuId:(NSString *)sid content:(id)content{
    return [self stringToMD5:[NSString stringWithFormat:@"%@%f%@",sid,[[NSDate date] timeIntervalSince1970],content]];
}

/**
 16位 md5 加密
 
 @param str 需要加密的字符串
 @return 加密后的字符串
 */
+ (NSString *)MD5For16Bate:(NSString *)str {
    NSString *md5Str = [self stringToMD5:str];
    NSString  *string;
    if (md5Str.length > 24) {
        string=[md5Str substringWithRange:NSMakeRange(8, 16)];
    }
    return string;
}

/**
 32位 md5 加密
 
 @param str 需要加密的字符串
 @return 加密后的字符串
 */
+ (NSString *)stringToMD5:(NSString *)str
{
    //1.首先将字符串转换成UTF-8编码, 因为MD5加密是基于C语言的,所以要先把字符串转化成C语言的字符串
    const char *fooData = [str UTF8String];
    
    //2.然后创建一个字符串数组,接收MD5的值
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    
    //3.计算MD5的值, 这是官方封装好的加密方法:把我们输入的字符串转换成16进制的32位数,然后存储到result中
    CC_MD5(fooData, (CC_LONG)strlen(fooData), result);
    /**
     第一个参数:要加密的字符串
     第二个参数: 获取要加密字符串的长度
     第三个参数: 接收结果的数组
     */
    //4.创建一个字符串保存加密结果
    NSMutableString *saveResult = [NSMutableString string];
    //5.从result 数组中获取加密结果并放到 saveResult中
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [saveResult appendFormat:@"%02x", result[i]];
    }
    /*
     x表示十六进制，%02X  意思是不足两位将用0补齐，如果多余两位则不影响
     NSLog("%02X", 0x888);  //888
     NSLog("%02X", 0x4); //04
     */
    return saveResult;
}

/**
 32位 md5 加密
 
 @param data 需要加密的data
 @return 加密后返回的字符串
 */
+ (NSString *)stringToMD5WithData:(NSData *)data{
    //1.然后创建一个字符串数组,接收MD5的值
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    
    //2.计算MD5的值, 这是官方封装好的加密方法:把我们输入的字符串转换成16进制的32位数,然后存储到result中
    CC_MD5(data.bytes, (CC_LONG)(data.length), result);
    /**
     第一个参数:要加密的字符串
     第二个参数: 获取要加密字符串的长度
     第三个参数: 接收结果的数组
     */
    //3.创建一个字符串保存加密结果
    NSMutableString *saveResult = [NSMutableString string];
    //4.从result 数组中获取加密结果并放到 saveResult中
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [saveResult appendFormat:@"%02x", result[i]];
    }
    /*
     x表示十六进制，%02X  意思是不足两位将用0补齐，如果多余两位则不影响
     NSLog("%02X", 0x888);  //888
     NSLog("%02X", 0x4); //04
     */
    return saveResult;
}

/**
 异或加密
 
 @param input 要加密的字符串
 @param keyCode 私钥
 @return 加密后返回的字符串
 */
+ (NSString *)stringToXOR:(NSString *)input keyCode:(NSString *)keyCode {
    
    NSData *codeKeyData =  [keyCode dataUsingEncoding:NSUTF8StringEncoding];
    Byte codeKeyByteAry[codeKeyData.length];
    for (int i = 0 ; i < codeKeyData.length; i++) {
        NSData *idata = [codeKeyData subdataWithRange:NSMakeRange(i, 1)];
        codeKeyByteAry[i] =((Byte*)[idata bytes])[0];
    }

    NSData *strData =  [input dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableData *returnData = [[NSMutableData alloc] init];
    for (int i = 0 ; i < strData.length; i++) {
        NSData *idata = [strData subdataWithRange:NSMakeRange(i, 1)];
        Byte byte =((Byte*)[idata bytes])[0];
        Byte byte2 = codeKeyByteAry[i%keyCode.length];
        Byte returnbyte = byte^byte2;
        Byte returnbyteAry[1];
        returnbyteAry[0] = returnbyte;
        [returnData appendBytes:returnbyteAry length:1];
    }
    NSString *returnStr =  [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    return returnStr;
}

/**
 32位hash
 
 @param data 需要hash的数据
 @return hash之后的数据
 */
+ (int)intFNVHash:(NSString *)data {
    int p = 16777619;
    int hash = (int)2166136261L;
    for (int i = 0; i < data.length; i++) {
        hash = (hash ^ [data characterAtIndex:i]) * p;
    }
    hash += hash << 13;
    hash ^= hash >> 7;
    hash += hash << 3;
    hash ^= hash >> 17;
    hash += hash << 5;
    return hash;
}

+ (NSString *)parseMd5L16ToLong:(NSString *)md5L16 {
    if (nil == md5L16 || md5L16.length == 0) {
        return nil;
    }
    md5L16 = [md5L16 lowercaseString];
    NSData * data = [md5L16 dataUsingEncoding:NSUTF8StringEncoding];
    const char * bytes = data.bytes;
    long re = 0L;
    for (int i = 0; i < data.length; i++) {
        //加下一位的字符时，先将前面字符计算的结果左移4位
        re <<= 4;
        //0-9数组
        char b = (char)(bytes[i] - 48);
        //A-F字母
        if (b > 9) {
            b = (char)(b - 39);
        }
        //非16进制的字符
        if (b > 15 || b < 0) {
            return nil;
        }
        re += b;
    }
    
    NSString * reStr = [NSString stringWithFormat:@"%ld",re];
    return reStr;
}

+ (NSString *)getSDKVersion{
    return @"";
}

+ (NSString *)getAppVersion{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    return [infoDictionary objectForKey:@"CFBundleShortVersionString"];
}

+ (NSString *)getTuid {
    NSString * tuid = [[NSUserDefaults standardUserDefaults] objectForKey:@"LBLelinkKit_userID"];
    return tuid;
}

+ (NSString *)getBundleIdentifier {
    NSString * bundleId = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
    return bundleId;
}

+ (BOOL)isLeBoAPP {
    NSString * bundleId = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
    BOOL result = [bundleId isEqualToString:@"com.hpplay.tvassistant"];
    return result;
}

+ (BOOL)isLeBoDemoApp {
    NSString * bundleId = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
    BOOL result = [bundleId isEqualToString:@"com.hpplay.AppleSenderSDK"];
    return result;
}

/**
 柱形位移加密，加密和解密的列顺序必须相同
 
 @param forEncryptStr 待加密字符串
 @param orderStr 列顺序，注意列顺序字符串的每个字符均为0~9
 @return 加密后的字符串
 */
+ (NSString *)cylindricalDisplacementEncryptWithString:(NSString *)forEncryptStr columnOrder:(NSString *)orderStr {
    if (nil == forEncryptStr || 0 == forEncryptStr.length) {
        return nil;
    }
    
    // 不加这一句，则中文加密会失败
    forEncryptStr = [forEncryptStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    char * encrypted = NULL;
    int ret = cylindricalDisplacementEncrypt([forEncryptStr cStringUsingEncoding:NSUTF8StringEncoding], [orderStr cStringUsingEncoding:NSUTF8StringEncoding], &encrypted);
    if (ret != 0) {
        return nil;
    }
    
    NSString * encryptedStr = nil;
    if (NULL == encrypted) {
        return nil;
    } else {
        encryptedStr = [encryptedStr stringByRemovingPercentEncoding];
        encryptedStr  = [NSString stringWithUTF8String:encrypted];
        free(encrypted);
        encrypted = NULL;
    }
    
    return encryptedStr;
}

/**
 柱形位移解密，加密和解密的列顺序必须相同，解密用于验证加密是否OK
 
 @param forDecryptStr 待解密字符串
 @param orderStr 列顺序，注意列顺序字符串的每个字符均为0~9
 @return 解密后的字符串
 */
+ (NSString *)cylindricalDisplacementDecryptWithString:(NSString *)forDecryptStr columnOrder:(NSString *)orderStr {
    if (nil == forDecryptStr || 0 == forDecryptStr.length) {
        return nil;
    }
    
    char * decrypt = NULL;
    int ret = cylindricalDisplacementDecrypt([forDecryptStr cStringUsingEncoding:NSUTF8StringEncoding], [orderStr cStringUsingEncoding:NSUTF8StringEncoding], &decrypt);
    if (ret != 0) {
        return nil;
    }
    
    NSString * decryptStr = nil;
    if (NULL == decrypt) {
        return nil;
    } else {
        
        decryptStr = [NSString stringWithUTF8String:decrypt];
        // 移除Encoding
        decryptStr = [decryptStr stringByRemovingPercentEncoding];
        free(decrypt);
        decrypt = NULL;
    }
    
    return decryptStr;
}

@end

#pragma mark - C code

/**
 柱形位移加密，加密和解密的列顺序必须相同
 
 @param forEncrypt 待加密字符串
 @param columOrder 列顺序，注意列顺序字符串的每个字符均为0~9,必须能重新排列为0~n的自然数
 @param encryptedPtr 加密后的字符串，注意，该字符串在使用后需要释放，free（）
 @return 0代表加密成功，-1代表失败
 */
int cylindricalDisplacementEncrypt(LB_IN const char * forEncrypt, LB_IN const char * columOrder, LB_OUT char ** encryptedPtr) {
    // 1 计算列数
    if (NULL == columOrder || 0 == strlen(columOrder)) {
        NSLog(@"列数为空");
        return -1;
    }
    unsigned long columNum = 0; // 列数
    columNum = strlen(columOrder);
    
    // 2 计算行数
    if (NULL == forEncrypt || 0 == strlen(forEncrypt)) {
        NSLog(@"被加密字符串为空");
        return -1;
    }
    unsigned long rowNum = 0; // 行数
    rowNum = strlen(forEncrypt) / columNum + 1;
    
    // 3 根据行和列，构造二维字符数组，将forEncrypt，填充
    char * buffer = NULL;
    buffer = (char *)malloc(rowNum * columNum); // 二维数组其实是一维的
    if (NULL == buffer) {
        NSLog(@"分配内存空间失败");
        return -1;
    }
    memset(buffer, 0, rowNum * columNum); // 清零
    strcpy(buffer, forEncrypt); // 填充
    
    // 4 组串，按columOrder的列顺序，逐列取字符组成列串，组合。
    char * temEncrypted = (char *)malloc(strlen(forEncrypt) + 1);
    if (NULL == temEncrypted) {
        NSLog(@"encrypted分配空间失败");
        return -1;
    }
    memset(temEncrypted, 0, strlen(forEncrypt) + 1);
    int encryptedIndex = 0;
    for (int i = 0; i < columNum; i++) { // 按列取，共计columNum列
        
        // 找到第i次获取的列号
        bool findFlag = false;
        int columIndex = 0;
        for (int j = 0; j < columNum; j++) {
            if (i == (columOrder[j] - 48)) {
                findFlag = true;
                columIndex = j;
                break;
            }
        }
        if (!findFlag) {
            NSLog(@"columOrder列序不是可排序为自然数序列");
            if (buffer != NULL) {
                free(buffer);
                buffer = NULL;
            }
            if (temEncrypted != NULL) {
                free(temEncrypted);
                temEncrypted = NULL;
            }
            return -1;
        }
        
        for (int k = 0; k < rowNum; k++) {// 在第columIndex列，按行取字符
            unsigned long rowIndex = columIndex + k * columNum;
            if (buffer[rowIndex] == 0) {// 0不组串
                break;
            }
            temEncrypted[encryptedIndex] = buffer[rowIndex];
            encryptedIndex++;
        }
    }
    
    *encryptedPtr = temEncrypted;
    
    // 5 释放临时不用的堆区空间
    if (buffer != NULL) {
        free(buffer);
        buffer = NULL;
    }
    
    return 0;
}

/**
 柱形位移解密，加密和解密的列顺序必须相同，解密用于验证加密是否OK
 
 @param forDecrypt 待解密字符串
 @param columOrder 列顺序，注意列顺序字符串的每个字符均为0~9,必须能重新排列为0~n的自然数
 @param decryptedPtr 解密后的字符串，注意，该字符串在使用后需要释放，free（）
 @return 0代表加密成功，-1代表失败
 */
int cylindricalDisplacementDecrypt(LB_IN const char * forDecrypt, LB_IN const char * columOrder, LB_OUT char ** decryptedPtr) {
    // 1 计算列数
    if (NULL == columOrder || 0 == strlen(columOrder)) {
        NSLog(@"列数为空");
        return -1;
    }
    unsigned long columNum = 0; // 列数
    columNum = strlen(columOrder);
    
    // 2 计算行数
    if (NULL == forDecrypt || 0 == strlen(forDecrypt)) {
        NSLog(@"被加密字符串为空");
        return -1;
    }
    unsigned long rowNum = 0; // 行数
    rowNum = strlen(forDecrypt) / columNum + 1;
    
    // 3 根据行列，构造字符数组，顺序填充
    char * buffer = NULL;
    buffer = (char *)malloc(rowNum * columNum); // 二维数组其实是一维的
    if (NULL == buffer) {
        NSLog(@"分配内存空间失败");
        return -1;
    }
    memset(buffer, 0, rowNum * columNum); // 清零
    strcpy(buffer, forDecrypt); // 顺序填充，为了将非\0的字符占位
    
    // 4 按columOrder的列顺序，逐列填充buffer中非0的字符
    
    int decryptedIndex = 0;
    for (int i = 0; i < columNum; i++) { // 按列取，共计columNum列
        
        // 第i次获取的列号
        int columIndex = columOrder[i] - 48;
        
        for (int k = 0; k < rowNum; k++) {// 在第columIndex列，按行填充字符
            unsigned long rowIndex = columIndex + k * columNum;
            if (buffer[rowIndex] == 0) {// 0不组串
                break;
            }
            buffer[rowIndex] = forDecrypt[decryptedIndex];
            decryptedIndex++;
        }
    }
    
    // 5 顺序拷贝出buffer中的字符
    char * temDecrypt = (char *)malloc(strlen(forDecrypt) + 1);
    if (NULL == temDecrypt) {
        NSLog(@"temDecrypt分配空间失败");
        return -1;
    }
    memset(temDecrypt, 0, strlen(forDecrypt) + 1);
    int m = 0;
    while (buffer[m] != 0) {
        temDecrypt[m] = buffer[m];
        m++;
    }
    
    *decryptedPtr = temDecrypt;
    
    // 释放
    if (buffer != NULL) {
        free(buffer);
        buffer = NULL;
    }
    
    return 0;
}

