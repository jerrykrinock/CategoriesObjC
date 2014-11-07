#import <Cocoa/Cocoa.h>

@interface NSTableView (Scrolling)

- (NSRect)visibleRowsRect ;

- (void)scrollRowToTop:(NSInteger)row
       plusExtraPoints:(CGFloat)extraPoints ;

@end
