#import "NSString+SSYExtraUtils.h"
#import "NSScanner+GeeWhiz.h"
#import "NSBundle+MainApp.h"

/*
 @brief    A patched version of CFXMLCreateStringByUnescapingEntities(), which
 fixes Apple Bug ID 16424156
 @details  See http://lists.apple.com/archives/cocoa-dev/2014/Mar/msg00343.html
 */
CFStringRef PatchedCFXMLCreateStringByUnescapingEntities(CFAllocatorRef allocator, CFStringRef string, CFDictionaryRef entitiesDictionary) {
    if (string == NULL) {
        return NULL ;
    }
    
    CFStringInlineBuffer inlineBuf; /* use this for fast traversal of the string in question */
    CFStringRef sub;
    CFIndex lastChunkStart, length = CFStringGetLength(string);
    CFIndex i, entityStart;
    UniChar uc;
    UInt32 entity;
    int base;
    CFMutableDictionaryRef fullReplDict = entitiesDictionary ? CFDictionaryCreateMutableCopy(allocator, 0, entitiesDictionary) : CFDictionaryCreateMutable(allocator, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    CFDictionaryAddValue(fullReplDict, (const void *)CFSTR("amp"), (const void *)CFSTR("&"));
    CFDictionaryAddValue(fullReplDict, (const void *)CFSTR("quot"), (const void *)CFSTR("\""));
    CFDictionaryAddValue(fullReplDict, (const void *)CFSTR("lt"), (const void *)CFSTR("<"));
    CFDictionaryAddValue(fullReplDict, (const void *)CFSTR("gt"), (const void *)CFSTR(">"));
    CFDictionaryAddValue(fullReplDict, (const void *)CFSTR("apos"), (const void *)CFSTR("'"));
    
    CFStringInitInlineBuffer(string, &inlineBuf, CFRangeMake(0, length));
    // The above range was length-1, but that misses the ';' in case the
    // subject string ends in a numeric HTML entity.  So I removed the "-1"
    CFMutableStringRef newString = CFStringCreateMutable(allocator, 0);
    
    lastChunkStart = 0;
    // Scan through the string in its entirety
    for(i = 0; i < length; ) {
        uc = CFStringGetCharacterFromInlineBuffer(&inlineBuf, i); i++;	// grab the next character and move i.
        
        if(uc == '&') {
            entityStart = i - 1;
            entity = 0xFFFF;	// set this to a not-Unicode character as sentinel
            // We may have hit the beginning of an entity. Copy everything from lastChunkStart to this point.
            if(lastChunkStart < i - 1) {
                sub = CFStringCreateWithSubstring(allocator, string, CFRangeMake(lastChunkStart, (i - 1) - lastChunkStart));
                CFStringAppend(newString, sub);
                CFRelease(sub);
            }
            
            uc = CFStringGetCharacterFromInlineBuffer(&inlineBuf, i); i++;	// grab the next character and move i.
            // Now we can process the entity reference itself
            if(uc == '#') {	// If this turns out to be an entity, it is a numeric entity.
                base = 10;
                entity = 0;
                uc = CFStringGetCharacterFromInlineBuffer(&inlineBuf, i); i++;
                
                if(uc == 'x') {	// only lowercase x allowed. Translating numeric entity as hexadecimal.
                    base = 16;
                    uc = CFStringGetCharacterFromInlineBuffer(&inlineBuf, i); i++;
                }
                
                // process the provided digits 'til we're finished
                while(true) {
                    if (uc >= '0' && uc <= '9')
                        entity = entity * base + (uc-'0');
                    else if (uc >= 'a' && uc <= 'f' && base == 16)
                        entity = entity * base + (uc-'a'+10);
                    else if (uc >= 'A' && uc <= 'F' && base == 16)
                        entity = entity * base + (uc-'A'+10);
                    else break;
                    
                    if (i < length) {
                        uc = CFStringGetCharacterFromInlineBuffer(&inlineBuf, i); i++;
                    }
                    else
                        break;
                }
            }
            
            while(uc != ';' && i < length) {
                uc = CFStringGetCharacterFromInlineBuffer(&inlineBuf, i); i++;
            }
            
            if (uc == ';') {
                if(0xFFFF != entity) { // it was numeric, and translated.
                    // Now, output the result fo the entity
                    if(entity >= 0x10000) {
                        UniChar characters[2] = { ((entity - 0x10000) >> 10) + 0xD800, ((entity - 0x10000) & 0x3ff) + 0xDC00 };
                        CFStringAppendCharacters(newString, characters, 2);
                    } else {
                        UniChar character = entity;
                        CFStringAppendCharacters(newString, &character, 1);
                    }
                } else {	// it wasn't numeric.
                    sub = CFStringCreateWithSubstring(allocator, string, CFRangeMake(entityStart + 1, (i - entityStart - 2))); // This trims off the & and ; from the string, so we can use it against the dictionary itself.
                    CFStringRef replacementString = (CFStringRef)CFDictionaryGetValue(fullReplDict, sub);
                    if(replacementString) {
                        CFStringAppend(newString, replacementString);
                    } else {
                        CFRelease(sub); // let the old substring go, since we didn't find it in the dictionary
                        sub =  CFStringCreateWithSubstring(allocator, string, CFRangeMake(entityStart, (i - entityStart))); // create a new one, including the & and ;
                        CFStringAppend(newString, sub); // ...and append that.
                    }
                    CFRelease(sub); // in either case, release the most-recent "sub"
                }
            }
            else {
                // Trailing semicolon was missing.  This was not an html entity.
                // Back out of it.
                CFStringRef sub1 =  CFStringCreateWithSubstring(allocator, string, CFRangeMake(entityStart, (i - entityStart)));
                CFStringAppend(newString, sub1) ;
                if (sub1 != NULL) {
                    CFRelease(sub1) ;
                }
            }
            
            // move the lastChunkStart to the beginning of the next chunk.
            lastChunkStart = i;
        }
    }
    if(lastChunkStart < length) { // we've come out of the loop, let's get the rest of the string and tack it on.
        sub = CFStringCreateWithSubstring(allocator, string, CFRangeMake(lastChunkStart, i - lastChunkStart));
        CFStringAppend(newString, sub);
        CFRelease(sub);
    }
    
    CFRelease(fullReplDict);
    
    return newString ;
}

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
        CFRelease(cfStringRef);
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

- (NSUInteger)numberOfOccurrencesOfCharacter:(unichar)aChar {
	NSInteger i ;
	NSUInteger count = 0 ;
	for (i=0; i<[self length]; i++) {
		if ([self characterAtIndex:i] == aChar) {
			count++ ;
		}
	}
	
	return count ;
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
    NSUInteger replacementLength = [replacement length];
    
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
	if (![self containsString:@"  "]) {
		return self ;
	}

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
	NSInteger iMinLength = [minLength integerValue] ;
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
	NSInteger length = [self length] ;
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

- (NSString*)stringByRemovingLastCharacters:(NSInteger)n 
{
	NSInteger l = [self length] ;
	NSString* s = [[NSString alloc] initWithString:[self substringWithRange:NSMakeRange(0, l-n)]] ;
	return [s autorelease] ;
}

- (NSInteger)occurrencesOfSubstring:(NSString*)target
					 inRange:(NSRange)range {
	NSInteger n = 0 ;
	NSInteger locStart = range.location ;
	NSInteger lenWhole = range.length ;
	NSInteger locFound ;
	BOOL done = NO ;
	while (!done) {
		NSInteger lenAfter = lenWhole - locStart ;
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

NSString* const aNewline = @"\n" ;

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
	NSInteger maxLength = [self length] - range.location ;
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
		
		NSInteger atLoc ;
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
			if ([domain length] < 2) {
				okSoFar = NO ;
			}
		}
		
		if (okSoFar) {
			unichar chr ;	
			name = [NSMutableString stringWithCapacity:32] ;
			NSInteger i = 2 ;
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
    [scanner release] ;
	
	NSString* answer = done ? [NSString stringWithFormat:@"%@@%@", name, domain] : nil ;
	return answer ;
}

- (NSString *) stringByDecodingXMLEntities {
    NSString *unescapedString = (NSString *)PatchedCFXMLCreateStringByUnescapingEntities(NULL, (CFStringRef)self, NULL) ;
	return [unescapedString autorelease] ;
}

- (NSString*)reverseAsciiChars {
	const char* fwdBytes = [self UTF8String] ;
	NSInteger L = [self length] ;
	NSInteger end = L - 1 ;
	char* revBytes = malloc(L) ;
	NSInteger i ;
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

- (BOOL)isValidUrl {
	// Idea stolen from http://www.cocoabuilder.com/archive/cocoa/1281-url-parsing-in-cocoa.html?q=string+is+valid+URL#1281
	NSString* scheme = [[[NSURL URLWithString:self] absoluteURL] scheme] ;
	return (scheme != nil) ;
}

- (NSString*)parseForUrlAndName_p:(NSString**)name_p {
	NSScanner* scanner = [[NSScanner alloc] initWithString:self] ;
	NSString* firstPart = nil ;
	[scanner scanUpToString:@"\t"
				 intoString:&firstPart] ;
	NSString* name = nil ;
	NSString* url = nil ;
	if ([scanner isAtEnd]) {
		if ([firstPart isValidUrl]) {
			url = firstPart ;
		}
		else {
			name = firstPart ;
		}
	}
	else {
		name = firstPart ;
		// Add +1 for the \t ...
		url = [self substringFromIndex:([scanner scanLocation] + 1)] ;
		if (![url isValidUrl]) {
			url = nil ;
		}
	}
	[scanner release] ;
	
	if (name_p) {
		if ([name length] == 0) {
			name = [[NSBundle mainAppBundle] localizedStringForKey:@"untitled"
                                                             value:@"?"
                                                             table:@"Localizable"] ;
		}

		*name_p = name ;
	}
	
	return url ;
}
		

- (NSString*)stringByOmittingAttachmentCharacters {
	NSMutableString * mString = [self mutableCopy] ;
	NSUInteger loc = 0 ;
	unsigned long end = [mString length] ;
	
	while (loc < end) {
		unichar ch = [mString characterAtIndex:loc] ;
		// Since attachment characters are rare, it is probably
		// cheaper to remove them when found, rather than building
		// up a new string from valid characters.
		if (ch == NSAttachmentCharacter) {
			[mString replaceCharactersInRange:NSMakeRange(loc, 1)
								   withString:@""] ;
			// Get new length
			end = [mString length] ;
		}
		else
			// Just skip over the current character...
			loc++ ;	
	}
	
	NSString* result = [NSString stringWithString:mString] ;
	[mString release] ;
	
	return result ;
}



@end


@implementation NSMutableString (SSYExtraUtils)

- (NSUInteger)replaceOccurrencesOfString:(NSString *)target
								withString:(NSString *)replacement {
	return [self replaceOccurrencesOfString:target
								 withString:replacement
									options:0
									  range:NSMakeRange(0, [self length])] ;
}

@end