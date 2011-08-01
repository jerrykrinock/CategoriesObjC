@interface NSObject (SafeSending)

/* This method may be used to safely send a message to the
 superclass of an instance, when you are not sure whether
 or not the selector is defined in any of the superclasses.
 The argument list "firstArg, ..." must end with a nil.
 Limitation: Selector must return void or an id. */
/*!
 @brief    Sends a message to the receiver's super, after first
 checking to see that super responds.

 @details  If the receiver's super does not respond, nothing happens.
 @param    selector  The selector to be performed.  May be NULL,
 which will, of course, create a no-op.  The selector must
 take 0 or 1 arguments of type id and return either void or
 an id.
 @param    firstArg,  The first argument to the selector, or nil
 if the selector does not take any arguments
 @param    ...  varargs list, must end with nil sentinel
 @result   The object returned by the selector
*/
- (id)safelySendSuperSelector:(SEL)selector
					arguments:firstArg, ... ;

/*!
 @brief    Performs a selector with one object argument after
 first checking to see that the receiver responds

 @details  If the receiver does not respond, nothing happens.
 @param    selector  The selector to be performed.  May be NULL,
 which will, of course, create a no-op.  The selector must
 take 0 or 1 arguments of type id and return either void or
 an id.
 @param    object  The single argument of the selector.  May
 be nil.  Should be nil if selector takes 0 arguments.
 @result   The object returned by the selector
*/
- (id)safelyPerformSelector:(SEL)selector
				 withObject:(id)object ;


/*!
 @brief    Returns whether or not the receiver (a class object)
 has overridden any superclass' implementation of a given selector.
 
 @details  By "any superclass", we mean the immediate superclass, the
 superclass' superclass, the superclass' superclass' superclass, etc.
 If the receiver's superclass does not respond to the given
 selector, returns NO.
 If the receiver does not respond to the given selector, returns NO.
 If the receiver is the NSObject class, returns NO, because the
 concept of "override" does not apply if there is no superclass.
 
 TEST CODE FOR THIS METHOD

 Class class ;
 SEL selector ;
 
 class = [NSObject class] ;
 selector = @selector(description) ;
 NSLog(@"%@ has%@ overridden %@", NSStringFromClass(class), [class hasOverridden:selector] ? @"" : @" not", NSStringFromSelector(selector)) ;
 
 class = [NSString class] ;
 selector = @selector(initWithString:) ;
 NSLog(@"%@ has%@ overridden %@", NSStringFromClass(class), [class hasOverridden:selector] ? @"" : @" not", NSStringFromSelector(selector)) ;
 
 class = [Extore class] ;
 selector = @selector(description) ;
 NSLog(@"%@ has%@ overridden %@", NSStringFromClass(class), [class hasOverridden:selector] ? @"" : @" not", NSStringFromSelector(selector)) ;
 
 class = [Extore class] ;
 selector = @selector(installOwnerAddonError_p:) ;
 NSLog(@"%@ has%@ overridden %@", NSStringFromClass(class), [class hasOverridden:selector] ? @"" : @" not", NSStringFromSelector(selector)) ;
 
 class = [ExtoreLocalJson class] ;
 selector = @selector(installOwnerAddonError_p:) ;
 NSLog(@"%@ has%@ overridden %@", NSStringFromClass(class), [class hasOverridden:selector] ? @"" : @" not", NSStringFromSelector(selector)) ;
 
 class = [ExtoreFirefox class] ;
 selector = @selector(installOwnerAddonError_p:) ;
 NSLog(@"%@ has%@ overridden %@", NSStringFromClass(class), [class hasOverridden:selector] ? @"" : @" not", NSStringFromSelector(selector)) ;
 
 class = [ExtoreSafari class] ;
 selector = @selector(installOwnerAddonError_p:) ;
 NSLog(@"%@ has%@ overridden %@", NSStringFromClass(class), [class hasOverridden:selector] ? @"" : @" not", NSStringFromSelector(selector)) ;
 
 class = [ExtoreSafari class] ;
 selector = @selector(foobar) ;
 NSLog(@"%@ has%@ overridden %@", NSStringFromClass(class), [class hasOverridden:selector] ? @"" : @" not", NSStringFromSelector(selector)) ;
*/
+ (BOOL)hasOverridden:(SEL)selector  ;

@end

