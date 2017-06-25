#import "BSManagedDocument.h"
/* BSManagedDocument is a open source replacement for NSPersistentDocument.
 It is recommended for any Core Data document-based app.
 https://github.com/jerrykrinock/BSManagedDocument
 */

@interface BSManagedDocument (SSYMetadata)

/*!
 @brief    Returns the metadata of an SQLite
 persistent store at a given path, by cheating, that is, by opening the store
 with SSYSQLiter and querying "SELECT Z_PLIST FROM Z_METADATA".
 
 @details  This is a heavyweight method which you should use to get metadata
 from documents that are not already open.  To get metadata from open documents,
 use the much simpler instance method, -metadataObjectForKey:.
 
 Notice that this method does not return an error.  If something goes wrong,
 it is logged to stderr.
 */
+ (NSDictionary*)metadataAtPath:(NSString*)path ;

/*!
 @brief    Returns an object for a given key from the metadata of an SQLite
 persistent store at a given path, by cheating, that is, by opening the store
 with SSYSQLiter and querying "SELECT Z_PLIST FROM Z_METADATA".

 @details  Ditto from +metadataAtPath:
 */
+ (id)metadataObjectForKey:(NSString*)key
                      path:(NSString*)path ;

/*!
 @brief    Returns an object for a given key from the metadata of the
 receiver's first persistent store
 
 @details  This method uses a little trick.  First, it tries to
 get the metadata from the first of the  persistent store of the receiver.
 If that returns nil, then it cheats by using +metadataObjectForKey:path:
 */
- (id)metadataObjectForKey:(NSString*)key ;

/*!
 @brief    Adds a given object and key to the metadata of the first
 persistent store of the receiver's managed object context
 
 @details   This method will not work in new managed object contexts
 until after the store has been saved once.
 
 @param    object  A serializable object.  (It will be set as a value in an NSDictionary.)
 @param    andSave  See -addMetadata:andSave:.

 */
- (void)setMetadataObject:(id)object
				   forKey:(NSString*)key
                  andSave:(BOOL)doSave ;

/*!
 @brief    Adds a given dictionary to the metadata of the first persistent
 store of the receiver's managed object context
 
 @details  Also saves the store as described in -saveMetadataOnly.
 To get the existing metadata (which is necesary to mutate it),
 relies on the same trick described in -metadataObjectForKey:
 
 @param    andSave  Optionally saves the store as described in -saveMetadataOnly.
 It is best to pass NO if you know that the document will be saved immediately
 in some other method, because there are wacky edge cases where this save
 followed by another save will result in one of those damned "The changes made
 by the other application will be lost if you save. Save anyway?" because
 "This document’s file has been changed by another application since you opened
 or saved it" sheets being presented (macOS 10.7); or NSCocoa ErrorDomain
 error code 67000 being sent to -willPresentError: (macOS 10.8).
*/
- (void)addMetadata:(NSDictionary*)moreMetadata
            andSave:(BOOL)doSave ;

/*!
 @brief    Workaround for the fact that the only way to save metadata in
 a Core Data document is to save the managed object context, which saves
 the regular data too.
 
 @details   This method saves only if the document's regular data does
 *not* have changes because…
 
 * I'm afraid of introducing bugs into the always-fragile  NSPersistentDocument
 document-saving system, which I have already bastardized quite a bit in other places.
 
 * I don't want to be saving the document and un-dirtying the dirty dot without
 the user asking to "Save".
 
 * If the document is dirty, and if the user cares, it will be saved later anyhow.
 
 * Saving will be guaranteed if this method is invoked while opening a document,
 so if there's some really important metadata, you might be able to do it then.
 */
- (void)saveMetadataOnly ;

	
@end
