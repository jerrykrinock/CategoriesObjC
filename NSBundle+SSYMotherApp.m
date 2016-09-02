#import "NSBundle+SSYMotherApp.h"
#import "NSBundle+MainApp.h"
#import "NSString+SSYDotSuffix.h"

@implementation NSBundle (SSYMotherApp)

- (NSString*)motherAppName {
    return [[NSBundle mainAppBundle] objectForInfoDictionaryKey:@"SSYMotherAppName"] ;
}

- (NSString*)motherAppBundleIdentifier {
    NSString* motherAppName = [self motherAppName] ;
    NSString* answer = nil ;
    if (motherAppName) {
        NSString* bundleIdentifier = [self bundleIdentifier] ;
        answer = [bundleIdentifier stringByDeletingDotSuffix] ;
        answer = [answer stringByAppendingDotSuffix:motherAppName] ;
    }
    
    return answer ;
}

- (NSString*)applicationSupportPathForMotherApp {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(
                                                         NSApplicationSupportDirectory,
                                                         NSUserDomainMask,
                                                         YES
                                                         ) ;
    NSString* userAppSupportPath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil ;
    // The idea is that we return "BookMacster" for the other three apps too.
    NSString* motherAppName = [self motherAppName] ;
    if (!motherAppName) {
        motherAppName = [[NSBundle mainAppBundle] objectForInfoDictionaryKey:@"CFBundleName"] ;
    }
    
    NSString* answer ;
    if (motherAppName) {
        answer = [userAppSupportPath stringByAppendingPathComponent:motherAppName] ;
    }
    else {
        answer = userAppSupportPath ;
    }

    return answer ;
}

@end
