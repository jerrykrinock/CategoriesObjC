#import "NSMenu+RepresentMore.h"

@implementation NSMenu (RepresentMore)

- (NSMenuItem*)itemWithRepresentedObject:(id)object {
	for (NSMenuItem* item in [self itemArray]) {
		if ([object isEqual:[item representedObject]]) {
			return item ;
		}
	}
	
	return nil ;
}

@end
