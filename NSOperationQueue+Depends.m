#import "NSOperationQueue+Depends.h"


@implementation NSOperationQueue (Depends)

- (void)addAtEndOperation:(NSOperation*)operation {
	for (NSOperation* existingOperation in [self operations]) {
		[operation addDependency:existingOperation] ;
	}
	
	[self addOperation:operation] ;
}

@end
