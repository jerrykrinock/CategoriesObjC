#import <Foundation/Foundation.h>

@interface NSString (SSYCaseness)

/*!
 @brief    Determines whether the receiver or another given string
 has the first uppercase character in its sequence of characters
 
 @details  Starting with the first character in each of the two
 strings, if the first character for which the receiver's characters
 is uppercase occurs before the first character for which the other
 string's character is uppercase, returns NSOrderedDescending.  If
 the first character for which the other's characters is uppercase
 occurs before the first character for which the receiver's
 string's character is uppercase, returns NSOrderedAscending.
 Otherwise, returns NSOrderedSame.
 
 Test code for this method:
 
 - (void)cs1:(NSString*)s1 cs2:(NSString*)s2 {
 NSComparisonResult result = [s1 compareCase:s2] ;
 if (result == NSOrderedAscending) {
 NSLog(@"%@  <--up  %@", s2, s1) ;
 }
 else if (result == NSOrderedDescending) {
 NSLog(@"%@  <--up  %@", s1, s2) ;
 }
 else {
 NSLog(@"%@  SAME!  %@", s1, s2) ;
 }
 }
 
 
 - (id)init {
 NSString* s1, *s2 ;
 s1 = @"" ;
 s2 = @"Hello, World!" ;
 [self cs1:s1 cs2:s2] ;
 
 s1 = @"heLLO, WORLD!" ;
 s2 = @"Hello, World!" ;
 [self cs1:s1 cs2:s2] ;
 
 s1 = @"" ;
 s2 = @"" ;
 [self cs1:s1 cs2:s2] ;
 
 s1 = @"bROWNDOG" ;
 s2 = @"Browndog" ;
 [self cs1:s1 cs2:s2] ;
 
 s1 = @"nobody" ;
 s2 = @"yabody" ;
 [self cs1:s1 cs2:s2] ;
 
 s1 = @"noBody" ;
 s2 = @"yabody" ;
 [self cs1:s1 cs2:s2] ;
 
 s1 = @"zzzzz" ;
 s2 = @"aaaaA" ;
 [self cs1:s1 cs2:s2] ;
 
 s1 = @"z" ;
 s2 = @"A" ;
 [self cs1:s1 cs2:s2] ;
 
 s1 = @"zzz" ;
 s2 = @"aaa" ;
 [self cs1:s1 cs2:s2] ;
 
 s1 = @"aaa" ;
 s2 = @"zzz" ;
 [self cs1:s1 cs2:s2] ;
 
 s1 = @"ZZ" ;
 s2 = @"AA" ;
 [self cs1:s1 cs2:s2] ;
 
 s1 = @"A" ;
 s2 = @"Z" ;
 [self cs1:s1 cs2:s2] ;
 
 exit(0) ;
 
 */
- (NSComparisonResult)compareCase:(NSString*)other ;

@end
