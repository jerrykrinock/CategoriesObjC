#import <Cocoa/Cocoa.h>


/*!
 @brief    

 @details  The NSColor methods were copied from
 http://developer.apple.com/documentation/Cocoa/Conceptual/DrawColor/Tasks/StoringNSColorInDefaults.html
*/
@interface NSUserDefaults (MoreTypes)

- (void)setColor:(NSColor*)aColor
		  forKey:(NSString*)aKey ;

- (NSColor*)colorForKey:(NSString*)aKey ;

@end
