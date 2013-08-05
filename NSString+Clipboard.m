#import "NSString+Clipboard.h"
#import <Cocoa/Cocoa.h>

@implementation NSString (Clipboard)

+ (NSString*)clipboard {
	NSPasteboard* pasteboard = [NSPasteboard generalPasteboard] ;
	NSArray* supportedTypes = [NSArray arrayWithObject:NSStringPboardType] ;
	NSString* type = [pasteboard availableTypeFromArray:supportedTypes] ;
	NSString* value = [pasteboard stringForType:type];
	return value ;
}

- (void)copyToClipboard {
	NSPasteboard* pasteboard = [NSPasteboard generalPasteboard] ;
	[pasteboard declareTypes:[NSArray arrayWithObjects:NSStringPboardType, nil]
					   owner:nil] ;
	// Above, we can say owner:nil since we are going to provide data immediately
	[pasteboard setString:self
				  forType:NSStringPboardType] ;
}


@end
