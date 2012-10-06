#import <Cocoa/Cocoa.h>
#import "SSYBetterHashCategories.h"

#define SSY_HASH_BETTER_SEED 0xdeadbeef

@interface NSObject (HashBetter)

/*!
 @brief    A replacement for Apple's -hash, which invokes it
 but modifies its result to make it more random for small
 integer numbers, and when used as a building block for
 computing hashes of dictionaries containing common values,
 and also returns a 32-bit value instead of NSUInteger

 @details  This method modifies the result of Apple's -hash
 function, improving its randomness in some applications
 
 1.  For NSNumber, the -hash of a number with a given integer
 value is the same as the -hash of a number whose integer value
 is the negative of the given integer value.  This is a waste
 of the available space where only small integer values are possible.
 This method fixes that by adding NSNotFound to the hash of
 negative-valued NSNumbers.
 
 2.  If -hash returns a value of 0, we change it to 
 SSY_HASH_BETTER_SEED.
 This indeed occurs if the receiver
 is an NSNumber, whose -integerValue is 0.  Since 0 is quite a
 common number in many applications, and since starting with 0
 defeats our next improvement because 0*N=0, this change
 will improve the randomness of results.
*/
- (uint32_t)hashBetter32 ;

@end

@interface NSArray (HashBetter)

/*!
 @brief    Produces a nonlinear mix hash from the -hashBetter32
 of the receiver and a given starting hash, which is suitable for
 producing hashes of collections of values such as dictionaries

 @details  The bonehead approach to producing a hash of a 
 collection is to take the hashes of all the values and add,
 xor, or multiply them together.  Adding and xoring are not
 a good idea because of these two examples:
 
 Example 1:
 Consider a dictionary of boolean values.  Now create another
 dictionary from the original by swapping YES and NO values
 among the keys.  Although they now represent quite different
 objects, if you create a hash of both dictionaries by
 performing a linear combination of the hashes of all the values,
 both hashes will be the same.  
 
 Example 2:
 A set of ordered objects each has an 'index'
 attribute.  The objects are sorted or otherwise reordered.
 You still have the same set of 'index' values, just assigned
 to different objects.  Again, a linear operation performed on the
 values before and after sorting will yield the same
 hash value.
 
 To solve this problem, the hashes need to be "mixed" nonlinearly.
 A multiply operation (*) might be good, but be careful because
 when a multiply overflows in C, the result is undefined. This
 method is based on Robert Jenkins' mix() function, from here…
 http://www.burtleburtle.net/bob/hash/doobs.html
 
 The receiver is an array instead of a set because, in 
 order to get the same result each time the hash of a collection
 is computed, which is a required property of a hash f
 unction,
 the values must be mixed in the same order each time.
 
 @param    hash  An optional initial hash value which may be used to 
 chain hashes of arrays together.  Pass 0 if you only have one array.
*/
- (uint32_t)mixHash:(uint32_t)hash ;

/*!
 @brief    An override of hashBetter32 which really does work better for
 arrays

 @details  This method simply returns -mixHash:0.
 
 In Mac OS 10.7.2, Apple's -hash of an NSArray is particularly lame, returning
 the number of elements in the array.  Eeeek!
*/
- (uint32_t)hashBetter32 ;

@end


#if 0

// TEST CODE

NSArray *a, *b ;

#if __LP64__
NSString* integerFormat = @"%016x" ;
#else
NSString* integerFormat = @"%08x" ;
#endif

NSString* appleFormatString = [NSString stringWithFormat:
							   @" Apple hashes  a=%@  b=%@",
							   integerFormat,
							   integerFormat] ;
NSString* betterFormatString = [NSString stringWithFormat:
								@"Better hashes  a=%@  b=%@",
								integerFormat,
								integerFormat] ;


a = [NSArray arrayWithObjects:@"Tom", @"Dick", @"Sue", nil] ;
b = [NSArray arrayWithObjects:@"Sue", @"Tom", @"Dick", nil] ;
NSLog(appleFormatString, [a hash], [b hash]) ;
NSLog(betterFormatString, [a hashBetter32], [b hashBetter32]) ;

a = [NSArray arrayWithObjects:[NSNumber numberWithInteger:0], [NSNumber numberWithInteger:1], nil] ;
b = [NSArray arrayWithObjects:[NSNumber numberWithInteger:1], [NSNumber numberWithInteger:0], nil] ;
NSLog(appleFormatString, [a hash], [b hash]) ;
NSLog(betterFormatString, [a hashBetter32], [b hashBetter32]) ;

a = [NSArray arrayWithObjects:[NSNumber numberWithInteger:-1], [NSNumber numberWithInteger:1], nil] ;
b = [NSArray arrayWithObjects:[NSNumber numberWithInteger:1], [NSNumber numberWithInteger:-1], nil] ;
NSLog(appleFormatString, [a hash], [b hash]) ;
NSLog(betterFormatString, [a hashBetter32], [b hashBetter32]) ;

a = [NSArray arrayWithObjects:[NSNumber numberWithInteger:-5555], [NSNumber numberWithInteger:1], nil] ;
b = [NSArray arrayWithObjects:[NSNumber numberWithInteger:1], [NSNumber numberWithInteger:-5555], nil] ;
NSLog(appleFormatString, [a hash], [b hash]) ;
NSLog(betterFormatString, [a hashBetter32], [b hashBetter32]) ;

#endif