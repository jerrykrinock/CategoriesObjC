#import "NSUndoManager+SSYAdds.h"
#import "NSObject+MoreDescriptions.h"
#import <objc/runtime.h>

//#warning Cannot get away with this if > 1 Undo Manager in app:
//static NSInteger gSeqNum = 0 ;
//static BOOL badBegin = NO ;
//static BOOL badEnd = NO ;

@implementation NSUndoManager (SSYAdds)


- (void)logUndoStack {
	// So I can write readable code without compiler warnings and errors...
#define _NSUndoStack NSObject
#define _NSUndoObject NSObject
#define _NSUndoInvocation NSObject
#define _NSUndoLightInvocation NSObject
#define _NSUndoBeginMark NSObject
#define _NSUndoEndMark NSObject
	NSMutableString* msg ;
	if ([self respondsToSelector:@selector(_undoStack)]) {
		_NSUndoStack* undoStack = [self performSelector:@selector(_undoStack)] ;
		msg = [NSMutableString stringWithFormat:
			   @"\nCurrent Undo Stack for %@:\n  count:%d  nestingLevel:%d  max:%d",
			   self,
			   [undoStack performSelector:@selector(count)],
			   [undoStack performSelector:@selector(nestingLevel)],
			   [undoStack performSelector:@selector(max)]] ;
		_NSUndoObject* object = [undoStack performSelector:@selector(topUndoObject)] ;
		NSInteger iObject = 0 ;
		while (object) {
			[msg appendFormat:@"\nUndo Stack Object at index %d is of class %@:\n",
			 iObject,
			 [object class]] ;
			if ([object isKindOfClass:NSClassFromString(@"_NSUndoInvocation")]) {
				[msg appendString:[[object valueForKeyPath:@"invocation"] longDescription]] ;
			}
			else if ([object isKindOfClass:NSClassFromString(@"_NSUndoLightInvocation")]) {
				[msg appendFormat:
				 @"%@  arg details:\n%@",
				 [object description],
				 [[object valueForKeyPath:@"arg"] shortDescription]] ;
			}
			else if ([object performSelector:@selector(isBeginMark)]) {
				[msg appendFormat:
				 @"beginning group with groupIdentifier:%@",
				 [[object valueForKeyPath:@"groupIdentifier"] description]] ;
			}
			object = [object valueForKeyPath:@"next"] ;
			iObject++ ;
		}
	}
	else {
		msg = @"Tried to log undo stack but private _undoStack is not accessible on this system.  "
			@"Probably time for another classdump." ;
	}
	
	NSLog(msg) ;
	
#undef _NSUndoStack
#undef _NSUndoInvocation
#undef _NSUndoLightInvocation
#undef _NSUndoBeginMar
#undef _NSUndoEndMark
}


#if 0
+ (void)load {
	NSLog(@"122 %s", __PRETTY_FUNCTION__) ;
	Method originalMethod ;
	Method replacedMethod ;

	// Swap the implementations of one method with another.
	// When the message Xxx is sent to the object (either instance or class),
	// replacement_Xxx will be invoked instead.  Conversely,
	// replacement_Xxx will invoke Xxx.

	originalMethod = class_getInstanceMethod(self, @selector(beginUndoGrouping)) ;
	replacedMethod = class_getInstanceMethod(self, @selector(replacement_beginUndoGrouping)) ;
	method_exchangeImplementations(originalMethod, replacedMethod) ;

	originalMethod = class_getInstanceMethod(self, @selector(endUndoGrouping)) ;
	replacedMethod = class_getInstanceMethod(self, @selector(replacement_endUndoGrouping)) ;
	method_exchangeImplementations(originalMethod, replacedMethod) ;
		 
	originalMethod = class_getInstanceMethod(self, @selector(setActionName:)) ;
	replacedMethod = class_getInstanceMethod(self, @selector(replacement_setActionName:)) ;
	method_exchangeImplementations(originalMethod, replacedMethod) ;
 
	originalMethod = class_getInstanceMethod(self, @selector(disableUndoRegistration)) ;
	replacedMethod = class_getInstanceMethod(self, @selector(replacement_disableUndoRegistration)) ;
	method_exchangeImplementations(originalMethod, replacedMethod) ;
	
	originalMethod = class_getInstanceMethod(self, @selector(enableUndoRegistration)) ;
	replacedMethod = class_getInstanceMethod(self, @selector(replacement_enableUndoRegistration)) ;
	method_exchangeImplementations(originalMethod, replacedMethod) ;
	
	originalMethod = class_getInstanceMethod(self, @selector(undoNestedGroup)) ;
	replacedMethod = class_getInstanceMethod(self, @selector(replacement_undoNestedGroup)) ;
	method_exchangeImplementations(originalMethod, replacedMethod) ;
	
	originalMethod = class_getInstanceMethod(self, @selector(undo)) ;
	replacedMethod = class_getInstanceMethod(self, @selector(replacement_undo)) ;
	method_exchangeImplementations(originalMethod, replacedMethod) ;
}


- (void)replacement_beginUndoGrouping {
	if (self == [[[NSDocumentController sharedDocumentController] currentDocument] undoManager]) {
		NSLog(@"WILL beginUndoGrouping gsn=%d %@", gSeqNum, self) ;
		NSInteger oldLevel = [self groupingLevel] ;
		if (badBegin) {
			/*DB?Line*/ NSLog(@"Bad Jump in %s", __PRETTY_FUNCTION__) ;
		}
		badBegin = YES ;
		[self replacement_beginUndoGrouping] ;
		NSLog(@" DID beginUndoGrouping gsn=%d %d->%d %@", gSeqNum, oldLevel, [self groupingLevel], self) ;
		badBegin = NO ;
		gSeqNum++ ;
	}
	else {
		[self replacement_beginUndoGrouping] ;
	}
}

- (void)doDeferred_endUndoGrouping {
	/*DB?Line*/ NSLog(@"WILL endddUndoGrouping (deferred) %@", self) ;
	NSInteger oldLevel = [self groupingLevel] ;
	[self replacement_endUndoGrouping] ;
	/*DB?Line*/ NSLog(@" DID endddUndoGrouping (deferred) %d->%d %@", oldLevel, [self groupingLevel], self) ;
}

- (void)replacement_endUndoGrouping {
	if (self == [[[NSDocumentController sharedDocumentController] currentDocument] undoManager]) {
		NSLog(@"WILL endddUndoGrouping gsn=%d %@", gSeqNum, self) ;
		NSInteger oldLevel = [self groupingLevel] ;
		BOOL ok = YES ;
		if (badEnd) {
			/*DB?Line*/ NSLog(@"Bad Jump in %s", __PRETTY_FUNCTION__) ;
			ok = NO ;
		}
		badEnd = YES ;
		if (ok) {
			[self replacement_endUndoGrouping] ;
			NSLog(@" DID endddUndoGrouping gsn=%d %d->%d %@", gSeqNum, oldLevel, [self groupingLevel], self) ;
		}
		else {
			[self performSelector:@selector(doDeferred_endUndoGrouping)
					   withObject:nil
					   afterDelay:0.0] ;
			NSLog(@" DEFERRED endddUndoGrouping gsn=%d %d->%d %@", gSeqNum, oldLevel, [self groupingLevel], self) ;
		}
		badEnd = NO ;
	}
	else {
		[self replacement_endUndoGrouping] ;
	}
	return ;
}

// Note that, in NSUndoManager, "no action name" is represented
// by setting actionName to an empty string, not to nil.
- (void)replacement_setActionName:(NSString*)name {
	NSLog(@"Setting action name in %p to %@", self, name) ;
	[self replacement_setActionName:name] ;
	return ;
	
	if ([[self undoActionName] length] == 0) {
		NSLog(@"270: Setting action name to %@", name) ;
		[self replacement_setActionName:name] ;
	}
	else {NSLog(@"366: NOT setting action name to %@", name) ;}
}

- (void)replacement_disableUndoRegistration {
	if (self == [[[NSDocumentController sharedDocumentController] currentDocument] undoManager]) {
		NSLog(@"WILL disableUndoRegistration for %@", self) ;
		[self replacement_disableUndoRegistration] ;
	}
	else {
		[self replacement_disableUndoRegistration] ;
	}
	return ;
	
}

- (void)replacement_enableUndoRegistration {
	if (self == [[[NSDocumentController sharedDocumentController] currentDocument] undoManager]) {
		NSLog(@"WILL enableUndoRegistration for %@", self) ;
		[self replacement_enableUndoRegistration] ;
	}
	else {
		[self replacement_enableUndoRegistration] ;
	}
	return ;
	
}

- (void)replacement_undoNestedGroup {
	if (self == [[[NSDocumentController sharedDocumentController] currentDocument] undoManager]) {
		NSLog(@"WILL undoNestedGroup for %@", self) ;
		[self replacement_undoNestedGroup] ;
	}
	else {
		[self replacement_undoNestedGroup] ;
	}
	return ;
	
}

- (void)replacement_undo {
	if (self == [[[NSDocumentController sharedDocumentController] currentDocument] undoManager]) {
		NSLog(@"WILL undo for %@", self) ;
		[self replacement_undo] ;
	}
	else {
		[self replacement_undo] ;
	}
	return ;
	
}

- (void)reallyEndUndoGrouping {
	NSLog(@"872 Will really end Undo Grouping with groupingLevel=%d", [self groupingLevel]) ;
	[self replacement_endUndoGrouping] ;
	NSLog(@"874 Did really end undo grouping with groupingLevel = %d", [self groupingLevel]) ;
}
#endif

@end
