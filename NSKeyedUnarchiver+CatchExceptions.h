#import <Cocoa/Cocoa.h>


@interface NSKeyedUnarchiver (CatchExceptions) 

/*!
 @brief    Like -unarchiveObjectSafelyWithData:, except instead of
 throwing an exception and potentially crashing the app if given
 a corrupt archive, it simply returns nil. 
*/
+ (id)unarchiveObjectSafelyWithData:(NSData*)data ;

/*!
 @brief    Like unarchiveObjectSafelyWithData:, except in addition
 it returns the exception by reference.

 @param    error_p  Pointer which will, upon return, if an 
 error occurred and said pointer is not NULL, point to an
 error object describing the problem.
 */
+ (id)unarchiveObjectSafelyWithData:(NSData*)data
							error_p:(NSError**)error_p ;

@end
