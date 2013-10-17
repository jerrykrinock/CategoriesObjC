#import "NSDocumentController+DisambiguateForUTI.h"
#import "NSBundle+MainApp.h"
#import "NSArray+SafeGetters.h"
#import "NSBundle+MainApp.h"

@implementation NSDocumentController (DisambiguateForUTI)

- (NSString*)filenameExtensionForDocumentUTI:(NSString*)uti {
	NSArray* docDics = [[NSBundle mainAppBundle] objectForInfoDictionaryKey:@"CFBundleDocumentTypes"] ;
	NSString* extension = nil ;
	for (NSDictionary* docDic in docDics) {
		NSArray* utis = [docDic objectForKey:@"LSItemContentTypes"] ;
		for (NSString* uti in utis) {
			if ([uti isEqualToString:uti]) {
				NSArray* extensions = [docDic objectForKey:@"CFBundleTypeExtensions"] ;
				extension = [extensions firstObjectSafely] ;
				break ;
			}
		}
		if (extension) {
			break ;
		}
	}
					
	return extension ;
}			

- (NSString*)displayNameForDocumentUTI:(NSString*)uti {
	NSArray* docDics = [[NSBundle mainAppBundle] objectForInfoDictionaryKey:@"CFBundleDocumentTypes"] ;
	NSString* displayName = nil ;
	for (NSDictionary* docDic in docDics) {
		NSArray* utis = [docDic objectForKey:@"LSItemContentTypes"] ;
		for (NSString* uti in utis) {
			if ([uti isEqualToString:uti]) {
				displayName = [docDic objectForKey:@"CFBundleTypeName"] ;
				break ;
			}
		}
		if (displayName) {
			break ;
		}
	}
	
	return displayName ;
}			

- (NSDictionary *)defaultDocumentInfo {
    // If this executable is located in Contents/MacOS, then -[NSDocumentController defaultType]
	// will return the UTI instead of the "Name" if the document type has a UTI defined.
	// NSString* uti = [self defaultType] ;
	
	// Unfortunately, if this executable is not in Contents/MacOS, as occurs if executing
	// a helper application, which is located in Contents/Helpers/, for other reasons,
	// -[NSDocumentController defaultType] will return nil.
//  The solution is to to dig into the mainAppBundle ourselves
    NSArray* docDics = [[NSBundle mainAppBundle] objectForInfoDictionaryKey:@"CFBundleDocumentTypes"] ;
    return [docDics firstObjectSafely] ;
}

- (NSString*)defaultDocumentUTI {
    NSDictionary *docInfo = [self defaultDocumentInfo] ;
    NSArray* utis = [docInfo objectForKey:@"LSItemContentTypes"] ;
    NSString* uti = [utis firstObjectSafely] ;

	return uti ;
}

- (NSString*)defaultDocumentFilenameExtension {
	NSString* uti = [self defaultDocumentUTI] ;
	return [self filenameExtensionForDocumentUTI:uti] ;
}

- (NSString*)defaultDocumentDisplayName {
	NSString* uti = [self defaultDocumentUTI] ;
	return [self displayNameForDocumentUTI:uti] ;
}

- (Class)defaultDocumentClass {
    return NSClassFromString([[self defaultDocumentInfo] objectForKey:@"NSDocumentClass"]) ;
}

- (NSString*)defaultDocumentIconName {
    return [[self defaultDocumentInfo] objectForKey:@"CFBundleTypeIconFile"] ;
}

@end