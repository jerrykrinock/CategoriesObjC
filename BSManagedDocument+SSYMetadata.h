#import "BSManagedDocument.h"
/* BSManagedDocument is a open source replacement for NSPersistentDocument.
 It is recommended for any Core Data document-based app.
 https://github.com/jerrykrinock/BSManagedDocument
 */

/*!
 @brief    Class for accessing Core Data metadata of a BSManagedDocument,
 with or without a persistence stack

 @details  In macOS 10.13.3, at least, there is no reliable way to *just*
 save changes to Core Data metadata.  To save metadata changes, you must
 change object(s) in the actual data model, and *then*  invoke
 -[NSManagedObjectContext save:].  For your own key/value pairs you  should
 consider using BSManagedDocument(SSYAuxiliaryData) instead of Core Data's
 metadata.
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
 persistent store of the receiver's managed object context, or removes a
 given key
 
 @details   This method will not work in new managed object contexts
 until after the store has been saved once.  If the object and key are not
 added because the store is readonly, this method is a no-op.
 
 @param    object  A serializable object, or nil to remove the given key
 @param    error_p  If not NULL and if returning NO, will point to an error
 object encapsulating the error.
 @result   YES the method succeeds, or if it fails because the store is
 readonly.  If setting fails for other reasons, returns NO.

 */
- (BOOL)setMetadataObject:(id)object
				   forKey:(NSString*)key
                  error_p:(NSError**)error_p;

/*!
 @brief    Adds a given dictionary to the metadata of the first persistent
 store of the receiver's managed object context
 
 @details  To get the existing metadata (which is necesary to mutate it),
 relies on the same trick described in -metadataObjectForKey:
 */
- (void)addMetadata:(NSDictionary*)moreMetadata;

@end
