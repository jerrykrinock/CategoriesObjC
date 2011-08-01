#import "NSHelpManager+HelpForHelp.h"
#include <Carbon/Carbon.h>

@implementation NSHelpManager (HelpForHelp)

+ (void)openAnchor:(NSString*)anchor 
 neighboringAnchor:(NSString*)neighboringAnchor {
	NSString* bookName = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleHelpBookName"] ;
	
	AHLookupAnchor((CFStringRef)bookName, (CFStringRef)neighboringAnchor) ;
	NSLog(@"Attempting to work around Apple Bug 4212853.  Supposedly this bug was fixed in Leopard.") ;
	[NSThread sleepUntilDate: [NSDate dateWithTimeIntervalSinceNow: 2.0]];
	AHLookupAnchor((CFStringRef)bookName, (CFStringRef)anchor) ;
}

+ (void)openAnchor:(NSString*)anchor {
	NSString* bookName = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleHelpBookName"] ;
	
	NSArray* anchors = [anchor componentsSeparatedByString:@"|"] ;
	
	if ([anchors count] == 1) {
		AHLookupAnchor((CFStringRef)bookName, (CFStringRef)anchor) ;
	}
	else if ([anchors count] == 2) {
		[self openAnchor:[anchors objectAtIndex:0]
	   neighboringAnchor:[anchors objectAtIndex:1] ] ;
	}
}

+ (void)openPage:(NSString*)page {
	NSString* bookName = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleHelpBookName"] ;
	AHGotoPage ((CFStringRef)bookName, (CFStringRef)page, NULL);
}	


@end

