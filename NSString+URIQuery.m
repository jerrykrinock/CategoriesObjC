#import "NSString+URIQuery.h"
#import "NSCharacterSet+SSYMoreCS.h"

static NSString* const constStringRFC3896AdditionsTo2396 = @"!*'();:@&=+$,/?" ;

enum State_enum
{
    StateHopeless = -2,
    StateValidButFiltered = -1,
    StateHoping = 0,
    StateValidAndAccepted = 1
} ;
typedef enum State_enum State ;

/* This function is adapted from https://nullprogram.com/blog/2017/10/06/.
 That blog post refers to a more performant implementation, given here:
 https://github.com/skeeto/branchless-utf8.  But after 2 minutes I was not able
 to get the more efficient implementation to work, and 2 minutes was all I had
 afforded to spend on it.  The problem is certainly related to the 8 vs 16 vs
 32 bit integer sizes used. */
const uint8_t* utf8_simple(const uint8_t* s, uint16_t* c) {
    const unsigned char *next;
    if (s[0] < 0x80) {
        *c = s[0];
        next = s + 1;
    } else if ((s[0] & 0xe0) == 0xc0) {
        *c = ((uint16_t)(s[0] & 0x1f) <<  6) |
             ((uint16_t)(s[1] & 0x3f) <<  0);
        next = s + 2;
    } else if ((s[0] & 0xf0) == 0xe0) {
        *c = ((uint16_t)(s[0] & 0x0f) << 12) |
             ((uint16_t)(s[1] & 0x3f) <<  6) |
             ((uint16_t)(s[2] & 0x3f) <<  0);
        next = s + 3;
    } else if ((s[0] & 0xf8) == 0xf0 && (s[0] <= 0xf4)) {
        *c = ((uint16_t)(s[0] & 0x07) << 18) |
             ((uint16_t)(s[1] & 0x3f) << 12) |
             ((uint16_t)(s[2] & 0x3f) <<  6) |
             ((uint16_t)(s[3] & 0x3f) <<  0);
        next = s + 4;
    } else {
        *c = -1; // invalid
        next = s + 1; // skip this byte
    }
    if (*c >= 0xd800 && *c <= 0xdfff)
        *c = -1; // surrogate half
    return next;
}

/* static_zeroPad is used when creating UTF16 from UTF8. */
uint8_t const static_zeroPad = 0x00;

@interface NSScanner (SSYPercentEscapes)

/*!
 @brief  Scans the next three characters and returns by reference the value of
 the last two characters interpreted to be two hexidecimal digits, as in a
 URL-encoded percent escape sequence
 
 @details  A triplet is, for example, "%CE" or "%ce".  For this method to work
 as intended, when this method is called, the receiver's scanLocation should be
 at (just before) the target '%' character.
 
 @param  into  Upon return, points to the hex value scanned, or to 0 if the
 next two characters are not hex characters.
 
 @result  The count of characters that were scanned – that is, the change in
 the receiver's scan location.  Should be 3 unless the scan location is within
 3 characters of the end of the receiver's string.
 */
- (NSInteger)scanPercentEscapeTripletInto:(uint8_t*)byteValue;

@end

@implementation NSScanner (SSYPercentEscapes)

- (NSInteger)scanPercentEscapeTripletInto:(uint8_t*)byteValue {
    BOOL ok;
    NSInteger countOfScanned;
    NSString* twoHexCharacters = nil;
    NSInteger loc = 0;
    NSInteger len = 0;
    NSInteger originalLoc = 0;
    uint8_t value;

    /* This will only work if we have at least 3 bytes before the end!*/
    ok = self.string.length - self.scanLocation >= 3;
    if (ok) {
        originalLoc = self.scanLocation;
        loc = originalLoc + 1;
        len = 2;
        if (loc+len > self.string.length) {
            len = self.string.length - loc;
            ok = NO;
        }
    }
    
    if (ok) {
        twoHexCharacters = [self.string substringWithRange:NSMakeRange(loc,len)];
        for (NSInteger i=0; i<len; i++) {
            unichar aChar = [twoHexCharacters characterAtIndex:i];
            if (![[NSCharacterSet ssyHexDigitsCharacterSet] characterIsMember:aChar]) {
                ok = NO;
            }
        }
    }
    
    if (ok && (twoHexCharacters.length == 2)) {
        sscanf([twoHexCharacters UTF8String], "%2hhx", &value);
        loc = self.scanLocation + 3;
        if (loc > self.string.length) {
            loc = self.string.length;
        }
        self.scanLocation = loc;
        countOfScanned = loc - originalLoc;
    } else {
        value = 0;
        countOfScanned = 0;
    }

    *byteValue = value;
    return countOfScanned;
}

@end


@implementation NSString (URIQuery)

- (NSString*)encodePercentEscapesStrictlyPerRFC2396 {
	
	CFStringRef decodedString = (CFStringRef)[self decodeAllPercentEscapes] ;
	// The above may return NULL if url contains invalid escape sequences like %E8me, %E8fe, %E800 or %E811,
	// because CFURLCreateStringByReplacingPercentEscapes() isn't smart enough to ignore them.
	CFStringRef recodedString = CFURLCreateStringByAddingPercentEscapes(
																		kCFAllocatorDefault,
																		decodedString,
																		NULL,
																		NULL,
																		kCFStringEncodingUTF8
																		) ;
	// And then, if decodedString is NULL, recodedString will be NULL too.
	// So, we recover from this rare but possible error by returning the original self
	// because it's "better than nothing".
	NSString* answer = (recodedString != NULL) ? [(NSString*)recodedString autorelease] : self ;
	// Note that if recodedString is NULL, we don't need to CFRelease() it.
	// Actually, CFRelease(NULL) causes a crash.  That's kind of stupid, Apple.
	return answer ;
}

- (NSString*)encodePercentEscapesPerStandard:(SSYPercentEscapeStandard)standard
									  butNot:(NSString*)butNot
									 butAlso:(NSString*)butAlso {
	// CFURLCreateStringByAddingPercentEscapes escapes per RFC2396
	if (standard == SSYPercentEscapeStandardRFC3986) {
		// We are going to add some standard butAlso characters.
		// However, we don't want to add a butAlso character which is
		// also in butNot provided by the user, because the butAlso
		// will take precendence in CFURLCreateStringByAddingPercentEscapes().
		// So we need to see if there are any such characters in our 
		// standardButAlso string and if so remove them.
		NSString* standardButAlso = constStringRFC3896AdditionsTo2396 ;
		if ([butNot length] > 0) {
			NSInteger i ;
			NSMutableIndexSet* indexesToRemove = [[NSMutableIndexSet alloc] init] ;
			for (i=0; i<[standardButAlso length]; i++) {
				unichar iChar = [standardButAlso characterAtIndex:i] ;
				NSInteger j ;
				for (j=0; j<[butNot length]; j++) {
					unichar jChar = [butNot characterAtIndex:j] ;
					if (iChar == jChar) {
						[indexesToRemove addIndex:i] ;
						break ;
					}
				}
			}
			
			if ([indexesToRemove count] > 0) {
				NSMutableString* mutatedStandardButAlso = [standardButAlso mutableCopy] ;
				i = [standardButAlso length] ;
				while (YES) {
					NSInteger indexToRemove = [indexesToRemove indexLessThanIndex:i] ;
					if (indexToRemove == NSNotFound) {
						break ;
					}
					[mutatedStandardButAlso deleteCharactersInRange:NSMakeRange(indexToRemove, 1)] ;
					i = indexToRemove ;
				}
				
				standardButAlso = [[mutatedStandardButAlso copy] autorelease] ;
				[mutatedStandardButAlso release] ;
			}
			
			[indexesToRemove release] ;
		}	
		
		if (butAlso) {
			butAlso = [butAlso stringByAppendingString:standardButAlso] ;
		}
		else {
			butAlso = standardButAlso ;
		}
	}
	
	NSString* answer = (NSString*)[(NSString*)CFURLCreateStringByAddingPercentEscapes(
																		  NULL,
																		  (CFStringRef)self,
																		  (CFStringRef)butNot,
																		  (CFStringRef)butAlso,
																		  kCFStringEncodingUTF8
																		  ) autorelease] ;
	return answer ;
}

- (NSString*)encodePercentEscapesPerStandard:(SSYPercentEscapeStandard)standard {
	return [self encodePercentEscapesPerStandard:standard
										  butNot:nil
										 butAlso:nil] ;
}

+ stringWithQueryDictionary:(NSDictionary*)dictionary {
	NSMutableString* string = [NSMutableString string] ;
	NSUInteger countdown = [dictionary count] ;
	NSString* additionsToRFC2396 = @"+=;" ;
	for (NSString* key in dictionary) {		
		[string appendFormat:@"%@=%@",
		 [key encodePercentEscapesPerStandard:SSYPercentEscapeStandardRFC2396
									   butNot:nil
									  butAlso:additionsToRFC2396],
		 [[dictionary valueForKey:key] encodePercentEscapesPerStandard:SSYPercentEscapeStandardRFC2396
																butNot:nil
															   butAlso:additionsToRFC2396]
		 ] ;
		countdown-- ;
		if (countdown > 0) {
			[string appendString:@"&"] ;
		}
	}
	return [NSString stringWithString:string] ;
}

- (NSString*)decodePercentEscapesButNot:(NSString*)butNot {
	if (butNot) {
	}
	else {
		butNot = @"" ;
	}

	// Unfortunately, CFURLCreateStringByReplacingPercentEscapes() seems to only replace %[NUMBER] escapes
	NSString* cfWay = (NSString*)[(NSString*)CFURLCreateStringByReplacingPercentEscapes(
																						kCFAllocatorDefault,
																						(CFStringRef)self,
																						(CFStringRef)butNot
																						)
								  autorelease] ;
	return cfWay ;
}

- (NSString*)stringByFixingPercentEscapes {
    CFStringRef s1 = CFURLCreateStringByReplacingPercentEscapes(kCFAllocatorDefault,
                                                                   (CFStringRef)self,
                                                                   CFSTR("")) ;
    NSString* s2 = (NSString*)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                              s1,
                                                              CFSTR("#"),
                                                              CFSTR("+-"),
                                                              kCFStringEncodingUTF8) ;
    [s2 autorelease] ;
    if (s1) {
        CFRelease(s1) ;
    }
    
    return s2 ;
}

- (BOOL)hasPercentEscapeEncodedCharacters {
	NSString* decodedString = [self decodePercentEscapesButNot:nil] ;
	// Decoding percent escapes will always cause the string to become shorter.
	return ([decodedString length] < [self length]) ;
}

- (void)appendString:(NSString*)aString
         toUtf16Data:(NSMutableData*)utf16Data {
    for (NSInteger i=0; i<aString.length; i++) {
        char aChar = [aString characterAtIndex:i];
        [utf16Data appendBytes:&aChar
                        length:1];
        [utf16Data appendBytes:&static_zeroPad
                        length:1];
    }
}

- (NSRange)pathRangeLoosely {
    /* This remaining code is simply to replace the path.  Sadly,
     NSURL does not feature a method to simply build a path
     from all 10 of its components (scheme, url, user, password,
     host, port, path, parameterString, query, fragment).  And
     there is no NSMutableURL.  So, instead we tediously parse
     the string, find the third slash… */
    NSScanner* scanner = [[NSScanner alloc] initWithString:self];
    NSInteger slashCount  = 0;
    while (![scanner isAtEnd]) {
        [scanner scanUpToString:@"/"
                     intoString:NULL];
        NSInteger scanCount = [scanner scanString:@"/"
                                       intoString:NULL];
        if (scanCount == 1) {
            slashCount++;
        }
        if (slashCount == 3) {
            break;
        }
    }
    
    NSInteger location;
    if (slashCount == 3) {
        location = scanner.scanLocation - 1;
    } else {
        location = NSNotFound;
    }
    
    /* The path of a URL may be followed by a query, parameters, or fragment,
     each of which begins with a certain delimiter. */
    NSCharacterSet* paramQueryAndFragmentDelimiters = [NSCharacterSet characterSetWithCharactersInString:@"?;#"];
    [scanner scanUpToCharactersFromSet:paramQueryAndFragmentDelimiters
                            intoString:NULL];
    NSInteger length;
    if (location != NSNotFound) {
        length = scanner.scanLocation - location;
    } else {
        length = 0;
    }
    [scanner release];
    
    return NSMakeRange(location, length);
}

- (NSString*)decodeOnlyPercentEscapesInUnicodeSet:(NSCharacterSet*)targetSet
                               uppercaseAnyOthers:(BOOL)uppercaseAnyOthers
                          resolveDoubleDotsInPath:(BOOL)resolveDoubleDotsInPath {
    /* Part 1 of 2.  Scan self for percent escapes, and, if any are found,
     create a data object `utf16' of UTF16 little endian encoded bytes.  For
     example, if self is the string "M%C2%B5d" (which is the UTF8
     representation of the string "Mµd"), `utf16` will be created containing
     the six bytes:
       0x4d 0x00 0xc2 0xb5 0x64 0x00 .  In other words, it converts a
     percent-escape encoded UTF8 string to a UTF16 data. */
    NSMutableData* utf16 = nil;
    if (targetSet) {
        NSScanner* scanner = [[NSScanner alloc] initWithString:self] ;
        NSInteger pendingUppercaseCount = 0;
        while (![scanner isAtEnd]) {
            NSString* aString = nil;
            
            [scanner scanUpToString:@"%"
                         intoString:&aString];
            if (utf16) {
                if (aString.length > 0) {
                    if (pendingUppercaseCount > 0) {
                        if (aString.length == 2) {
                            aString = [aString uppercaseString];
                        } else if (aString.length > 2){
                            NSString* aString1 = [aString substringToIndex:2];
                            NSString* aString2 = [aString substringFromIndex:2];
                            aString = [[aString1 uppercaseString] stringByAppendingString:aString2];
                        }
                        pendingUppercaseCount--;
                    }
                    [self appendString:aString
                           toUtf16Data:utf16];
                }
            }
            if ([scanner isAtEnd]) {
                break;
            } else {
                if (!utf16) {
                    utf16 = [NSMutableData new];
                    if (aString) {
                        [self appendString:aString
                               toUtf16Data:utf16];
                    }
                }
                
                /* UTF8 multibyte sequences may have up to 4 bytes … */
                uint8_t escapeSequenceValues[4] = {0,0,0,0};
                NSInteger escapeSequenceByteIndex = 0;
                NSInteger escapeSequenceStartingCharacterIndex = scanner.scanLocation;
                State state = StateHoping;
                NSInteger expectedByteCount = 1;
                while (state == StateHoping) {
                    uint8_t byteValue;
                    NSInteger thisTripletScanned = [scanner scanPercentEscapeTripletInto:&byteValue];
                    if (thisTripletScanned == 3) {
                        escapeSequenceValues[escapeSequenceByteIndex] = byteValue;
                    } else {
                        state = StateHopeless;
                    }
                    
                    if (state == StateHoping) {
                        if (escapeSequenceByteIndex == 0) {
                            /* We have successfully parsed the first triplet of a
                             new candidate escape sequence. */
                            uint8_t firstNibbleValue = (escapeSequenceValues[0] & 0xf0) >> 4;
                            switch(firstNibbleValue) {
                                case 0x0:
                                case 0x1:
                                case 0x2:
                                case 0x3:
                                case 0x4:
                                case 0x5:
                                case 0x6:
                                case 0x7:
                                    /* ASCII character, 0x01 thru 0x7f.  Example: %20, space character */
                                    expectedByteCount = 1;
                                    break;
                                    break;
                                case 0xc:
                                    /* Two-byte UTF8 character.  Example: %CEBC, Greek letter mu  */
                                    expectedByteCount = 2;
                                    break;
                                case 0xe:
                                    /* Three-byte UTF8 character */
                                    expectedByteCount = 3;
                                    break;
                                case 0xf:
                                    /* Four-byte UTF8 character */
                                    expectedByteCount = 4;
                                    break;
                                default:
                                    /* Not a valid percent escape sequence */
                                    expectedByteCount = 0;
                                    state = StateHopeless;
                            }
                            
                            if (state == StateHoping) {
                                if (escapeSequenceByteIndex > expectedByteCount) {
                                    state = StateHopeless;
                                }
                            }
                        }
                    }
                    
                    if (state == StateHoping) {
                        if (escapeSequenceByteIndex == expectedByteCount - 1) {
                            uint16_t codePointValue = 0x0000;
                            utf8_simple(escapeSequenceValues, &codePointValue);
                            if ([targetSet characterIsMember:codePointValue]) {
                                /* We've got a good percent escape sequence. */
                                [utf16 appendBytes:&codePointValue
                                            length:2];
                                state = StateValidAndAccepted;
                            } else if (codePointValue != 0x0000){
                                state = StateValidButFiltered;
                            } else {
                                /* The current bytes in escapeSequenceValues is
                                 invalid.  But we stay in StateHoping because
                                 subsequent iterations of this loop may result
                                 in validity. */
                            }
                        }
                    }
                    
                    switch(state) {
                        case StateValidButFiltered: {
                            if (uppercaseAnyOthers && (pendingUppercaseCount == 0)) {
                                pendingUppercaseCount = expectedByteCount;
                            }
                            // no break – continue to next case
                        }
                        case StateHopeless: {
                            NSInteger nextLocation = escapeSequenceStartingCharacterIndex + 1;
                            if (nextLocation <= scanner.string.length) {
                                scanner.scanLocation = nextLocation;
                            }
                            uint8_t const percent = '%';
                            /* Insert the percent character that we scanned by. */
                            [utf16 appendBytes:&percent
                                        length:1];
                            [utf16 appendBytes:&static_zeroPad
                                        length:1];
                            break;
                        }
                        case StateHoping: {
                            break;
                        }
                        case StateValidAndAccepted: {
                            break;
                        }
                    }
                    
                    escapeSequenceByteIndex++;
                }
            }
        }
        [scanner release];
    }
    
    NSString* answer1 = nil;
    if(utf16) {
#if 0
        printf("The utf16 is:\n   ");
        for (NSInteger k=0; k<utf16.length; k++) {
            printf("0x%02x ", (*((uint8_t*)utf16.bytes + k)));
        }
        printf("\n");
#endif
        /* Part 2 of 2.  Convert UTF16 data to string. */
        answer1 = [[NSString alloc] initWithData:utf16
                                       encoding:NSUTF16LittleEndianStringEncoding];
        [answer1 autorelease];
    }
    [utf16 release];

    NSString* answer;
    if (answer1) {
        answer = answer1;
    } else {
        answer = self;
    }

    NSString* answer2 = nil;
    if (resolveDoubleDotsInPath) {
        NSRange pathRange = [answer pathRangeLoosely];
        if (pathRange.location < answer.length) {
            NSString* path = [answer substringWithRange:pathRange];
            if (path && [path rangeOfString:@"/../"].location != NSNotFound) {
                NSMutableArray* comps = [[path pathComponents] mutableCopy];
                NSMutableIndexSet* doubleDotCompsIndexes = [NSMutableIndexSet new];
                NSInteger i = 0;
                for (NSString* comp in comps) {
                    if ([comp isEqualToString:@".."]) {
                        [doubleDotCompsIndexes addIndex:i];
                    }
                    i++;
                }
                if (doubleDotCompsIndexes.count > 0) {
                    /* So far, our doubleDotCompsIndexes includes only the double
                     dot path components themselves.  We now crete a
                     augmentedDoubleDotIndexes set which also contains indexes
                     of the previous, target path components which those double-dot
                     components imply should be wiped out. */
                    NSMutableIndexSet* augmentedDoubleDotIndexes = [doubleDotCompsIndexes mutableCopy];
                    NSInteger doomedIndex = NSNotFound;
                    while (YES) {
                        doomedIndex = [doubleDotCompsIndexes indexLessThanIndex:doomedIndex];
                        if (doomedIndex < comps.count) {
                            NSInteger k = 1;
                            while (YES) {
                                NSInteger targetIndex = doomedIndex - k;
                                if ([augmentedDoubleDotIndexes containsIndex:targetIndex]) {
                                    k++;
                                } else {
                                    if (targetIndex >= 0) {
                                        [augmentedDoubleDotIndexes addIndex:targetIndex];
                                    }
                                    break;
                                }
                            }
                        } else {
                            break;
                        }
                    }
                    
                    doomedIndex = NSNotFound;
                    while (YES) {
                        doomedIndex = [augmentedDoubleDotIndexes indexLessThanIndex:doomedIndex];
                        if (doomedIndex < comps.count) {
                            [comps removeObjectAtIndex:doomedIndex];
                        } else {
                            break;
                        }
                    }
                    [augmentedDoubleDotIndexes release];
                    
                    NSString* newPath = [NSString pathWithComponents:comps];
                    newPath = [newPath stringByAppendingString:@"/"];
                    
                    /* This remaining code is simply to replace the path.  Sadly,
                     NSURL does not feature a method to simply build a URL
                     from all 10 of its components (scheme, url, user, password,
                     host, port, path, parameters, query, fragment).  And
                     there is no NSMutableURL.  So, instead we tediously parse
                     the string, find the path, and replace it… */
                    NSMutableString* newString = [answer mutableCopy];
                    NSRange pathRange = [answer pathRangeLoosely];
                    if (pathRange.location + pathRange.length <= newString.length) { // Defensive programming
                        [newString replaceCharactersInRange:pathRange
                                                 withString:newPath];
                        answer2 = [newString copy];
                        [answer2 autorelease];
                    }
                    [newString release];
                }
                [comps release];
                [doubleDotCompsIndexes release];
            }
        }
    }
    
    if (answer2) {
        answer = answer2;
    }
    
    return answer ;
}
				 
- (NSString*)decodeAllPercentEscapes {
	// Unfortunately, CFURLCreateStringByReplacingPercentEscapes() seems to only replace %[NUMBER] escapes
	NSString* cfWay = (NSString*)[(NSString*)CFURLCreateStringByReplacingPercentEscapes(kCFAllocatorDefault, (CFStringRef)self, CFSTR("")) autorelease] ;
/*
	// The only action ai've ever seen from the following test is when Input was:
    //    text1=&x=43&y=12&txCadastre=Num%E9ro+du+lot&txMatricule=&txMatricule1=&txMatricule2=&txMatricule3=&txMatricule4=&paroisse=&Txtdivcad1=Lot&Txtdivcad2=Subdivision
    // and in that case both cfWay and cocoaWay were nil.
	// The full URL was probably one of Allison's:
    //    http://evalweb.cum.qc.ca/Role2007actualise/recherche.asp?text1=&x=43&y=12&txCadastre=Num%E9ro+du+lot&txMatricule=&txMatricule1=&txMatricule2=&txMatricule3=&txMatricule4=&paroisse=&Txtdivcad1=Lot&Txtdivcad2=Subdivision
    // (Should have used -isEqualHandlesNilString1:string2: instead of -isEqualToString.)
	NSString* cocoaWay = [self stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ;
	if (![cfWay isEqualToString:cocoaWay]) {
		NSLog(@"Internal Error 402-2626 %s", __PRETTY_FUNCTION__) ;
		NSLog(@" Input: %@", self) ;
		NSLog(@"    CF: %@", cfWay) ;
		NSLog(@" Cocoa: %@", cocoaWay) ;
	}
*/	
	return cfWay ;
}

- (NSDictionary*)queryDictionaryUsingEncoding:(NSStringEncoding)encoding {
	NSCharacterSet* delimiterSet = [NSCharacterSet characterSetWithCharactersInString:@"&;"] ;
	NSMutableDictionary* pairs = [NSMutableDictionary dictionary] ;
	NSScanner* scanner = [[NSScanner alloc] initWithString:self] ;
	while (![scanner isAtEnd]) {
		NSString* pairString ;
		[scanner scanUpToCharactersFromSet:delimiterSet
								intoString:&pairString] ;
		[scanner scanCharactersFromSet:delimiterSet intoString:NULL] ;
		NSArray* kvPair = [pairString componentsSeparatedByString:@"="] ;
		if ([kvPair count] == 2) {
			NSString* key = [[kvPair objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:encoding] ;
			NSString* value = [[kvPair objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:encoding] ;
			[pairs setObject:value forKey:key] ;
		}
	}
	[scanner release] ;
    
	return [NSDictionary dictionaryWithDictionary:pairs] ;
}
			
@end
