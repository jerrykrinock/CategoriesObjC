#import "BSManagedDocument.h"

/*
 @brief    Class for infrequently reading and writing non-Core-Data key-value
 pairs of a BSManagedDocument to and from the disk

 @details  Yes, this is what many people would call "metadata", but I call it
 "auxiliary" to eliminate confusion with the "metadata" stored by Core Data,
 that is, the Z_METADATA table in the document's SQLite database.

 If you are using BSManagedDocument, you have a document package and it is
 much cleaner to store additional data in the package, rather than to put
 stuff in Core Data's metadata (Z_METADATA), especially when it comes time
 to save the managed object context.  That is what this category does.

 This class is optimized for infrequent, crash-proof access.  I thought about
 using the `additionalContent` API in BSManagedDocument, but decided against
 that because it is too tied up with the regular reading and writing methods.
 Nothing in our Auxiliary Data is cached in memory.  All getters read from the
 disk.  All setters write data to the disk before returning, unless the data
 to be set already exists and is equal on the disk.

 Objects stored by this class must, of course, be serializable.
 */
@interface BSManagedDocument (SSYAuxiliaryData)

- (id)auxiliaryObjectForKey:(NSString*)key;

/*!
 @brief    Sets or removes a given auxiliary key value pair on the disk

 @param    object  The desired value.  May be nil to remove the given key
 value from the disk.
 */
- (void)setAuxiliaryObject:(id)object
                    forKey:(NSString*)key;

- (void)addAuxiliaryKeyValues:(NSDictionary*)keyValues;

+ (id)auxiliaryObjectForKey:(NSString*)key
        documentPackagePath:(NSString*)path;

@end
