#import "NSString+URIQuery.h"
#import "NSCharacterSet+SSYMoreCS.h"

static NSString* const constStringRFC3896AdditionsTo2396 = @"!*'();:@&=+$,/?" ;


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

#if 0
This work-in-progress does not handle multi-byte encoded characters.
- (NSString*)decodePercentEscapesOnly:(NSIndexSet*)valuesToBeDecoded {
	NSScanner* scanner = [[NSScanner alloc] initWithString:self] ;
	NSMutableString* mutant = nil ;
	while (![scanner isAtEnd]) {
		NSString* priorString ;
		[scanner scanUpToString:@"%"
					 intoString:&priorString] ;
		if ([scanner isAtEnd]) {
			if (mutant) {
				[appendString priorString] ;
			}
			else {
				break;
			}
		}
		else {
			[scanner scanString:@"%@"
					 intoString:NULL] ;
			NSString* hexString ;
			BOOL foundHex = [scanner scanCharactersFromSet:[NSCharacterSet ssyHexDigitsCharacterSet]
												intoString:&hexString] ;
			if (foundHex) {
				int16_t codeValue ;
				sscanf([hexString UTF8String], @"%2hx", &codeValue) ;
				if (!mutant) {
					mutant = [[NSMutableDictionary alloc] init] ;
				}
				
				[mutant appendString:priorString] ;
				[mutant appendFormat:@"%c", codeValue] ;
			}
			else {
				[scanner set
			}

		}
	}
	
	if(!mutant) {
		answer = self ;
	}
	else {
		answer = [[mutant copy] autorelease] ;
	}
	
	[mutant release] ;
	
	return answer ;
}
#endif
				 
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