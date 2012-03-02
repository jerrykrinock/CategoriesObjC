// Probably most of this stuff is necessary because of the notRealBrowprietaryValueKeys
// crap that I use to handle the garbage required by ExtoreOpera.

@interface NSDictionary (DeepDooDoo)

- (BOOL)isEqualDeepToDictionary:(NSDictionary*)otherDic ;

- (BOOL)isEqualDeepToDictionary:(NSDictionary*)otherDic
				   ignoringKeys:(NSSet*)ignoreKeys ;

- (BOOL)isEqualDeepToDictionary:(NSDictionary*)otherDic
				   ignoringKeys:(NSSet*)ignoreKeys
				inSubdictionary:(NSString*)subdicKey ;

@end

// To test this category, change the following #if 0 to 1
#if 0
#define COMPILING_TEST_CODE_FOR_NSDICTIONARY_DEEPDOODOO 1

@interface NSDictionary (DeepDooDooTest)

- (void)testEqualToDictionary:(NSDictionary*)otherDic
				 ignoringKeys:(NSSet*)ignoreKeys 
			  inSubdictionary:(NSString*)subdicKey ;

@end

#endif

#if 0
// Then, use the following test code in your test program
#import "NSDictionary+DeepDooDoo.h"


#endif