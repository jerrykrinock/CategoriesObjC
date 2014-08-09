#import <Cocoa/Cocoa.h>

@interface NSDocumentController (FrontOrder)

/*
 @brief    Returns the result of -documents, except if the current document is
 not at index 0 in that array, then returns a rearranged version of that array
 which has the current document removed and then reinserted at index 0
 
 @details  Although the order of the array returned by 
 -[NSDocumentController documents] is not documented, in my experience, its
 order is the order in which documents were opened, even if a later-opened
 document is now the current document.  The "current document" here is the
 frontmost, active document, the one returned by -currentDocument.
 */
- (NSArray*)frontOrderDocuments ;

/*
 @brief    Returns the frontmost of the receiver's open documents which is of
 the receiver's default types, more aggressively than Cocoa's -currentDocument
 
 @details  -[NSDocumntController currentDocument] will return nil, for example,
 during for the brief period between the time that a first document is added to
 the document controller the time that it opens any windows, or something like
 that.
 */
- (NSDocument*)currentDefaultDocumentAggressively ;

@end
