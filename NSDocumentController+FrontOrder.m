#import "NSDocumentController+FrontOrder.h"

@implementation NSDocumentController (FrontOrder)

- (NSArray*)frontOrderDocuments {
    NSArray* documents = [self documents] ;
    NSInteger count = [documents count] ;
    if (count > 1) {
        NSDocument* frontDoc = [self currentDocument] ;
        if ([documents objectAtIndex:0] != frontDoc) {
            // Need to fix the order
            NSMutableArray* mutant = [documents mutableCopy] ;
            [mutant removeObject:frontDoc] ;
            [mutant insertObject:frontDoc
                         atIndex:0] ;
            documents = [[mutant copy] autorelease] ;
            [mutant release] ;
        }
    }
    
    return documents ;
}

@end
