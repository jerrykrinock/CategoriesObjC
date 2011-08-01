#import <Cocoa/Cocoa.h>

@interface NSString (VarArgs)

- (int)countOccurrencesOfSubstring:(NSString*)substring ;

/*
 Returns the count of % characters in the receiver, or the
 index of the highest placeholder + 1, (1-10), whichever is larger.
 */
- (int)countMaxPlaceholders ;

+ (NSString *)replacePlaceholdersInString:(NSString*)s
								 argPtr_p:(va_list*)argPtr_p ;


/*
 returns a string representation of the integer.  Examples: "1" "42", "-579".
 */
+ (NSString*)stringWithInt:(int)i ;

@end

