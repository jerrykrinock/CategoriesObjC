#import <Cocoa/Cocoa.h>


@interface NSObject (SSYBindingsHelp)

/*!
 @brief    Pushes a given value through to any bound model object
 which may exist for a given key

 @details  This is typically used in control classes to implement
 the "reverse" binding when the user changes the control value, 
 pushing the new value into the data model.  It may be invoked in
 -mouseDown:, -keyDown:, -controlTextDidEndEditing.  Invoking it
 in a custom setter causes unnecessary pushing to occur whenever,
 say, a selection in a table is changed.  Besides wasted CPU cycles,
 this can cause model values to be copied from one model object
 to another when changing selection if, for example, your control
 supports multiple selections.
 See discussion with Quincey Morris:
 http://lists.apple.com/archives/cocoa-dev/2012/Jun/msg00460.html
*/
- (void)pushBindingValue:(id)value
				  forKey:(NSString*)key ;

@end
