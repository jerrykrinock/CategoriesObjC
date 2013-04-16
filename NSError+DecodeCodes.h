#import <Foundation/Foundation.h>

@interface NSError (DecodeCodes)

/*!
 @brief    Returns a set of numbers whose intValues are the -code of the receiver and
 the codes of all underlying errors, but only if the relevant error's domain is
 equal to a given domain, unless domain is nil in which case it's the codes of
 all underlying errors.
 */
- (NSSet*)allInvolvedCodesInDomain:(NSString*)domain ;

/*!
 @brief    Returns whether the receiver or any of its underlying errors is in a given domain
 and has a code in a given set, unless the given domain is nil then it returns whether or
 not the receiver or any of its underlying errors simply has a code in a given set.
 */
- (BOOL)involvesOneOfCodesInSet:(NSSet*)targetCodes
						 domain:(NSString*)domain ;

/*!
 @brief    Returns whether the receiver or any of its underlying errors has a code
 in a given set.
 */
- (BOOL)involvesOneOfCodesInSet:(NSSet*)targetCodes ;

/*!
 @brief    Returns whether the receiver or any of its underlying errors is in +myDomain
 and has a code in a given set.
 */
- (BOOL)involvesOneOfMyCodesInSet:(NSSet*)targetCodes ;

/*!
 @brief    Returns whether the receiver or any of its underlying errors is in a given domain
 and has a given code, unless the given domain is nil then it returns whether or
 not the receiver or any of its underlying errors simply has the given code.
 */
- (BOOL)involvesCode:(NSInteger)code
			  domain:(NSString*)domain ;

/*!
 @brief    Returns whether the receiver or any of its underlying errors has a given code.
 */
- (BOOL)involvesCode:(NSInteger)code ;

/*!
 @brief    Returns whether the receiver or any of its underlying errors is in +myDomain
 and has a given code.
 */
- (BOOL)involvesMyDomainAndCode:(NSInteger)code ;

/*!
 @brief    Returns NO if the receiver is not a known "file not found"
 type of error
 
 @details  Returns NO if the receiver has code NSFileReadNoSuchFileError=260
 and domain NSCocoaErrorDomain or ENOENT=2 and NSPOSIXErrorDomain.  (The former
 is returned by -[NSFileManager contentsOfDirectoryAtPath:error:] if the given
 path does not exist.)
 
 Use this method to process only other errors, like this
 • if ([error isNotFileNotFoundError]) {
 •     // This is a serious error, do something about it
 •     …
 • }
 
 The reason we put the *Not* in the name of the method is because this gives
 the expected result if error is nil :)
 */
- (BOOL)isNotFileNotFoundError ;

- (BOOL)isUserCancelledCocoaError ;
@end
