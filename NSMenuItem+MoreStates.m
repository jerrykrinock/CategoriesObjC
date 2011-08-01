#import "NSMenuItem+MoreStates.h"


@implementation NSMenuItem (MoreStates)

- (void)toggleState {
	[self setState:([self state] == NSOnState) ? NSOffState : NSOnState] ;
}
	
@end
