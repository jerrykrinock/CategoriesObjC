@interface NSPersistentDocument (SSYMetadata)

/*!
 @brief    Returns an object for a given key from the metadata of the
 receiver's first persistent store
 
 @details  This method uses a little trick.  First, it tries to
 get the metadata from the first of the 
 persistent store of the receiver.  If that
 returns nil, then it cheats by opening the store with SSYSQLiter
 and querying "SELECT Z_PLIST FROM Z_METADATA".
 
 If an error occurs, logs to stderr.
 */
- (id)metadataObjectForKey:(NSString*)key ;

/*!
 @brief    Adds a given object and key to the metadata of the first
 persistent store of the receiver's managed object context
 
 @details  Also saves the store as described in -saveMetadataOnly.
 Warning: This method will not work in new managed object contexts
 until after the store has been saved once.
 
 @param    object  A serializable object.  (It will be set as a value in an NSDictionary.)
 */
- (void)setMetadataObject:(id)object
				   forKey:(NSString*)key ;

/*!
 @brief    Adds a given dictionary to the metadata of the first persistent
 store of the receiver's managed object context
 
 @details  Also saves the store as described in -saveMetadataOnly.
 To get the existing metadata (which is necesary to mutate it),
 relies on the same trick described in -metadataObjectForKey:
 */
- (void)addMetadata:(NSDictionary*)moreMetadata ;

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
