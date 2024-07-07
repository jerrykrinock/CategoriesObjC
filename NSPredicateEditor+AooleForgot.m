#import "NSPredicateEditor+AppleForgot.h"
#import "NSView+Layout.h"


@implementation NSPredicateEditor (AppleForgot)

- (void)changeRowCountTo:(NSInteger)count {
    // Remove all existing rows
	NSRange range = NSMakeRange(0, [self numberOfRows]) ;
	NSIndexSet* indexSet = [NSIndexSet indexSetWithIndexesInRange:range] ;
	[self removeRowsAtIndexes:indexSet
			   includeSubrows:YES];
    
    // Add new rows
    for (NSInteger i=0; i<count; i++) {
        [self addRow:self];
    }
}

@end
