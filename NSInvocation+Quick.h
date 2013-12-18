#import <Cocoa/Cocoa.h>

@interface NSObject (PerformInvocation)

// This is handy to use in -performSelectorOnMainThread:withObject:waitUntilDone:
- (void)performInvocation:(NSInvocation*)invocation ;

@end


/*!
 @brief    A category on NSInvocation to return a simple invocation without much code.

 @details  I use NSInvocation just often enough to be dangerous.  Using this
 category greatly reduces the time I need to spend refreshing myself with the
 documentation and troubleshooting crashes.
 
 Notes on the 'retainArguments':
 
 Passing -retainArguments:YES invokes -retainArguments on the invocation
 after creating it.  Apple does not explain this very well, so I
 shall.  This causes the invocation to retain its object arguments
 and target as instance variables, and also to make copies of some non-object
 arguments.  (See below for definition of "some").  The retained
 items will be released when the invocation is released.  You should
 <b>not</b> release them in order to "balance" this "retain", because it is
 not <i>your</i> retain.
 
 That being said, I always pass retainArguments:YES.  The only reason
 I could think of not to do it would be to eliminate redundant memory copying,
 if you have large non-object arguments which are not going to go away during
 the lifetime of the invocation.
 
 Note that this will not retain all argument types.  See the 10.5 Cocoa
 Foundation release notes
 http://developer.apple.com/releasenotes/Cocoa/Foundation.html and search for
 text 'retainArguments'  Since this link may break or be different when
 10.6 is released, I've copied all the text and pasted it in below.
 
 In 10.5, NSInvocation does not retain arguments or return values, unless
 -retainArguments is called on it.  The primary purpose of -retainArguments
 is to cause the receiving invocation to copy or hold onto certain types of
 arguments as long as the invocation survives.  You would do this if you are
 saving invocations for later use, or any use on another thread.  For example,
 you would generally want to use this even if synchronously waiting on one
 thread for an invocation to finish being invoked on another, since the
 autorelease pools and garbage collector on the other thread are cleaning up
 objects asynchronously with the waiting thread.
 
 Unfortunately, there is too much ambiguity and historical compatibility in
 the Objective C language and libraries for NSInvocation to "get this right"
 all the time for everybody.  For example, for some methods, you may want a
 pointer return value preserved and returned unchanged, and for others, you
 might want the pointed-to items to be copied shallowly, or at other times
 deeply, in order to preserve the data being pointed to.  In different contexts,
 you may even want different behaviors from NSInvocation for the same method
 being invoked.  So NSInvocation implements some generic generally useful
 behaviors.  Some of these behaviors may vary from those on 10.4 and earlier,
 which were a little more ad hoc.
 
 In 10.5, the candidate types for retention are Objective C object [pointer]
 types, fixed-length arrays, and C strings.  Note that there is an inherent
 ambiguity in the type "char *", which can variously mean, in Objective C,
 "pointer to single char", "pointer to array of char of some known length", and
 "pointer to null-terminated array of char".  The Objective C compiler and
 runtime have historically chosen to interpret "char *" (and variations) as a
 C string (null-terminated array) pointer, and this tradition continues.  You
 cannot use the other two interpretations with anything that uses the runtime
 type metadata, such as forwarding (NSInvocations) or key-value coding.
 
 For Objective C object [pointer] types, like "NSArray *", the parameter and
 return objects are retained when -retainArguments has been invoked.  For
 fixed-length arrays not embedded in a struct, the array is copied, and the
 pointer to the copy becomes the new argument or return value.  For C strings,
 the C string is copied, and the pointer to the copy becomes the new argument
 or return value.  NSInvocation also, recursively, retains (or copies) the
 Objective C object and C string types within C struct and C array arguments
 and return values (fixed-length arrays embedded within a struct are part of the
 struct).
 
 Other pointer uses are not candidates for retention.  For example, if a method
 takes an "int *" argument, NSInvocation takes no action (even when
 -retainArguments has been called) to copy/preserve the int which that pointer
 is pointing to.  If you manually set that argument (-setArgument:atIndex:), you
 set the pointer only, not [also] the value being pointed to (and of course,
 since the first argument to -setArgument:atIndex: is a pointer to the value
 to be set, it should be a pointer to the pointer-to-int to be set, not the
 pointer-to-int itself).  This non-copying behavior is generally desireable,
 since you usually don't want NSInvocation to attempt to copy a FILE * or a C++
 object (which, as far as the Objective C runtime is concerned, is just a
 pointer to a struct, and no copy constructor would be invoked) parameter or
 return value.
 
 Arithmetic types are naturally preserved/copied due to their simple nature,
 when set or captured as part of forwarding or NSInvocation invocation.
 Structs passed by value are also preserved/copied when -retainArguments has
 been invoked.
 
 Note that for an invocation object that has been told to -retainArguments,
 which has arguments set on it multiple times, or is invoked multiple times,
 accumulates those retainable arguments and return values, and holds them for
 the lifetime of the invocation.
 
 For a somewhat higher degree of safety/compatibility, for applications linked
 on or before 10.4, NSInvocations automatically retain return values after
 -invoke.
*/

@interface NSInvocation (Quick)

/*!
 @brief    Convenience method for returning a simple invocation

 @details  The invocation's arguments are supplied to this method as a variable
 number of arguments (varargs) list.&nbsp; Each element in the list may be
 which may be the address of an object, the address of a non-object, or NULL.
 
 This elements in the va_arg-style list beginning with firstArgumentAddress
 may point to any mixture of objects, nil objects or non-objects.
 <ul>
 <li>For objects, add a pointer to a pointer -- an NSSomeObject** -- to the list.</li>
 <li>For a nil object argument, add a NULL to the list.&nbsp; The method will detect this
 and apply special handling.</li>
 <li>For non-objects, add the address of the variable to the list.</li>
 </ul>
 Example:  Consider invoking a method declared as:
 -(id)myMethodWithArg1:(id)arg1 arg2:(NSDictionary*) arg3:(int)arg3 ;
 with these arguments:
 id arg1 = @"Hello" ;
 id arg2 = nil ;
 int arg3 = 5 ;
 The list of argumentAddresses would be: &arg1, NULL, &arg3
 
 If there no arguments, pass NULL.&nbsp; (It will be ignored.)
 
 This method knows how many arguments to read from the list by creating a method
 signature of 'selector'.  It reads that many arguments from the list and
 ignores any further arguments. A NULL sentinel termination is therefore
 not required.
 
 However, the flip side of this is that you must provide as many arguments in
 argumentAddresses as the method signature of 'selector' requires.  If an
 argument is not known yet, pass a NULL placeholder.  The reason is that these
 arguments will be 'set' into the invocation and thus may be sent messages if
 the method signature indicates that they are objects.
 
 If, after creating an invocation using this method, you want to modify an
 argument, you can do so by invoking -setArgument:atIndex:.  But when doing so,
 remember that argument indexes start at 2.  For example, to modify the first\
 argument, pass atIndex:2.
 
 Also remember that, per NSInvocation documentation, none of the the parameters
 of the selector being invoked may themselves be a va_arg argument list, nor a
 union.
 
 Returns nil if either param 'target' is nil or if param 'selector' is NULL.
 
 @param    target  The object which will receive the invocation when it is invoked.
 @param    selector  The selector that will be invoked when the invocation is invoked.
 @param    retainArguments.&nbsp;  See notes in class documentation.   
 @param    firstArgumentAddress  A va_args-style list of the addresses of the arguments
 passed to the selector when the invocation is invoked, or NULL.  See Details above for
 important requirements.
 @result   The invocation is returned so that you can get a return value
 in case it returns one.&nbsp; Send -getReturnValue to it.
 */
+ (NSInvocation*)invocationWithTarget:(id)target
							 selector:(SEL)selector
					  retainArguments:(BOOL)retainArguments
					argumentAddresses:(void*)firstArgumentAddress, ... ;

/*!
 @brief    Invokes (performs) the receiver on the main thread, similar to
 -[NSObject performSelectorOnMainThread:::]
 
 @details  Hint: Use NSInvocation+Quick to make invocations quickly and
 easily.
 
 If waitUntilDone is NO, this method returns nil immediately.&nbsp; 
 In that case, you can get the return value later by sending
 -getReturnValue to the invocation.
 
 <i>How it works.</i>&nbsp; This method invokes the desired selector on
 the main thread by using
 -performSelectorOnMainThread:withObject:waitUntilDone:.
 
 @param    waitUntilDone  YES if you would like to wait until
 the invocation performance is complete, otherwise NO.
 */
- (void)invokeOnMainThreadWaitUntilDone:(BOOL)waitUntilDone ;

/*!
 @brief    Creates an invocation and with given parameters and immediately
 invokes it on the main thread.

 @details  This method is a concatenation of the code in
 +invocationWithTarget:selector:retainArguments:argumentAddresses:
 followed by -invokeOnMainThreadWaitUntilDone:.&nbsp; For information
 see those methods.
 @param    retainArguments.&nbsp;  See notes in class documentation.   
*/
+ (NSInvocation*)invokeOnMainThreadTarget:(id)target
								 selector:(SEL)selector
						  retainArguments:(BOOL)retainArguments
							waitUntilDone:(BOOL)waitUntilDone
						argumentAddresses:(void*)firstArgumentAddress, ... ;

- (void)invokeOnNewThread ;

@end
