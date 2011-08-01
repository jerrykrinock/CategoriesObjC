#import <Cocoa/Cocoa.h>


@interface NSDictionary (Readable)

/*!
 @brief    Returns a string of the form "key: value", containing
 -description of key and value, separated by newlines.

 @details  You can't use this in a binding key path, probably
 because bindings interprets the key path myDictionary.readable
 to be [myDictionary objectForKey:@"readable"].  For bindings,
 therefore, use SSYTransformDicToString
*/
- (NSString*)readable ;

@end
