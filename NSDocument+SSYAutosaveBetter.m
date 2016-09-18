#import "NSDocument+SSYAutosaveBetter.h"

NSString* SSYDontAutosaveKey = @"dontAutosave" ;

@implementation NSDocument (SSYAutosaveBetter)


- (BOOL)ssy_isInViewingMode {
	BOOL isInViewingMode ;
    isInViewingMode = [self isInViewingMode] ;
    // But Apple's implementation does not always work as I expect,
    // so I add another possibility…
    if (!isInViewingMode) {
        NSString* path = [[self fileURL] path] ;
        // A newly-duplicated document will not have a path yet.
        if (path) {
            if ([path rangeOfString:@"/.DocumentRevisions-V100/"].location != NSNotFound) {
                isInViewingMode = YES ;
            }
            // Added in BookMacster 1.17
            if ([path rangeOfString:@"/Backups.backupdb/"].location != NSNotFound) {
                isInViewingMode = YES ;
            }
        }
    }
    
	return isInViewingMode ;
}

@end
