#import <Cocoa/Cocoa.h>


@interface NSManagedObject (Debug)

/*!
 @brief    Returns a truncation of [[[self objectID] URIRepresentation] absoluteString],
 showing only some of the unique parts, in a string of 2-6 characters.
 Conserves console space when printing in logs during debugging.

 @details  An managed object can be uniquely identified by its
 [[[self objectID] URIRepresentation] absoluteString].
 These typically look like this:
 *   For permanent objects:
 *       x-coredata://8E4A6EED-E4FE-4C6B-95AD-02E874FDAEAC/myEntityName/p139
 *   For temporary objects:
 *       x-coredata:///myEntityName/t77470F45-9092-4480-95AB-A6D79F1CE70537
 When you're debugging and want to log one of these things, it takes up too
 much space in your console output.
 For the permanent objects, only the last part, p139 in our example, are 
 usually unique.  For temporary objects, only the last few digits of that
 UUID at the end are usually unique.
 
 This method returns a string beginning with "t" or "p" to indicate whether
 it's temporary or permanent, followed by a few characters form the unique
 parts identified above.
*/
- (NSString*)truncatedID ;

@end
