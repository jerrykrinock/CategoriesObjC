#import "NSString+URIQuery.h"
#import "NSCharacterSet+SSYMoreCS.h"

static NSString* const constStringRFC3896AdditionsTo2396 = @"!*'();:@&=+$,/?" ;

/* This function is adapted from https://nullprogram.com/blog/2017/10/06/ */
const unsigned char* utf8_simple(const unsigned char *s, uint16_t *c) {
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

@interface NSScanner (SSYPercentEscapes)

- (void)scanPercentEscapeTripletIntoData:(NSMutableData*)data;

@end

@implementation NSScanner (SSYPercentEscapes)

/* This method assusmes that the given scanner.scanLocation is at the "%". */
- (void)scanPercentEscapeTripletIntoData:(NSMutableData*)data {
    NSString* twoHexCharacters = [self.string substringWithRange:NSMakeRange(self.scanLocation + 1, 2)];
    unsigned short codeValue;
    sscanf([twoHexCharacters UTF8String], "%2hx", &codeValue) ;
    [data appendBytes:&codeValue
               length:1];
    self.scanLocation = self.scanLocation + 3;
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

- (NSString*)decodeOnlyPercentEscapesInUnicodeIndexSet:(NSIndexSet*)indexSet {
    /* Part 1 of 3.  Scan self for percent escapes, and, if any are found,
     create a data object UTF8 encoded bytes.  For example, if self is
     the string "M%C2%B5d" (which is the UTF8 representation of the string
     "Mµd"), `data` will be created containing the four bytes:
       0x4d 0xc2 0xb5 0x64.  In other words, it converts a percent-escape
     encoded UTF8 string to a UTF8 data. */
	NSScanner* scanner = [[NSScanner alloc] initWithString:self] ;
	NSMutableData* data = nil ;
    while (![scanner isAtEnd]) {
        NSString* aString = nil;
        [scanner scanUpToString:@"%"
                     intoString:&aString];
        /* The following will be a no-op if `data` is still nil. */
        [data appendData:[aString dataUsingEncoding:NSUTF8StringEncoding]];
        if ([scanner isAtEnd]) {
            break;
        } else {
            scanner.scanLocation = scanner.scanLocation + 1;
            if (!data) {
                data = [NSMutableData data];
                if (aString) {
                    [data appendData:[aString dataUsingEncoding:NSUTF8StringEncoding]];
                }
            }

            // Next two characters are the next byte of a UTF8 sequence
            unichar lengthChar = [self characterAtIndex:scanner.scanLocation];
            NSInteger percentCount;
            switch(lengthChar) {
                case 'c':
                case 'C':
                    percentCount = 2;
                    break;
                case 'e':
                case 'E':
                    percentCount = 3;
                    break;
                case 'f':
                case 'F':
                    percentCount = 4;
                    break;
                default:
                    percentCount = 0;
                    NSLog(@"Error 484");
            }
            scanner.scanLocation = scanner.scanLocation - 1;
            for (NSInteger i=0; i<percentCount; i++) {
                [scanner scanPercentEscapeTripletIntoData:data] ;
            }
        }
    }
    
    NSString* answer;
    if(!data) {
        answer = self ;
    }
    else {
        /* Part 2 of 3.  Convert UTF8 data to UTF16 data.  */
        const void* startingPointer = [data bytes];
        const void* nextBytePointer = startingPointer;
        /* Count of characters in output can be no longer than data.length. */
        NSInteger length = data.length;
        uint16_t* output = malloc(length * sizeof(uint16_t));
        NSInteger j = 0;
        while (nextBytePointer < startingPointer + length) {
            uint16_t nextWideChar;
            nextBytePointer = utf8_simple(nextBytePointer, &nextWideChar);
            output[j] = nextWideChar;
            j++;
        }

#if 0
        printf("The output is:\n");
        for (NSInteger i=0; i<j; i++) {
            printf("i=%ld:0x%04x ", (long)i, output[i]);
        }
        printf("\nEnd of output.\n");
#endif
        /* Part 3 of 3.  Convert UTF16 data to string. */
        answer = [[NSString alloc] initWithBytes:output
                                          length:j*sizeof(uint16_t)
                                        encoding:NSUTF16LittleEndianStringEncoding];
        free(output);
        [answer autorelease];
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
