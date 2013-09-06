#import "NSObject+MoreDescriptions.h"
#import "NSString+Truncate.h"

NSString* constIndentation = @"   " ;

@implementation NSObject (MoreDescriptions)

- (NSString*)longDescription {
	return [self description] ;
}

- (NSString*)shortDescription {
	/* The following truncation was added in BookMacster 0.9.33 and is the
	 performance bottleneck fix described in the release notes.  Prior to
	 adding the truncating, I got this sample stack from Activity Monitor:
	 100.000% -[SSYOperation(OperationImport) mergeImport_unsafe]  (was -readAndMerge)
	 100.000% -[Ixporter mergeFromStartainer:toStartainer:info:error_p:]
	 100.000% -[Stark overwriteAttributes:locals:mergeTags:fabricateTags:fromStark:]
	 100.000% -[NSManagedObject setValue:forKey:]
	 100.000% -[Stark setUrl:]
	 100.000% -[SSYManagedObject postWillSetNewValue:forKey:]
	 100.000% -[NSNotificationCenter postNotificationName:object:userInfo:]
	 100.000% _CFXNotificationPostNotification
	 100.000% __CFXNotificationPost
	 100.000% _nsnote_callback
	 100.000% -[BkmxDoc objectWillChangeNote:]
	 100.000% -[Chaker updateStark:key:oldValue:newValue:]
	 100.000% -[Stange registerUpdateKey:oldValue:newValue:fromDisplayName:]
	 100.000% -[NSString(ChangeLogging) localizedUpdateDescriptionsFromValue:toValue:fromDisplayName:]
	 100.000% +[NSString(LocalizeSSY) localizeFormat:]
	 100.000% +[NSString(LocalizeSSY) replacePlaceholdersInString:argPtr_p:]
	 100.000% -[NSMutableString(StuffINeed) replacePlaceholdersWithIndex:withSubstitutionFromVaArgPointer:]
	 100.000% -[NSConcreteScanner initWithString:]
	 100.000% -[NSCFString copyWithZone:]
	 100.000% CFStringCreateCopy
	 100.000% __CFStringCreateImmutableFunnel3
	 100.000% _CFRuntimeCreateInstance
	 100.000% __bzero
	 and what was happening there looked like CFStringCreateCopy was waiting for
	 an a memory allocation.  The +[NSString(LocalizeSSY) localizeFormat:]
	 occurred near the end of call occurred with format string "changeX3" near the end of
	 -[NSString(ChangeLogging) localizedUpdateDescriptionsFromValue:toValue:fromDisplayName:].
	 In the log of another run I saw that this was also where a memory
	 allocation failure of 30 MB in creating an NSString.  So apparently that
	 100.000% __bzero happened because __bzero was waiting for this allocation,
	 which possibly never came. Things don't quite add up though, because the URL
	 of the 1Password bookmarklet which was apparently causing the problem, because
	 it was the only long URL in there, was only 165 KB.  And also, why was there a
	 failure to allocate 30 MB?  Certainly 30 MB is alot, but not *that* much.
	 Anyhow, adding the following truncation here fixed things nicely. */
#if DEBUG
#define SHORT_DESCRIPTION_CHARACTER_LIMIT 2048
#else
#define SHORT_DESCRIPTION_CHARACTER_LIMIT 63
#endif
	return [[self description] stringByTruncatingMiddleToLength:SHORT_DESCRIPTION_CHARACTER_LIMIT
													 wholeWords:NO] ;
}

- (NSString*)deepNiceDescriptionIndentLevel:(NSInteger)indentLevel {
	NSMutableString* indentation = [NSMutableString string] ;
	NSInteger i ;
	for (i=0; i<indentLevel; i++) {
		[indentation appendString:constIndentation] ;
	}	
	
	NSString *dnd;
	NSString* countClause = @"" ;
	if ([self respondsToSelector:@selector(count)]) {
		countClause = [NSString stringWithFormat:
					   @" count=%ld ", (long)[(id)self count]] ;
	}
	NSString* valueClause ;
	if ([self respondsToSelector:@selector(keyEnumerator)]) {
		// arg is a dictionary
		NSMutableString* ms = [NSMutableString string] ;
		NSEnumerator* e = [(id)self keyEnumerator] ;
		id key ;
		while ((key = [e nextObject])) {
			id value = [(id)self objectForKey:key] ;
			[ms appendFormat:@"\n%@%@Key:%@ Value:<%@ %@>",
			 indentation,
			 constIndentation,
			 key,
			 [value className],
			 [(id)value deepNiceDescriptionIndentLevel:(indentLevel+1)]] ;
		}
		valueClause = ms ;
	}
	else if ([self respondsToSelector:@selector(objectEnumerator)]) {
		// arg is an array or set of some kind
		NSMutableString* ms = [NSMutableString string] ;
		NSEnumerator* e = [(id)self objectEnumerator] ;
		id object ;
		NSInteger i = 0 ;
		while ((object = [e nextObject])) {
			[ms appendFormat:@"\n%@%@item %ld:<%@> %@",
			 indentation,
			 constIndentation,
			 (long)i++,
			 [object className],
			 [(id)object deepNiceDescriptionIndentLevel:(indentLevel+1)]] ;
		}
		valueClause = ms ;
	}
	else if ([self isKindOfClass:[NSInvocation class]]) {
		// Use my -[NSInvocation longDescription] which is pretty nice
		valueClause = [NSString stringWithFormat:
					   @" value=%@", [self longDescription]] ;
	}
	else {
		valueClause = [NSString stringWithFormat:
					   @" value=%@", [self shortDescription]] ;
	}
	dnd = [NSString stringWithFormat:
		   @"<%@* %p>%@%@",
		   [self className],
		   self,
		   countClause,
		   valueClause] ;
	
	return dnd;
}

- (NSString*)deepNiceDescription {
	return [self deepNiceDescriptionIndentLevel:0] ;
}

@end

@implementation NSDictionary (MoreDescriptions)

- (NSString*)shortDescription {
	NSMutableString* s = [NSMutableString stringWithString:@"{\n"] ;
	for (id key in [self allKeys]) {
		[s appendFormat:
		 @"   %@ = %@\n",
		 [key shortDescription],
		 [[self objectForKey:key] shortDescription]] ;
	}
	
	[s appendString:@"}"] ;
	
	return [NSString stringWithString:s] ;
}

@end

@implementation NSArray (MoreDescriptions)

- (NSString*)shortDescription {
	NSMutableString* s = [NSMutableString stringWithString:@"{\n"] ;
	for (id object in self) {
		[s appendFormat:
		 @"   %@\n",
		 [object shortDescription]] ;
	}
	
	[s appendString:@"}"] ;
	
	return [NSString stringWithString:s] ;
}

- (NSString*)longDescription {
	NSMutableString* s = [NSMutableString stringWithString:@"{\n"] ;
	for (id object in self) {
		[s appendFormat:
		 @"   %@\n",
		 [object longDescription]] ;
	}
	
	[s appendString:@"}"] ;
	
	return [NSString stringWithString:s] ;
}

@end

@implementation NSSet (MoreDescriptions)

- (NSString*)shortDescription {
	NSMutableString* s = [NSMutableString stringWithString:@"{\n"] ;
	for (id object in self) {
		[s appendFormat:
		 @"   %@\n",
		 [object shortDescription]] ;
	}
	
	[s appendString:@"}"] ;
	
	return [NSString stringWithString:s] ;
}

- (NSString*)longDescription {
	NSMutableString* s = [NSMutableString stringWithString:@"{\n"] ;
	for (id object in self) {
		[s appendFormat:
		 @"   %@\n",
		 [object longDescription]] ;
	}
	
	[s appendString:@"}"] ;
	
	return [NSString stringWithString:s] ;
}

@end


@implementation NSCountedSet (MoreDescriptions)

- (NSString*)shortDescription {
	NSMutableString* desc = [[NSMutableString alloc] init] ;
	for (id object in self) {
		[desc appendFormat:
		 @"%@ [%ld],",
		 [object shortDescription],
		 (long)[self countForObject:object]] ;
	}
    
	// Delete the trailing comma
	if ([desc length] > 0) {
		[desc deleteCharactersInRange:NSMakeRange([desc length] - 1, 1)] ;
	}
	else {
		[desc appendString:@"<Empty Set>"] ;
	}
    
	NSString* answer = [[desc copy] autorelease] ;
    
    [desc release] ;
    
    return answer ;
}

@end

