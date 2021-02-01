#import <Cocoa/Cocoa.h>

extern NSString* const SSYManagedObjectContextCheatsErrorDomain ;
extern NSString* const SSYManagedObjectContextPathExtensionForSqliteStores ;

#define SSYManagedObjectContextCheatsErrorNoManagedObjectModel 613201
#define SSYManagedObjectContextCheatsErrorCouldNotCreatePSC 613202
#define SSYManagedObjectContextCheatsErrorCouldNotCreateUrlForStore 613203
#define SSYManagedObjectContextCheatsErrorCouldNotDeleteCorruptStore 613204
#define SSYManagedObjectContextCheatsErrorCouldNotFReplaceCorruptStore 613205
#define SSYManagedObjectContextCheatsErrorCouldNotCreateStore 613206
#define SSYManagedObjectContextCheatsErrorCouldNotGetStore 315644
#define SSYManagedObjectContextCheatsErrorStoreIsReadOnly 315645

@interface NSManagedObjectContext (Cheats)


/*!
 @brief    Returns the first persistent store of the receiver, or nil
 if the receiver does not have a persistent store
*/
- (NSPersistentStore*)store1 ;

/*!
 @brief    Returns the filesystem path to the first persistent store
 of the receiver, or nil if the receiver does not have a persistent
 store with a path
 */
- (NSString*)path1 ;
/*!
 @brief    Performs a fetch request for objects of a given entity name
 in the receiver's store, optionally satisfying a given predicate,
 and returns *one*, fixing the context if required by inserting one if
 there are none, and deleting others if there is more than one..

 @details  Use this method if you expect to find one and only one object
 of a given entity satisfying the predicate in the receiver's store.
 @param    predicate  May be nil if no predicate should be satisfied.
 @param    findings_p  On return, the value pointed to gives the number
 of objects that were found before objects were deleted or inserted
 if necessary to make only one.  If the value is != 1, you'll
 probably want to save the managed object context or else the
 NSPersistentDocument in which it resides.  (In the latter case,
 -saveDocument: is recommended since -[NSManagedObjectContext save:]
 will cause the very annoying "This document's file has been
 mofified by another application since you opened it" error.
*/
- (NSManagedObject*)singularObjectOfEntityName:(NSString*)entityName
									 predicate:(NSPredicate*)predicate
									findings_p:(NSInteger*)findings_p ;

/*!
 @brief    Fetches all objects from the receiver's store, and for each
 entity found logs the entity name and a count of objects
 
 @details  This is for debugging.
 @param    preface  A preface to be logged before the summary,
 useful as an identifier or label.  May be nil for no preface.
*/
- (void)logContentSummaryWithPreface:(NSString*)preface ;


/*!
 @brief    Returns the metadata of the receiver's first persistent store
 */
- (NSDictionary*)metadata1 ;

/*!
 @brief    Returns an object for a given key from the metadata of the
 receiver's first persistent store
*/
- (id)metadata1ObjectForKey:(id)key ;

/*!
 @brief    Sets an object for a given key in the metadata of the
 receiver's first persistent store, or removes the key
 
 @details  Does not save the store.
 Warning: This method will not work in new managed object contexts
 until after the store has been saved once.
 
 @param    object  A serializable object, or nil to remove the given key
 @param    error_p  If not NULL and if an error occurs, upon return, will point
 to an error object encapsulating the error.  If NULL and an error occurs, the
 error will be logged to the system console
 @result   YES if the metadata was written successfully, otherwise NO
 */
- (BOOL)setMetadata1Object:(id)object
				   forKey:(id)key
                   error_p:(NSError**)error_p ;

/*!
 @brief    Adds a given dictionary to the metadata of the first persistent
 store of the receiver, unless all of the given entries are already in the
 store

 @details  Does not save the store.
 Warning: This method will not work in new managed object contexts
 until after the store has been saved once.
 If an error occurs, logs to stderr.
 
 @result   YES if the metadata was changed, otherwise NO 
*/
- (BOOL)addMetadata1:(NSDictionary*)moreMetadata ;

/*!
 @brief    Returns an object currently existing in the receiver with
 a give object URI, or nil if no such object exists
*/
- (NSManagedObject*)objectWithUri:(NSString*)uri ;


@end
