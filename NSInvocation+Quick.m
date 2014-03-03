 // We need the address of nil object which will never go away.
// But Cocoa cannot retain such an object since [nil retain] is a no-op.
// So we use a static variable...
static NSObject* gNil = nil ;


@implementation NSInvocation (Quick)


+ (NSInvocation*)invocationWithTarget:(id)target
							 selector:(SEL)selector
					  retainArguments:(BOOL)retainArguments
					argumentAddresses:(void*)firstArgumentAddress, ...  {
	NSInvocation* invoc = nil ;
	
	if ((target != nil) && (selector != NULL)) {
		NSMethodSignature* methSig = [target methodSignatureForSelector:selector] ;
		if (methSig == nil) {
			NSString* msg = [NSString stringWithFormat:@"No method signature for selector %@ in %@", NSStringFromSelector(selector), target] ;
			NSLog(@"Internal Error 232-0843 %@", msg) ;
		}
		invoc = [NSInvocation invocationWithMethodSignature:methSig] ;
		[invoc setTarget:target] ;
		[invoc setSelector:selector] ;
		void* address ;
		va_list argumentList;
		if (firstArgumentAddress) {
			address = firstArgumentAddress ;
		}
		else {
			address = &gNil ;
		}
		
		if ([methSig numberOfArguments] > 2) {
			// First two arguments at Indices 0 and 1 indicate the hidden arguments self and _cmd
			// So, we start at index 2
			[invoc setArgument:address atIndex:2] ;
			// The following loops executes if selector takes > 1 argument
			if ([methSig numberOfArguments] > 3) {
				va_start(argumentList, firstArgumentAddress) ;
				NSInteger i ;
				for (i=3; i<[methSig numberOfArguments]; i++) { 
					address = va_arg(argumentList, void*) ;
					if (!address) {
						address = &gNil ;
					}
					[invoc setArgument:address
							   atIndex:i] ;
				}
				va_end(argumentList) ;
			}
		}
		
		if (retainArguments) {
			[invoc retainArguments] ;
		}
	}
	
	return invoc ;
}

- (void)invokeOnMainThreadWaitUntilDone:(BOOL)waitUntilDone {
	[self performSelectorOnMainThread:@selector(invoke)
						   withObject:nil
						waitUntilDone:waitUntilDone] ;
}

+ (NSInvocation*)invokeOnMainThreadTarget:(id)target
								 selector:(SEL)selector
						  retainArguments:(BOOL)retainArguments
							waitUntilDone:(BOOL)waitUntilDone
						argumentAddresses:(void*)firstArgumentAddress, ... {
	// The reason why I don't simply forward most of these arguments on to
	//  +invocationWithTarget:selector:retainArguments:argumentAddresses:
	// is because C does not allow forwarding a va_list to another function.
	// http://groups.google.com/group/gnu.gcc.help/browse_thread/thread/c4a6b74860b0899f/cbd1f71fd1613b7d?lnk=gst&q=va_arg#
	// I could just run through the va_list here, but that's > 1/2 the damned method.
	// So, instead, I have copied and pasted the code from the other two methods.
	
	// Copy and paste (without comments) from
	//   +invocationWithTarget:selector:retainArguments:argumentAddresses:
	NSMethodSignature* methSig = [target methodSignatureForSelector:selector] ;

	NSInvocation* invoc = [NSInvocation invocationWithMethodSignature:methSig] ;
	[invoc setTarget:target] ;
	[invoc setSelector:selector] ;
	void* address ;
	va_list argumentList;
	if (firstArgumentAddress) {
		address = firstArgumentAddress ;
	}
	else {
		address = &gNil ;
	}

	if ([methSig numberOfArguments] > 2) {
		// First two arguments at Indices 0 and 1 indicate the hidden arguments self and _cmd
		// So, we start at index 2
		[invoc setArgument:address atIndex:2] ;
		// The following loops executes if selector takes > 1 argument
		if ([methSig numberOfArguments] > 3) {
			va_start(argumentList, firstArgumentAddress) ;
			NSInteger i ;
			for (i=3; i<[methSig numberOfArguments]; i++) { 
				address = va_arg(argumentList, void*) ;
				if (!address) {
					address = &gNil ;
				}
				[invoc setArgument:address atIndex:i] ;
			}
			va_end(argumentList) ;
		}
	}

	if (retainArguments) {
		[invoc retainArguments] ;
	}
	
	// Copy and paste from
	//   -invokeOnMainThreadWaitUntilDone:
	[invoc performSelectorOnMainThread:@selector(invoke)
							withObject:nil
						 waitUntilDone:waitUntilDone] ;
	
	// Something original
	return invoc ;
}

+ (void)invokeWithAutoreleasePoolInvocation:(NSInvocation*)invocation {
#if NO_ARC
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init] ;
#endif
	[invocation invoke] ;
#if NO_ARC
	[pool release] ;
#endif
}

- (void)invokeOnNewThread {
	[NSThread detachNewThreadSelector:@selector(invokeWithAutoreleasePoolInvocation:)
							 toTarget:[NSInvocation class]
						   withObject:self] ;
}


@end