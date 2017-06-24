#import <Cocoa/Cocoa.h>
#import "BSManagedDocument.h"

extern NSString* SSYPersistentDocumentVerifyModelResourcesErrorDomain ;

#define SSYPersistentDocumentVerifyModelResourcesErrorBadResource 252856

@interface BSManagedDocument (VerifyModelResources)

/*!
 @brief    Verifies that the data model resources in the app package are
 not overly corrupt, so that we get a good error message instead of 
 inexplicable puke from Core Data.
 
 @details  This method was added after I received a crash report from a
 user, and asked Apple to decode it for me, DTS Incident 275744748.
 The crash was not reproducible.
 
 @param    error_p  If this method returns NO, upon return, will point to an
 error object in domain SSYPersistentDocumentVerifyModelResourcesErrorDomain
 with code SSYPersistentDocumentVerifyModelResourcesErrorBadResource that
 explains the error.
 @result   YES if the model resources are OK, otherwise NO.
 */
- (BOOL)verifyModelResourcesError_p:(NSError**)error_p ;

@end
