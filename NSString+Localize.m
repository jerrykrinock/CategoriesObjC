#import "SSYLocalize/NSString+Localize.h"
#import "NSScanner+GeeWhiz.h"

NSString* SSPercentPercent = @"%%" ;
NSString* SSPercent = @"%" ;
NSString* SSStringNotFoundAnnouncer = @" <NOT FOUND>" ;


@interface SSYLocalizeBundleGetter : NSObject

+ (NSBundle*)bundle ;

@end

@implementation SSYLocalizeBundleGetter

// I cannot "just" do this in NSString(Localize) because it is a category,
// and the bundle of class NSString is CoreFoundation, not what I want.
+ (NSBundle*)bundle {
	return [NSBundle bundleForClass:[self class]] ;
}

@end

@interface NSMutableString (StuffINeed)

- (BOOL)replaceFirstOccurrenceOfString:(NSString*)target
							withString:(NSString*)replacement ;

@end


@implementation NSMutableString (StuffINeed)

- (BOOL)replaceFirstOccurrenceOfString:(NSString*)target
							withString:(NSString*)replacement {
	BOOL didDo = NO ;
	NSScanner* scanner = [[NSScanner alloc] initWithString:self] ;
	[scanner scanUpToString:target
				 intoString:NULL] ;
	if (![scanner isAtEnd]) {
		int targetLocation = [scanner scanLocation] ;
		[self deleteCharactersInRange:NSMakeRange(targetLocation, [target length])] ; 
		[self insertString:replacement
				   atIndex:targetLocation] ;
		didDo = YES ;
	}
	
	return didDo ;
}

- (void)doNextSubstitution:(NSString**)substitution_p
				   scanner:(NSScanner *)scanner
		  placeholderRange:(NSRange)placeholderRange
					argPtr:(va_list *)argPtr 
		 indexCharacterSet:(NSCharacterSet*)indexCharacterSet {
	static NSCharacterSet* modifierCharacterSet = nil ;
	if (modifierCharacterSet == nil) {
		modifierCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@".01234566789"] ;
		[modifierCharacterSet retain] ; // Stick around until app quits
	}
	
	int possibleFormatCharLocation ;
	NSString* modifier = @"" ;
	BOOL dollarsign = [scanner scanString:@"$"intoString:NULL] ;
	if (dollarsign) {
		[scanner scanCharactersFromSet:modifierCharacterSet
							intoString:&modifier] ;
		possibleFormatCharLocation = [scanner scanLocation] ;
		// Lengthen placeholder by the length of the modifier
		placeholderRange.length += [modifier length] ;
		// Also lengthen placeholder by one for the dollar sign and one for the formatChar:
		placeholderRange.length += 2 ;
	}
	else {
		possibleFormatCharLocation = [scanner scanLocation] - 1 ;
	}
	
	
	// If we're not re-using a previous substitution, get a new one from the var-args list
	if (*substitution_p == nil) {
		// Get the formatChar, which will be one of @, i, d, f, e, etc.
		[scanner setScanLocation:possibleFormatCharLocation] ;
		// If this placeholder is a simple reorderable string placeholder, the
		// next character will be a USA decimal digit and formatChar is the default '@'
		// If the next character is not a USA decimal digit, the placeholder is a
		// simple nonreorderable placeholder and the next character is the formatChar
		BOOL hasSimpleFormatChar = ![scanner scanCharactersFromSet:indexCharacterSet
														intoString:NULL] ;
		unichar formatChar ;
		if (hasSimpleFormatChar) {
			formatChar = [self characterAtIndex:possibleFormatCharLocation] ;
		}
		else {
			// Default for simple reorderable placeholders %0, %1, %2 is NSString*
			formatChar = '@' ;
		}
		NSString* formatString = [@"%" stringByAppendingString:modifier] ;
		formatString = [formatString stringByAppendingString:[NSString stringWithCharacters:&formatChar length:1]] ;
		switch (formatChar) {
			case '@':
				*substitution_p = [NSString stringWithFormat:formatString, va_arg(*argPtr, NSString*)] ;
				break ;
			case 'd':
			case 'D':
			case 'i':
			case 'c':  // 'unsigned char' is promoted to 'int' when passed through va-arg's '...'
			case 'C':  // 'unichar' is promoted to 'int' when passed through va-arg's '...'
				*substitution_p = [NSString stringWithFormat:formatString, va_arg(*argPtr, int)] ;
				break ;
			case 'e':
			case 'f':
			case 'F':
			case 'g':
			case 'G':
				*substitution_p = [NSString stringWithFormat:formatString, va_arg(*argPtr, double)] ;
				break ;
			case 's':
				*substitution_p = [NSString stringWithFormat:formatString, va_arg(*argPtr, char*)] ;
				break ;
			case 'S':
				*substitution_p = [NSString stringWithFormat:formatString, va_arg(*argPtr, unichar*)] ;
				break ;
			case 'p':
				*substitution_p = [NSString stringWithFormat:formatString, va_arg(*argPtr, void*)] ;
				break ;
			case 'u':
			case 'U':
			case 'x':
			case 'X':
			case 'o':
			case 'O':
				*substitution_p = [NSString stringWithFormat:formatString, va_arg(*argPtr, int unsigned)] ;
				break ;
			default:
				// Should never execute
				*substitution_p = @"ERROR 575-9832: See Console Msgs", formatChar ;
				NSLog(@"Internal Error 575-9832: [%@ %s]: Unsupported format type: %c", [self className], _cmd, formatChar) ;
				break ;
				
		}
	}
	
	[self deleteCharactersInRange:placeholderRange] ; 
	[self insertString:*substitution_p
			   atIndex:placeholderRange.location] ;
}


- (void)replacePlaceholdersWithIndex:(int)index
	withSubstitutionFromVaArgPointer:(va_list*)argPtr {
	static NSCharacterSet* indexCharacterSet = nil ;
	if (indexCharacterSet == nil) {
		indexCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"01234566789"] ;
		[indexCharacterSet retain] ; // Stick around until app quits
	}

	NSString* substitution = nil ;
	BOOL foundQualifiedPlaceholder ;
	do {
		// If substitution is nil (the normal case), will get a new substitution
		// by running va_arg() to extract the next value pointed to by argPtr.
		// If substitution is non-nil (the case if more than one placeholder gets
		// the same substitution) it will be used and va_arg() will not run.
		// Returns the substitution done, or nil if the target was not found
		
		NSScanner* scanner = [[NSScanner alloc] initWithString:self] ;
		
		// Scan past the first qualified target, bypassing any escaped percents %%
		BOOL foundQualifiedIndexedPlaceholder = NO ;
		BOOL foundQualifiedUnindexedPlaceholder = NO ;

		do {
			BOOL didFindFirstPercent = [scanner scanUpToAndThenLeapOverString:@"%"
																   intoString:NULL] ;
			if (didFindFirstPercent) {
				BOOL escapedPercent = [scanner scanString:@"%"
											   intoString:NULL] ;
				if (escapedPercent) {
					// First % was immediately followed by second %
					// This is an esaped %
					// Scan by it
					[scanner scanString:@"%" intoString:NULL] ;
				}
				else {
					// First % was not followed by a second %
					// This is a placeholder
					if (index >= 0) {
						foundQualifiedIndexedPlaceholder = [scanner scanString:[NSString stringWithInt:index]
																	intoString:NULL] ;
					}
					else {
						// When index is -1, we do not yet allow placeholders of the form %d,
						// where d is a decimal digit
						foundQualifiedUnindexedPlaceholder = ![scanner scanCharactersFromSet:indexCharacterSet
																				  intoString:NULL] ;
						// If the next char is the non-decimal-digit character (@, d, i, f, etc.)
						// the above failed to scan, and we'll need to scan by it.
						if (foundQualifiedUnindexedPlaceholder) {
							[scanner setScanLocation:[scanner scanLocation] + 1] ;
						}
					}
				}
			}
			foundQualifiedPlaceholder = (foundQualifiedIndexedPlaceholder  || foundQualifiedUnindexedPlaceholder) ;
		} while (![scanner isAtEnd] && !foundQualifiedPlaceholder) ;
		
		
		if (foundQualifiedIndexedPlaceholder || foundQualifiedUnindexedPlaceholder) {
			if (!foundQualifiedIndexedPlaceholder) { 
				substitution = nil ;
			}
			
			// If we found a qualified placeholder, we will, at this point, have
			// scanned the first two characters of it.  For example, %@, %d, %0, %1, etc.
			// We backtrack to define the range of what we have scanned so far.
			NSRange placeholderRange = NSMakeRange([scanner scanLocation] - 2, 2) ;
			[self doNextSubstitution:&substitution
							 scanner:scanner
					placeholderRange:placeholderRange
							  argPtr:argPtr
				   indexCharacterSet:indexCharacterSet] ;
		}
		
		
		foundQualifiedPlaceholder = (foundQualifiedIndexedPlaceholder  || foundQualifiedUnindexedPlaceholder) ;
		
		if (!foundQualifiedPlaceholder) {
			substitution = nil ;
		}
		
		[scanner release] ;
		
	} while ((foundQualifiedPlaceholder == YES)) ;
}

@end

@implementation NSString (SSYLocalize)

- (int)countOccurrencesOfSubstring:(NSString*)substring {
	NSScanner* scanner = [[NSScanner alloc] initWithString:self] ;
	int count = 0 ;
	while ([scanner scanUpToAndThenLeapOverString:substring
									   intoString:NULL] == YES) {
		count++ ;
	}
	
	[scanner release] ;
	
	return count ;
}

- (NSString*)localizedTableValue {
	// Will return nil if not found in Localizable.strings.
	static NSBundle* bundle = nil ;
	if (bundle == nil) {
		bundle = [SSYLocalizeBundleGetter bundle] ;

		[bundle retain] ; // Stick around until app quits
	}

	NSString* answer = nil ;
	
	NSString* s = [bundle localizedStringForKey:self // key
										  value:SSStringNotFoundAnnouncer  // returned if not found in any Localizable.strings
										  table:@"Localizable"] ;
	// I would have preferred to use @"" for value, but that doesn't work.
	// due to an apparent bug in localizedStringForKey:value:table
	
	if (![s isEqualToString:SSStringNotFoundAnnouncer]) {
		// This is the normal case
		answer = s ;
	}
	
	return answer ;
}

- (NSString*)notFoundInLocalizedTableValue {
	return [[self uppercaseString] stringByAppendingString:SSStringNotFoundAnnouncer] ;
}

+ (NSString*)localize:(NSString*)keyString {
	NSString* answer = [keyString localizedTableValue] ;
	if (answer == nil) {
		answer = [keyString notFoundInLocalizedTableValue] ;
	}
	
	return answer ;	
}

+ (NSString*)localizeWeakly:(NSString*)keyString {
	NSString* answer = [keyString localizedTableValue] ;
	if (answer == nil) {
		answer = keyString ;
	}
	
	return answer ;	
}

+ (NSString *)replacePlaceholdersInString:(NSString*)s
								 argPtr_p:(va_list*)argPtr_p  {
	// The tricky thing about va_arg() is that it will suddenly start
	// giving garbage once all the arguments are gone.  You have to know
	// from other information how many arguments are expected.  There
	// are ordinarily two ways to get the number of arguments:
	//    (1) Parse the format string and count the placeholders
	//    (2) Require the invoker to end the list with nil and watch for it.
	// In this method we use (1)
	
	NSString *answer;
	
	int nLiteralPercents = [s countOccurrencesOfSubstring:SSPercentPercent] ;
	int nPlaceholders = [s countOccurrencesOfSubstring:SSPercent] - 2 * nLiteralPercents ;
	if (nPlaceholders == 0) {
		answer = s ;
		goto end ;
	}
	
	NSMutableString* ss = [s mutableCopy] ;
	int i ;
	for (i=-1; i<nPlaceholders; i++) {		
		[ss replacePlaceholdersWithIndex:i
		withSubstitutionFromVaArgPointer:argPtr_p] ;
	}
	
	// If there were any escaped percents, %%, replace them with %.
	if (nLiteralPercents > 0) {
		[ss replaceOccurrencesOfString:SSPercentPercent
							withString:SSPercent
							   options:0
								 range:NSMakeRange(0, [ss length])] ;
	}	
	
	answer = [[ss copy] autorelease] ;
	[ss release] ;

end:
	return answer;
}

+ (NSString*)localizeFormat:(NSString*)formatString, ... {
	NSString* answer ;
	BOOL canDo = YES ;
	
	if (formatString == nil) {
		answer = nil ;
		canDo = NO ;
	}	
	
	if ([formatString length] == 0) {
		answer = formatString ;
		canDo = NO ;
	}
	
	NSString* s = [formatString localizedTableValue] ;
	if (s == nil) {
		answer = [formatString notFoundInLocalizedTableValue] ;
		canDo = NO ;
	}
	
	if (canDo) {
		va_list argPtr ;
		va_list* argPtr_p = &argPtr ;
		
		// Note that we pass argPtr by reference.  The reason for this may be explained in:
		// http://groups.google.com/group/gnu.gcc.help/browse_thread/thread/c4a6b74860b0899f/cbd1f71fd1613b7d?lnk=gst&q=va_arg#
		// More practically, I find (in project varArgsWeirdness), that if I pass
		// the actual argPtr instead of &argPtr, va_arg() in the subroutine fails to
		// increment when called.  Each call gives the same (first) argument.  It
		// just stays stuck there and doesn't move.  (1-2 hours to learn and fix!!!)

		va_start(argPtr, formatString) ;
		answer = [self replacePlaceholdersInString:s
										  argPtr_p:argPtr_p];
		va_end(argPtr) ;
	}
	
	return answer ;
}

// weaklyLocalizeFormat: is the same as localizeFormat: except for the answer when (s == nil)
// However, we cannot factor out any more because of the requirement that argPtr be
// declared within the function that has the variable arguments.

+ (NSString*)weaklyLocalizeFormat:(NSString*)formatString, ... {
	NSString* answer ;
	BOOL canDo = YES ;
	
	if (formatString == nil) {
		answer = nil ;
		canDo = NO ;
	}	
	
	if ([formatString length] == 0) {
		answer = formatString ;
		canDo = NO ;
	}
	
	NSString* s = [formatString localizedTableValue] ;
	if (s == nil) {
		answer = formatString ;
		canDo = NO ;
	}
	
	if (canDo) {
		va_list argPtr ;
		va_list* argPtr_p = &argPtr ;
		
		// Note that we pass argPtr by reference.  The reason for this may be explained in:
		// http://groups.google.com/group/gnu.gcc.help/browse_thread/thread/c4a6b74860b0899f/cbd1f71fd1613b7d?lnk=gst&q=va_arg#
		// More practically, I find (in project varArgsWeirdness), that if I pass
		// the actual argPtr instead of &argPtr, va_arg() in the subroutine fails to
		// increment when called.  Each call gives the same (first) argument.  It
		// just stays stuck there and doesn't move.  (1-2 hours to learn and fix!!!)
		
		va_start(argPtr, formatString) ;
		answer = [self replacePlaceholdersInString: s argPtr_p: argPtr_p];
		va_end(argPtr) ;
	}
	
	return answer ;
}

+ (NSString*)languageCodeLoaded {
	NSString* key = @"000_language" ;
	NSString* value = [self localizeWeakly:key] ;
	if ([value isEqualToString:key]) {
		value = @"en" ;
	}
	
	return value ;
}


+ (NSString*)stringWithInt:(int)i {
	return [NSString localizedStringWithFormat:@"%d", i] ;
}

@end