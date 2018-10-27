#import "NSDocumentController+SSYFixLaunchServicesBug.h"

@implementation NSDocumentController (SSYFixLaunchServicesBug)

- (NSString*)fixLaunchServicesBugForUrl:(NSURL*)url
                             typeName_p:(NSString**)typeName_p {
    NSString* result = nil;

    if (url) {
        NSString* revisedTypeName = nil;
        NSString* extension = url.absoluteString.pathExtension;
        extension = [extension stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/"]];

        SEL mainAppBundleSelector = NSSelectorFromString(@"mainAppBundle");
        /* -mainAppBundle is defined in NSBundle+MainApp.h */
        NSBundle* bundle;
        if ([NSBundle respondsToSelector:mainAppBundleSelector]) {
            bundle = [NSBundle performSelector:mainAppBundleSelector];
        } else {
            bundle = [NSBundle mainBundle];
        }

        NSArray* docInfos = [bundle objectForInfoDictionaryKey:@"CFBundleDocumentTypes"];
        for (NSDictionary* info in docInfos) {
            for (NSString* aExtension in [info objectForKey:@"CFBundleTypeExtensions"]) {
                if ([extension isEqualToString:aExtension]) {
                    NSString* aType = [[info objectForKey:@"LSItemContentTypes"] firstObject];
                    if (aType) {
                        revisedTypeName = [aType lowercaseString];
                        break;
                    }
                }
            }
            if (revisedTypeName) {
                break;
            }
        }

        if (revisedTypeName && typeName_p) {
            if (![revisedTypeName isEqualToString:*typeName_p]) {
                result = [NSString stringWithFormat:
                          @"Launch Services Bug: doc type %@ (was %@) for %@",
                          revisedTypeName,
                          *typeName_p,
                          url.absoluteString];
                *typeName_p = revisedTypeName;
            }
        }
    }
    
    return result;
}
@end
