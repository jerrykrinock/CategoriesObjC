#import "NSString+VarArgs.h"
#import "NSScanner+GeeWhiz.h"

NSString* SSPercentPercent = @"%%" ;
NSString* SSPercent = @"%" ;

static NSCharacterSet* static_modifierCharacterSet = nil ;

@interface NSMutableString (FormatSubstitutions)

@end


@implementation NSMutableString (FormatSubstitutions)

- (void)doNextSubstitution:(NSString**)substitution_p
				   scanner:(NSScanner *)scanner
		  placeholderRange:(NSRange)placeholderRange
					argPtr:(va_list *)argPtr 
		 indexCharacterSet:(NSCharacterSet*)indexCharacterSet {
	if (static_modifierCharacterSet == nil) {
		static_modifierCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@".01234566789"] ;
		[static_modifierCharacterSet retain] ; // Stick around until app quits
	}
	
	int possibleFormatCharLocation ;
	NSString* modifier = @"" ;
	BOOL dollarsign = [scanner scanString:@"$"intoString:NULL] ;
	if (dollarsign) {
		[scanner scanCharactersFromSet:static_modifierCharacterSet
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
				NSLog(@"Internal Error 575-9832: [%@ %@]: Unsupported format type: %c", [self className], NSStringFromSelector(_cmd), formatChar) ;
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
		indexCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"] ;
		[indexCharacterSet retain] ; // Stick around until app quits
	}
	
	NSString* substitution = nil ;
	BOOL foundQualifiedPlaceholder ;
	// The leftOffAt jazz was added 20100209 when it was found that if a substitution
	// itself contained a %0, %1, %2 etc. sequence, as can happen with a percent-escape
	// encoded URL, after substituting this in, the following loop will erroneously
	// discover them as intended substitution placeholders, and then substitute the
	// substitution inside of itself.  Thus, an infinite loop as the receiver's length
	// grows infinitely, using massive memory, slowing down the system, etc.
	NSInteger leftOffAt = 0 ;
	BOOL didAtLeastOne = NO ;
	do {
		// If substitution is nil (the normal case), will get a new substitution
		// by running va_arg() to extract the next value pointed to by argPtr.
		// If substitution is non-nil (the case if more than one placeholder gets
		// the same substitution) it will be used and va_arg() will not run.
		// Returns the substitution done, or nil if the target was not found
		
		NSScanner* scanner = [[NSScanner alloc] initWithString:self] ;
		[scanner setScanLocation:leftOffAt] ;
		
		// Scan past the first qualified target, bypassing any escaped percents %%
		BOOL foundQualifiedIndexedPlaceholder = NO ;
		BOOL foundQualifiedUnindexedPlaceholder = NO ;
		
		do {
			leftOffAt = [scanner scanLocation] ;
			BOOL didFindFirstPercent = [scanner scanUpToAndThenLeapOverString:@"%"
																   intoString:NULL] ;
			leftOffAt = [scanner scanLocation] ;
			if (didFindFirstPercent) {
				leftOffAt -= 1;
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
						NSString* scannedIndex = nil ;
						foundQualifiedIndexedPlaceholder = [scanner scanString:[NSString stringWithInt:index]
																	intoString:&scannedIndex] ;
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
			// 'substitution' is normally nil.  It is non-nil if we are re-using
			// a subtitution.
			[self doNextSubstitution:&substitution
							 scanner:scanner
					placeholderRange:placeholderRange
							  argPtr:argPtr
				   indexCharacterSet:indexCharacterSet] ;
			leftOffAt += [substitution length] ;			
			didAtLeastOne = YES ;
		}
		
		foundQualifiedPlaceholder = (foundQualifiedIndexedPlaceholder  || foundQualifiedUnindexedPlaceholder) ;
		
		if (!foundQualifiedPlaceholder) {
			substitution = nil ;
		}
		
		[scanner release] ;
		
	} while ((foundQualifiedPlaceholder == YES) && (leftOffAt < [self length])) ;
	BOOL needToSkipThisOne = (!didAtLeastOne && (index >=0)) ;
	if (needToSkipThisOne) {
		// No occureneces of placeholder %<index> were found in the string.
		// (It is expected that no placeholders will be found if index = -1)
		
		// This can happen if the translator did not use all of the available
		// substitutions.  For example, consider a string "Trash the %0", where
		// %0 is "Files", in English.  However, in some languages, the proper
		// translation may be something like "Put File items into the trash".
		// Further assume that this language uses singular and plural forms
		// like English.  In this case, the translator would need the singlular
		// form "File" instead of the plural form.  To solve this problem,
		// you should give the translator two substitutions, singular and plural,
		// so they can pick the one that they need.  If you give the singular
		// one first and they need the plural, the singular one will be skipped
		// and we will end up here.
		
		// However, when a substitution is skipped, we still need to call
		// va_arg in order to advance va_arg's hidden argument pointer past
		// the unused substitution, so we'll get the next one when we need
		// it subsequently.
		
		// The 'notUsed' nonsense is to eliminate compiler warning.  LLVM-Clang
		// seems to think that va_arg() has no effect other than to return a
		// value which they expect you to use.  If they are correct, then
		// this whole section is nonsense.
		id notUsed = va_arg(*argPtr, id) ;
		notUsed = nil ;
	}
}

@end


@implementation NSString (VarArgs)

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


- (int)countMaxPlaceholders {
	NSScanner* scanner = [[NSScanner alloc] initWithString:self] ;
	int count = 0 ;
	int highest = 0 ;
	while ([scanner scanUpToAndThenLeapOverString:SSPercent
									   intoString:NULL] == YES) {
		count++ ;
		int n = 0 ;
		[scanner scanInt:&n] ;
		highest = MAX(n,highest) ;
	}
	
	[scanner release] ;
	
	return MAX(count,highest+1) ;
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
	int nPlaceholders = [s countMaxPlaceholders] - 2 * nLiteralPercents ;
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

+ (NSString*)stringWithInt:(int)i {
	return [NSString localizedStringWithFormat:@"%d", i] ;
}

@end
