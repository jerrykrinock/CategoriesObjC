#import <Cocoa/Cocoa.h>

@interface NSWindow (Sizing) 

- (void)setFrameToFitContentViewThenDisplay:(BOOL)display ;

- (void)setFrameToFitContentThenDisplay:(BOOL)display ;

#if 0
/*!
 @brief    Returns the current height of the window's toolbar

 @details  
 @result   
*/
- (CGFloat)toolbarHeight ;
#endif

/*!
 @brief    Returns the current height of the window's title bar
 plus that of the window's toolbar
 
 @details  
 @result   
 */
- (CGFloat)tootlebarHeight ;

@end

