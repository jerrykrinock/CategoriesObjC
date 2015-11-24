// ©2015 Electro-Diagnostic Imaging, Inc.


#import <Foundation/Foundation.h>

/*!
 @brief    Workarounds for the fact that, in Xcode 6+,  the various
 -[NSObject performSelector:…] methods cause warnings of the form
 "PerformSelector may cause a leak because its selector is unknown"
 
 @details  Very sad that Apple feels it is necessary to put the training
 wheels on Objectrive-C.  The methods in this category are adapted from these
 two posts:
 
 http://stackoverflow.com/questions/7017281/performselector-may-cause-a-leak-because-its-selector-is-unknown
 http://stackoverflow.com/questions/21433873/performselector-may-cause-a-leak-because-its-selector-is-unknown-in-singleton-cl
 
 Be sure to use the correct method depending on whether your selector 
 returns id or void.
 */
@interface NSObject (RecklessPerformSelector)

- (void)recklessPerformVoidSelector:(SEL)selector ;

- (id)recklessPerformSelector:(SEL)selector ;

- (void)recklessPerformVoidSelector:(SEL)selector
                             object:(id)object ;

- (id)recklessPerformSelector:(SEL)selector
                       object:(id)object ;

- (void)recklessPerformVoidSelector:(SEL)selector
                             object:(id)object1
                             object:(id)object2 ;

- (id)recklessPerformSelector:(SEL)selector
                       object:(id)object1
                       object:(id)object2 ;

@end
