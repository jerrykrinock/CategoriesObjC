#import "NSString+SSYExtraUtils.h"
#import "NSScanner+GeeWhiz.h"

@implementation NSString (SSYExtraUtils)

+ (NSString*)stringWithPascalString:(ConstStr255Param)pascalString
						   encoding:(CFStringEncoding)encoding {    
    if (pascalString == NULL) {
		return nil ;
	}
	
    char* cString = NULL;
    
    CFStringRef cfStringRef = CFStringCreateWithPascalString(NULL, pascalString, encoding);
    if (!cfStringRef) {
		return nil ;
	}
	
	CFIndex strBufLen = CFStringGetMaximumSizeForEncoding(CFStringGetLength(cfStringRef), kCFStringEncodingUTF8) + 1;       // + 1 for null terminator
	cString = (char *) malloc(strBufLen);
	if(!cString) {
		return nil ;
	}
	
	Boolean ok = CFStringGetCString(cfStringRef, cString, strBufLen, kCFStringEncodingUTF8);
	CFRelease(cfStringRef);
	
	NSString* serverName = nil ;
	if (ok) {
		serverName = [NSString stringWithUTF8String:cString] ;
	}
	
	free (cString) ;
	
	return serverName ;
}

- (NSRange)wholeRange {
	return NSMakeRange(0, [self length]) ;
}

- (NSString *)stringByReplacingAllOccurrencesOfString:(NSString *)stringToReplace
										   withString:(NSString *)replacement;
{
    NSRange searchRange = NSMakeRange(0, [self length]);
    NSRange foundRange = [self rangeOfString:stringToReplace options:0 range:searchRange];
    
    // If stringToReplace is not found, then there's nothing to replace -- just return self
    if (foundRange.length == 0) {
        return [[self copy] autorelease];
	}
	
    NSMutableString* copy = [self mutableCopy];
    unsigned int replacementLength = [replacement length];
    
    while (foundRange.length > 0) {
       [copy replaceCharactersInRange:foundRange withString:replacement];
        
        searchRange.location = foundRange.location + replacementLength;
        searchRange.length = [copy length] - searchRange.location;
		
        foundRange = [copy rangeOfString:stringToReplace options:0 range:searchRange];
    }
    
    NSString* result = [copy copy] ;
    [copy release] ;
    
    return [result autorelease] ;
}

- (NSString*)stringByCollapsingConsecutiveSpaces {
	NSMutableString* copy = [self mutableCopy] ;
	BOOL didModify = NO ;
	BOOL didModifyThisTime ;
	do {
		NSInteger oldLength = [copy length] ;
		[copy replaceOccurrencesOfString:@"  "
							  withString:@" "] ;
		didModifyThisTime = ([copy length] != oldLength) ;
		if (!didModify) {
			didModify = didModifyThisTime ;
		}
	} while (didModifyThisTime) ;
	
	id tweakedName = [copy copy] ;
	[copy release] ;
	
	return [tweakedName autorelease] ;
}

// The following two methods use functions recommended in Universal Binary Programming Guide > Swapping Bytes > Byte-Swapping Strategies > OSType
// http://developer.apple.com/legacy/mac/library/documentation/MacOSX/Conceptual/universal_binary/universal_binary_byte_swap/universal_binary_swap.html#//apple_ref/doc/uid/TP40002217-CH243-CJBBDIIG
// But I'm still not sure they work
- (FourCharCode)fourCharCodeValue {
	return UTGetOSTypeFromString((CFStringRef)self) ;
}

+ (NSString*)stringWithFourCharCode:(OSType)osType {
	return [(NSString*)UTCreateStringForOSType(osType) autorelease] ;
}

/* Old methods which give backwards results on Intel Macs due to endianness
- (FourCharCode)fourCharCodeValue
{
    char *chars;
    FourCharCode code;
    
    if ([self length] == 4) {    
		chars = (char*)[[self substringWithRange:NSMakeRange(0, 4)] UTF8String];
		
		code = 0;
		code += chars[0] << 24;
		code += chars[1] << 16;
		code += chars[2] << 8;
		code += chars[3];
	}
	else {
		NSLog(@"Error. Not 4 chars in %@", self) ;
		code = 0 ;
    }
    return code;
}

+ (NSString*)stringWithFourCharCode:(OSType)osType {
	char code[5];
	memcpy(code, &osType, sizeof(osType)) ;
	code[4] = 0 ;
	return [NSString stringWithCString:code
							  encoding:NSASCIIStringEncoding] ;
}

- (OSType)fourCharCode {
    OSType rval = 0;
    memcpy(&rval,[self UTF8String],sizeof(rval));
    return rval;
}
 */

// Fill the caller's buffer with a length-prefixed pascal-style ASCII string
// converted from the Uncode characters in an NSString.
//
//- (BOOL)pascalString:(StringPtr)outPStringPtr maxLen:(long)bufferSize
//{
//    BOOL convertedOK = NO;
//	
//    if ( outPStringPtr != NULL ) {
//		
//        convertedOK = CFStringGetPascalString( (CFStringRef)self,
//											   outPStringPtr,
//											   bufferSize,
//											   
//											   CFStringGetSystemEncoding() );
//	}
//	
//    return convertedOK;
//}
//

- (BOOL)containsString:(NSString*)target {
	BOOL answer = ([self rangeOfString:target].location != NSNotFound) ;
	return answer ;
}

- (BOOL)isMinimumLength:(NSNumber*)minLength {
	int iMinLength = [minLength intValue] ;
	return ([self length] >= iMinLength) ;
}

- (BOOL)isValidVersionString {
	// If string is a valid version string, the string which results
	// after we remove any decimal points, should have a nonzer -integerValue.
	NSString* dedecimalledString = [self stringByReplacingOccurrencesOfString:@"."
																   withString:@""] ;
	
	return ([dedecimalledString integerValue] != 0) ;
}

- (NSString*)versionSubstring {
	NSCharacterSet* thisNeedsMoreThought = [NSCharacterSet characterSetWithCharactersInString:@"()ab"] ;
	
	NSArray* words = [self componentsSeparatedByString:@" "] ;
	
	// So that we will ignore, for example, the "4" in case the string is
	// now, for example, "App4U version 1.0.0", we separate it into words and
	// see if there is a word that contains only decimal digits and the
	// decimal point.
	NSString* bestWord = nil ;
	NSString* nextBestWord = nil ;
	// Start from the end, since this is more likely to have the number(s)
	for (NSString* word in [words reverseObjectEnumerator]) {
		word = [word stringByTrimmingCharactersInSet:thisNeedsMoreThought] ;
		if ((bestWord == nil) && ([word rangeOfString:@"."].location != NSNotFound)) {
			bestWord = word ;
		}
		else if (nextBestWord == nil) {
			nextBestWord = word ;
		}
	}
	
	NSString* answer ;
	if ([bestWord isValidVersionString]) {
		answer = bestWord ;
	}
	else if ([nextBestWord isValidVersionString]) {
		answer = nextBestWord ;
	}
	else {
		answer = nil ;
	}
	
	return answer ;
}

- (NSInteger)majorVersion {
	return [[self versionSubstring] integerValue] ;
}

- (NSNumber*)isValidEmail {
	BOOL answer = YES ;
	int length = [self length] ;
	if ([self rangeOfString:@"@"].location > (length - 5)) {
		answer = NO ;
	}
	if ([self rangeOfString:@"."].location > (length - 3)) {
		answer = NO ;
	}
	
	if (length < 6) {
		answer = NO ;
	}
	
	return [NSNumber numberWithBool:answer] ;
}

- (NSString*)stringByRemovingLastCharacters:(int)n 
{
	int l = [self length] ;
	NSString* s = [[NSString alloc] initWithString:[self substringWithRange:NSMakeRange(0, l-n)]] ;
	return [s autorelease] ;
}

- (int)occurencesOfSubstring:(NSString*)target
					 inRange:(NSRange)range {
	int n = 0 ;
	int locStart = range.location ;
	int lenWhole = range.length ;
	int locFound ;
	BOOL done = NO ;
	while (!done) {
		int lenAfter = lenWhole - locStart ;
		locFound = [self rangeOfString:target
							   options:0
								 range:NSMakeRange(locStart, lenAfter)].location ;
		if (locFound == NSNotFound) {
			// Target not found
			done = YES ;
		}
		else {
			n++ ;
			locStart = locFound + 1 ;
		}
	}
	
	return n ;
}

NSString* const const aNewline = @"\n" ;

- (NSInteger)numberOfLinesCountTrailer:(BOOL)countTrailer {
	NSScanner* scanner = [[NSScanner alloc] initWithString:self] ;
	[scanner setCharactersToBeSkipped:nil] ;
	NSInteger numberOfLines = 0 ;
	while (![scanner isAtEnd]) {
		[scanner scanUpToString:aNewline
					 intoString:NULL] ;
		[scanner scanString:aNewline
				 intoString:NULL] ;
		numberOfLines++ ;
	}
	[scanner release] ;
	
	if (countTrailer) {
		// The above will not have counted a trailing newline
		// since the final scanString:intoString: will bring
		// the scanner to the end.  So we add one for that
		// if there is one:
		if ([self hasSuffix:aNewline]) {
			numberOfLines += 1 ;
		}
	}
	
	return numberOfLines ;
}

- (NSString *)stringByRemovingCharactersInSet:(NSCharacterSet*)characterSet {
	NSScanner*			 cleanerScanner = [NSScanner scannerWithString:self];
	NSMutableString* cleanString		= [NSMutableString stringWithCapacity:[self length]];
	
	while (![cleanerScanner isAtEnd])
	{
		NSString* stringFragment = @"" ;
		if ([cleanerScanner scanUpToCharactersFromSet:characterSet intoString:&stringFragment])
			[cleanString appendString:stringFragment];
		
		[cleanerScanner scanCharactersFromSet:characterSet
								   intoString:nil];
	}
	
	return cleanString;
}

- (NSString *)stringByReplacingCharactersInSet:(NSCharacterSet*)characterSet withString:(NSString*)string
{
	NSScanner*			 cleanerScanner = [NSScanner scannerWithString:self];
	NSMutableString* cleanString		= [NSMutableString stringWithCapacity:[self length]];
	
	while (![cleanerScanner isAtEnd])
	{
		NSString* stringFragment = @"" ;
		if ([cleanerScanner scanUpToCharactersFromSet:characterSet intoString:&stringFragment])
			[cleanString appendString:stringFragment];
		
		if ([cleanerScanner scanCharactersFromSet:characterSet
									   intoString:nil])
			[cleanString appendString:string];
	}
	
	return cleanString;
}

- (NSString*)substringSafelyWithRange:(NSRange)range {
	int maxLength = [self length] - range.location ;
	range.length = MIN(maxLength, range.length) ;
	return [self substringWithRange:range] ;
}

- (NSString*)capitalize {
	if ([self length] > 0) {
		unichar aChar = [self characterAtIndex:0] ;
		if ((aChar >= 0x61) && (aChar <= 0x7a)) {
			aChar -= 0x20 ;
			NSString* firstChar = [NSString stringWithCharacters:&aChar
														  length:1] ;
			NSString* ending = [self substringFromIndex:1] ;
			return [firstChar stringByAppendingString:ending] ;
		}
	}
	
	return self ;
}

- (NSString*)colonize {
	return [self stringByAppendingString:@":"] ;
}

- (NSString*)doublequote {
	return [NSString stringWithFormat:@"\"%@\"", self] ;
}

- (NSString*)ellipsize {
	unichar ellipsisChar = 0x2026 ;
	NSString* ellipsisString = [NSString stringWithCharacters:&ellipsisChar length:1] ;
	return [self stringByAppendingString:ellipsisString] ;
}

- (NSString*)trimNewlineFromEnd;
{
	NSRange rangeOfNewline = [self rangeOfString:@"\n" options:NSBackwardsSearch] ;
	if ((rangeOfNewline.location == NSNotFound) || (rangeOfNewline.location != ([self length]-1)))
		return nil ;
	else
	{
		return [[[self substringWithRange:NSMakeRange(0, [self length] - 1)] retain] autorelease]; 
	}
}

/*  This function is no longer used.  Good becase TruncateThemText() is depracated.
 - (NSString*)truncateToWidthStyle:(float)width
							style:()truncateStyle {
    NSMutableString *text = [self mutableCopy] ;
    NSAttributedString *s = [NSAttributedString alloc] ;
    NSMutableParagraphStyle *ps = [[NSParagraphStyle defaultParagraphStyle] mutableCopy] ;
    OSStatus err ;
    err = TruncateThemeText((CFMutableStringRef)text,
							kThemeViewsFont,
							kThemeStateActive,
							width,
							truncMiddle,
							NULL) ;
    if (err != noErr) {
		NSLog(@"TruncateThemeText failed with error %d", err) ;
	}
    // XXX Should be able to skip the above by using NSLineBreakByTruncatingMiddle,
    // XXX but OS X 10.1 doesn't implement it yet.
	if ([ps respondsToSelector:@selector(setLineBreakMode:)]) {  // 10.3 does not
		[ps setLineBreakMode: NSLineBreakByClipping];
    }
	NSDictionary* attributes = [NSDictionary dictionaryWithObjectsAndKeys:
								ps, NSParagraphStyleAttributeName,
								nil] ;
	s = [s initWithString:text
			   attributes:attributes];
    [text release];
    [ps release];
    return [s autorelease];
}
*/

- (BOOL)isAllWhite
{
	NSString* aCopy = [NSString stringWithString:self] ;
	NSString* trimmedCopy = [aCopy stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] ;
	if ([trimmedCopy length])
	{
		return NO ;
	}
	return YES ;
}

- (NSString*)parseForEmailInHTMLTags {
	NSScanner* scanner = [[NSScanner alloc] initWithString:self] ;
	BOOL done = NO ;
	NSString* domain = @"" ;
	NSMutableString* name = nil;
	
	while (!done && ![scanner isAtEnd]) {
		BOOL okSoFar = YES ;
		
		int atLoc ;
		if (okSoFar) {
			BOOL scanned = [scanner scanUpToAndThenLeapOverString:@"@" intoString:NULL] ;
			atLoc = [scanner scanLocation] ;
			if (!scanned || [scanner isAtEnd]) {
				okSoFar = NO ;
			}
		}
		
		if (okSoFar) {
			domain = @"";
			[scanner scanUpToString:@"<" intoString:&domain] ;
			[scanner release] ;
			if ([domain length] < 2) {
				okSoFar = NO ;
			}
		}
		
		if (okSoFar) {
			unichar chr ;	
			name = [NSMutableString stringWithCapacity:32] ;
			int i = 2 ;
			while ((chr = [self characterAtIndex:(atLoc-i)]) != '>') {
				[name insertString:[NSString stringWithCharacters:&chr length:1] atIndex:0] ;
				i++ ;
			}
			if ([name length] < 1) {
				okSoFar = NO ;
			}
		}
		
		if (okSoFar) {
			done = YES ;
		}
	}
	
	NSString* answer = done ? [NSString stringWithFormat:@"%@@%@", name, domain] : nil ;
	return answer ;
}

- (NSString *) stringByDecodingXMLEntities {
    NSString *unescapedString = (NSString *)CFXMLCreateStringByUnescapingEntities(NULL, (CFStringRef)self, NULL);
    // Apple documentation for the above function is very confusing regarding what the
	// last argument does.  I tried several examples.  It seems to always replace
	// something of the form &#dd; where dd is 1-3 decimal digits, regardless
	// of what the last argument is.  I have never seen any effect from the last argument.
	return [unescapedString autorelease];
}

- (NSString*)reverseAsciiChars {
	const char* fwdBytes = [self UTF8String] ;
	int L = [self length] ;
	int end = L - 1 ;
	char* revBytes = malloc(L) ;
	int i ;
	for (i=end; i>=0; i--) {
		revBytes[end-i] = fwdBytes[i] ;
	}
	
	NSString* revString = [[NSString alloc] initWithBytes:revBytes
												   length:L
												 encoding:NSASCIIStringEncoding] ;
	free(revBytes) ;
	return [revString autorelease] ;
}

- (NSString*)decimalDigitSuffix {
	NSString* revString = [self reverseAsciiChars] ;
	NSScanner* scanner = [[NSScanner alloc] initWithString:revString] ;
	// Must initialize to empty because stupid NSScanner won't touch this if
	// no characters scanned...
	NSString* revSuffix = @"" ;
	[scanner scanCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet]
						intoString:&revSuffix] ;
	[scanner release] ;
	return [revSuffix reverseAsciiChars] ;
}

@end


@implementation NSMutableString (SSYExtraUtils)

- (unsigned int)replaceOccurrencesOfString:(NSString *)target
								withString:(NSString *)replacement {
	return [self replaceOccurrencesOfString:target
								 withString:replacement
									options:0
									  range:NSMakeRange(0, [self length])] ;
}

@end