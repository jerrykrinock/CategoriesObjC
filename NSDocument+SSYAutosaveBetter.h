#import <Cocoa/Cocoa.h>

extern NSString* SSYDontAutosaveKey ;

@interface NSDocument (SSYAutosaveBetter)

/*!
 @brief    Like -[NSDocument isInViewingMode], except returns YES if receiver's
 fileURL's path contains "/Backups.backupdb/" or "/.DocumentRevisions-V100/"
 */
- (BOOL)ssy_isInViewingMode ;

@end
