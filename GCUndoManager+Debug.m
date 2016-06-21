#import "GCUndoManager+Debug.h"

#if GCUNDOMANAGER_DEBUG

// Note: You get the ivar offset from running
//    otool -ov  "/System/Library/Frameworks/AppKit.framework/AppKit" > ~/Desktop/AppKitClassDump.txt
// and searching the result for _changeCount in the NSDocument section.  It gives and "offset".
#define _CHANGE_COUNT_IVAR_OFFSET 0x00000018
// Unfortunately, the above only works ok macOS 10.6.
// In 10.7 and and 10.8, NSDocument no longer has a _changeCount.  Kyle Sluder
// says it was replaced by the "change token infrastructure".  Probably, he
// means this stuff…
//    -[NSDocument updateChangeCountWithToken:forSaveOperation:]
//    -[NSDocument changeCountTokenForSaveOperation:]
@interface NSDocument (SSYDebugChangeAndUndo)
@end

@implementation NSDocument (SSYDebugChangeAndUndo)

- (NSInteger)changeCount {
	// Must cast pointers to integers before adding or they
	// get multiplied by sizeof() their type.
	return *(NSInteger*)((NSInteger)self + (NSInteger)_CHANGE_COUNT_IVAR_OFFSET) ;
}

+ (void)load {
	// Swap the implementations of one method with another.
	// When the message Xxx is sent to the object (either instance or class),
	// replacement_Xxx will be invoked instead.  Conversely,
	// replacement_Xxx will invoke Xxx.
	
	// NOTE: Below, use class_getInstanceMethod or class_getClassMethod as appropriate!!
	Method originalMethod = class_getInstanceMethod(self, @selector(updateChangeCount:)) ;
	Method replacedMethod = class_getInstanceMethod(self, @selector(replacement_updateChangeCount:)) ;
	method_exchangeImplementations(originalMethod, replacedMethod) ;
	NSLog(@"Replaced -updateChangeCount in %@ for debugging.", [self class]) ;
}

- (void)replacement_updateChangeCount:(NSDocumentChangeType)changeType {
	NSInteger oldChangeCount = [self changeCount] ;
	// Due to the swap, this calls the original method
	[self replacement_updateChangeCount:changeType] ;
	NSInteger newChangeCount = [self changeCount] ;
	NSString* changeDesc ;
	switch (changeType) {
		case NSChangeDone:
			changeDesc = @"Do" ;
			break;
		case NSChangeUndone:
			changeDesc = @"Undo" ;
			break;
		case NSChangeCleared:
			changeDesc = @"Clear" ;
			break;
		case NSChangeReadOtherContents:
			changeDesc = @"ReadOther" ;
			break;
		case NSChangeAutosaved:
			changeDesc = @"Autosave" ;
			break;
		case NSChangeRedone:
			changeDesc = @"Redo" ;
			break;
		default:
			changeDesc = @"Undef" ;
			break;
	}
	NSLog(@"Did change type %@.  changeCount: %ld:%ld",
		  changeDesc,
		  (long)oldChangeCount,
		  (long)newChangeCount) ;
}

@end

@interface GCUndoTask (Debug)

- (NSInteger)depth ;

@end

@implementation GCUndoTask (Debug)

- (NSString*)lineage {
	GCUndoTask* parent = self ;
	NSMutableString* lineage = [NSMutableString stringWithString:@"-(self)"] ;
	do {
		NSString* s = [NSString stringWithFormat:@"-%p", parent] ; 
		[lineage insertString:s
					   atIndex:0] ;
	} while ((parent = [parent parentGroup]) != nil) ;
	[lineage insertString:@"(root ancestor)"
				  atIndex:0] ;
	return [NSString stringWithString:lineage] ;
}

- (NSInteger)depth {
	NSInteger depth = 0 ;
	GCUndoTask* parent = self ;
	while ((parent = [parent parentGroup]) != nil) {
		depth++ ;
	}
	
	return depth ;
}

@end

@implementation GCConcreteUndoTask (Debug)

- (NSString*)descriptionWithSelector:(SEL)selector {
	NSString* targetClause ;
	if (selector == @selector(shortDescription)) {
		targetClause = [[self target] className] ;
	}
	else {
		// The invocation's longDescription will show the target,
		// so we don't want to show it twice
		targetClause = @"" ;
	}
		
	return [NSString stringWithFormat:@"<%@ %p %@%p> invocn=%@>",
			[self className],
			self,
			targetClause,
			[self target],
			[mInvocation performSelector:selector]] ;
}

- (NSString*)shortDescription {
	return [self descriptionWithSelector:@selector(shortDescription)] ;	
}

- (NSString*)longDescription {
	return [self descriptionWithSelector:@selector(longDescription)] ;	
}

@end

@implementation GCUndoGroup (Debug)

- (NSString*)descriptionWithSelector:(SEL)selector {
	NSInteger count = [mTasks count] ;
	NSInteger depth = [self depth] ;
	NSMutableString* indentation = [NSMutableString string] ;
	NSInteger i ;
	for (i=0; i<depth; i++) {
		[indentation appendString:@"   "] ;
	}
	
	NSMutableString* ms = [NSMutableString stringWithFormat:
						   @"<%@ %p actionName='%@' %ld tasks at depth %ld",
						   [self className],
						   self,
						   [self actionName],
						   (long)count,
						   (long)depth] ;
	for (i=0; i<count; i++) {
		[ms appendFormat:
		 @"\n%@%p's Task %ld/%ld: %@",
		 indentation,
		 self,
		 (long)i,
		 (long)count,
		 [[self taskAtIndex:i] performSelector:selector]] ;
	}
	[ms appendString:@"\n>"] ;
	
	return [NSString stringWithString:ms] ;
}

- (NSString*)shortDescription {
	return [self descriptionWithSelector:@selector(shortDescription)] ;	
}

- (NSString*)longDescription {
	return [self descriptionWithSelector:@selector(longDescription)] ;	
}

@end

@implementation GCUndoManager (SSYDebug)

+ (void)load {
	// Swap the implementations of methods.
	// When the message Xxx is sent to the object (either instance or class),
	// replacement_Xxx will be invoked instead.  Conversely,
	// replacement_Xxx will invoke Xxx.
	
	// NOTE: Below, use class_getInstanceMethod or class_getClassMethod as appropriate!!
	Method originalMethod ;
	Method replacedMethod ;

	originalMethod = class_getInstanceMethod(self, @selector(beginUndoGrouping)) ;
	replacedMethod = class_getInstanceMethod(self, @selector(replacement_beginUndoGrouping)) ;
	method_exchangeImplementations(originalMethod, replacedMethod) ;

	originalMethod = class_getInstanceMethod(self, @selector(endUndoGrouping)) ;
	replacedMethod = class_getInstanceMethod(self, @selector(replacement_endUndoGrouping)) ;
	method_exchangeImplementations(originalMethod, replacedMethod) ;

	originalMethod = class_getInstanceMethod(self, @selector(removeAllActions)) ;
	replacedMethod = class_getInstanceMethod(self, @selector(replacement_removeAllActions)) ;
	method_exchangeImplementations(originalMethod, replacedMethod) ;
	
	NSLog(@"Replaced some methods in %@ for debugging.", [self class]) ;
}

- (NSString*)stateDescription {
	NSString* desc ;
	switch ([self undoManagerState]) {
		case kGCUndoCollectingTasks:
			desc = @"Collecting" ;
			break;
		case kGCUndoIsUndoing:
			desc = @"Undoing" ;
			break;
		case kGCUndoIsRedoing:
			desc = @"Redoing" ;
			break;
		default:
			desc = @"Undef" ;
			break;
	}
	
	return desc ;
}

- (NSDocument*)myDocument {
	NSArray* documents = [[NSDocumentController sharedDocumentController] documents] ;
	NSDocument* document = nil ;
	for (document in documents) {
		if ((GCUndoManager*)[document undoManager] == self) {
			break ;
		}
	}
	
	return document ;
}

// The undo manager state and grouping level are now exposed, thanks to GCUndoManager :)
- (void)replacement_beginUndoGrouping {
	NSInteger oldGroupingLevel =  [self groupingLevel] ;
	NSString* oldStateDescription = [self stateDescription] ;
	NSInteger oldChangeCount = [[self myDocument] changeCount] ;
	// Due to the swap, this calls the original method
	[self replacement_beginUndoGrouping] ;
	NSLog(@"began undo grp:  grpLvl: %ld:%ld  state: %@:%@  chgCnt: %ld:%ld",
		  (long)oldGroupingLevel,
		  (long)[self groupingLevel],
		  oldStateDescription,
		  [self stateDescription],
		  (long)oldChangeCount,
		  (long)[[self myDocument] changeCount]
		  ) ;
}

- (void)replacement_endUndoGrouping {
	NSInteger oldGroupingLevel =  [self groupingLevel] ;
	NSString* oldStateDescription = [self stateDescription] ;
	NSInteger oldChangeCount = [[self myDocument] changeCount] ;
	// Due to the swap, this calls the original method
	[self replacement_endUndoGrouping] ;
	NSLog(@"ended undo grp:  grpLvl: %ld:%ld  state: %@:%@  chgCnt: %ld:%ld",
		  (long)oldGroupingLevel,
		  (long)[self groupingLevel],
		  oldStateDescription,
		  [self stateDescription],
		  (long)oldChangeCount,
		  (long)[[self myDocument] changeCount]
		  ) ;
}

- (void)replacement_removeAllActions {
	NSLog(@">>> %s", __PRETTY_FUNCTION__) ;
	// Due to the swap, this calls the original method
	[self replacement_removeAllActions] ;
	NSLog(@"<<< %s", __PRETTY_FUNCTION__) ;
}

- (void)logPeekUndo {
	NSString* desc = [[self peekUndo] longDescription] ;
	NSLog(@"*** Begin logPeekUndo.  Top Undo Group: %@*** End logPeekUndo", desc) ;
}

@end

#endif
