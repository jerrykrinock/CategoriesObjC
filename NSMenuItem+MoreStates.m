#import "NSMenuItem+MoreStates.h"


@implementation NSMenuItem (MoreStates)

- (void)toggleState {
	[self setState:([self state] == NSControlStateValueOn) ? NSControlStateValueOff : NSControlStateValueOn] ;
}
	
@end
