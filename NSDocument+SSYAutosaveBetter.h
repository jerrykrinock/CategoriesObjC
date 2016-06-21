#import <Cocoa/Cocoa.h>

extern NSString* SSYDontAutosaveKey ;

@interface NSDocument (SSYAutosaveBetter)

/*!
 @brief    Like -[NSDocument isInViewingMode], except works better
 
 @details  The improvements are:
 • Returns YES if receiver's fileURL's path contains
 .     "/Backups.backupdb/" or "/.DocumentRevisions-V100/"
 • Returns NO, instead of crashing, if the runtime macOS precedes macOS 10.7.
 */
- (BOOL)ssy_isInViewingMode ;

@end
