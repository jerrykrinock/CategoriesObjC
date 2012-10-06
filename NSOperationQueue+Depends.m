#import "NSOperationQueue+Depends.h"


@implementation NSOperationQueue (Depends)

- (void)addAtEndOperation:(NSOperation*)operation {
	NSOperation* priorOperation = [[self operations] lastObject] ;
	if (priorOperation) {
		[operation addDependency:priorOperation] ;
	}
	
	[self addOperation:operation] ;
}

@end
