#import "NSDocumentController+FrontOrder.h"
#import "NSDocumentController+DisambiguateForUTI.h"

@implementation NSDocumentController (FrontOrder)

- (NSArray*)frontOrderDocuments {
    NSArray* documents = [self documents] ;
    NSInteger count = [documents count] ;
    if (count > 1) {
        NSDocument* frontDoc = [self currentDocument];
        /* frontDoc will be nil if a non-document window such as Preferences
         is frontmost. */
        if (frontDoc) {
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
    }
    
    return documents ;
}

- (NSArray*)defaultDocuments {
    Class defaultDocumentClass = [self defaultDocumentClass] ;
    NSMutableArray* defaultDocuments = [[NSMutableArray alloc] init] ;
    for (NSDocument* document in [self documents]) {
        if ([document isKindOfClass:defaultDocumentClass]) {
            [defaultDocuments addObject:document] ;
        }
    }
    
    NSArray* answer = [defaultDocuments copy] ;
    [answer autorelease] ;
    [defaultDocuments release] ;
    
    return answer ;
}

- (NSDocument*)currentDefaultDocumentAggressively {
	NSDocument* currentDocument = [self currentDocument] ;
	
    if (!currentDocument) {
        NSInteger docCount = [[self defaultDocuments] count] ;
        if (docCount == 1) {
            currentDocument = [[self defaultDocuments] firstObject] ;
        }
        else if ((docCount > 0)  && !currentDocument) {
            NSDocument* candidate ;
            Class defaultDocumentClass = [self defaultDocumentClass] ;
            candidate = [[[NSApp mainWindow] windowController] document] ;
            if ([candidate isKindOfClass:defaultDocumentClass]) {
                currentDocument = candidate ;
            }
            if (!currentDocument) {
                candidate = [[[NSApp keyWindow] windowController] document] ;
                if ([candidate isKindOfClass:defaultDocumentClass]) {
                    currentDocument = candidate ;
                }
                if (!currentDocument) {
                    for (NSWindow* window in [NSApp orderedWindows]) {
                        candidate = [[window windowController] document] ;
                        if ([candidate isKindOfClass:defaultDocumentClass]) {
                            currentDocument = candidate ;
                        }
                        if (currentDocument) {
                            break ;
                        }
                    }
                }
                
                if (!currentDocument) {
                    NSLog(@"Internal Error 501-3831  Can't discern current: %@", [self documents]) ;
                }
            }
        }
    }
    
	return currentDocument ;
}

@end
