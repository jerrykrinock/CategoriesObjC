#import <Cocoa/Cocoa.h>


@interface NSDocument (SyncModDate)

/*!
 @brief    Sets the receiver's internal fileModificationDate
 to the current modification date of the receiver's file on disk,
 which is indicated by the receiver's -fileURL.

 @details  This is typically necessary after doing any kind of
 under-the-table replacement of the receiver's file in the filesystem,
 lest Cocoa ruin your data by later emitting an error like this one…
 
 ***     code: 67000
 ***   domain: NSCocoaErrorDomain
 *** userInfo:
 **Key: NSLocalizedRecoverySuggestion
 Value: Click Save Anyway to keep your changes and save the changes made by the other application as a version, or click Revert to keep the changes from the other application and save your changes as a version.
 **Key: NSLocalizedFailureReason
 Value: The file has been changed by another application.
 **Key: NSLocalizedDescription
 Value: This document’s file has been changed by another application.
 **Key: NSLocalizedRecoveryOptions
 Value: {
 Save Anyway
 Revert
 }
 **Key: NSRecoveryAttempter
 Value: <NSDocumentErrorRecoveryAttempter: 0x6917a20>

 (The above is from Mac OS X 10.7.  Other OS versions may be slightly different.)
 */
- (void)syncFileModificationDate ;

@end
