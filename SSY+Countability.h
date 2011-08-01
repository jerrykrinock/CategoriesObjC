#import <Cocoa/Cocoa.h>


/*!
 @brief    A formal protocol which declares that, duh,
 NSArray and NSSet both implement -count.

 @details  Methods that want a parameter to take either an NSArray or
 NSSet can declare it with type (NSObject <SSYCountability> *)
*/
@protocol SSYCountability

- (NSInteger)count ;

@end


@interface NSArray (DeclareSSYCountability) <SSYCountability> 

@end

@interface NSSet (DeclareSSYCountability) <SSYCountability> 

@end

