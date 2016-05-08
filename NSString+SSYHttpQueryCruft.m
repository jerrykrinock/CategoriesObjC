#import "NSString+SSYHttpQueryCruft.h"
#import "Stark.h"

NSString* constKeyCruftDeskription = @"deskription" ;
NSString* constKeyCruftDomain = @"domain" ;
NSString* constKeyCruftKey = @"key" ;
NSString* constKeyCruftKeyIsRegex = @"keyIsRegex" ;

@implementation NSString (SSYRemoveHttpQueryCruft)

+ (NSCharacterSet*)ssyQueryDelimiters {
    return  [NSCharacterSet characterSetWithCharactersInString:@"&;"] ;
}

- (NSArray <NSString*> *)rangesOfQueryCruftSpecs:(NSArray <NSDictionary*> *)cruftSpecs
                                         error_p:(NSError**)error_p {
    /* Most URLs use '&' to delimit queries, but ';' is also supported. */
    NSError* error = nil ;
    NSArray* answer = nil ;
    
    NSURL* url = [[NSURL alloc] initWithString:self] ;
    NSString* queryString = url.query ;
    /* Only proceed if this stark (a) has a non-nil url string and (b) the
     it contains the query string decoded by -[NSURL queryString]  I think
     that this may not be the case for some edge-case URLs.  Just skip any
     such URLs. */
    if (queryString) {
        NSRange rangeOfQuery = [self rangeOfString:queryString] ;
        if (rangeOfQuery.location != NSNotFound) {
            NSString* host = url.host ;
            
            for (NSDictionary* cruftSpec in cruftSpecs) {
                NSString* specDomain = [cruftSpec objectForKey:constKeyCruftDomain] ;
                BOOL hostMatch = ((specDomain == nil) || [host hasSuffix:specDomain]) ;
                if (hostMatch) {
                    /* We use a scanner here.  I considered using
                     -[NSString componentsSeparatedByString:@"="], but I think
                     that maybe '=' is a legal character in some values, Base 64
                     encoded data in particular.  This way, we should always be
                     in a key and never a value when scanning for '='. */
                    NSScanner* scanner = [[NSScanner alloc] initWithString:queryString] ;
                    NSString* key ;
                    NSMutableArray* cruftRanges = [NSMutableArray new] ;
                    while (![scanner isAtEnd] && !error) {
                        NSInteger startOfThisPair = [scanner scanLocation] ;
                        [scanner scanUpToString:@"="
                                     intoString:&key] ;

                        /* In case the key has percent escapes in it? */
                        key = [key stringByRemovingPercentEncoding] ;
                        
                        BOOL thisPairIsCruft = NO ;
                        NSNumber* keyIsRegexNumber = [cruftSpec objectForKey:constKeyCruftKeyIsRegex] ;
                        BOOL keyIsRegex = NO ;
                        if ([keyIsRegexNumber respondsToSelector:@selector(boolValue)]) {
                            keyIsRegex = keyIsRegexNumber.boolValue ;
                        }
                        NSString* specKey = [cruftSpec objectForKey:constKeyCruftKey] ;
                        if (keyIsRegex) {
                            NSRegularExpression* regex = [[NSRegularExpression alloc] initWithPattern:specKey
                                                                                              options:0
                                                                                                error:&error] ;
                            
                            thisPairIsCruft = ([regex numberOfMatchesInString:key
                                                                      options:0
                                                                        range:NSMakeRange(0, key.length)] > 0) ;
#if !__has_feature(objc_arc)
                            [regex release] ;
#endif                        
                        }
                        else {
                            if ([key isEqualToString:specKey]) {
                                thisPairIsCruft = YES ;
                            }
                        }

                        if (!error) {
                            [scanner scanUpToCharactersFromSet:[[self class] ssyQueryDelimiters]
                                                    intoString:NULL] ;
                            
                            if (thisPairIsCruft) {
                                if (startOfThisPair > 0) {
                                    /* Delete the delimiter ('&' or ';')
                                     preceding the key also. */
                                    startOfThisPair-- ;
                                }
                                NSInteger length = scanner.scanLocation - startOfThisPair ;
                                NSRange rangeOfThisPair = NSMakeRange(rangeOfQuery.location + startOfThisPair, length) ;
                                NSString* rangeString = NSStringFromRange(rangeOfThisPair) ;
                                [cruftRanges addObject:rangeString] ;
                            }
                            
                            [scanner scanCharactersFromSet:[[self class] ssyQueryDelimiters]
                                                intoString:NULL] ;
                        }
                        
                    }
                    
                    if (cruftRanges.count > 0) {
                        answer = [cruftRanges copy] ;
                    }
                    else {
                        answer = nil ;
                    }
                    
#if !__has_feature(objc_arc)
                    [cruftRanges release] ;
                    [scanner release] ;
                    [answer autorelease] ;
#endif
                    if (error) {
                        break ;
                    }
                }
            }
        }
    }
    
#if !__has_feature(objc_arc)
    [url release] ;
#endif
    
    if (error && error_p) {
        *error_p = error ;
        answer = nil ;
    }


    return answer ;
}


- (NSString*)urlStringByRemovingCruftyQueryPairsInRanges:(NSArray <NSString*> *)ranges {
    NSString* answer ;
    if ((ranges.count > 0) && (self.length > 2)) {
        NSMutableString* decruftedSelf = [self mutableCopy] ;

        /* Must start from the *end* to avoid shifting ranges which
         have yet to be removed. */
        NSRange range = NSMakeRange(NSNotFound, 0) ;
        for (NSString* rangeString in [ranges reverseObjectEnumerator]) {
            range = NSRangeFromString(rangeString) ;
            [decruftedSelf deleteCharactersInRange:range] ;
        }
        
        /* At this point, range.location indicates the first character where a
         crufty key/value pair was removed from. */
        
        BOOL shouldRemoveOrphanedQuestionMarkBecauseNoMoreQuery = NO ;
        if ([decruftedSelf characterAtIndex:(range.location - 1)] == '?') {
            /* We have a '?' indicating the start of a query string */
            
            /* Tweak #1: If the query has been entirely removed, remove the '?'
             which delimits its beginning. */

            if (range.location >= decruftedSelf.length) {
                /* We have an empty query (at the end, no fragment). */
                shouldRemoveOrphanedQuestionMarkBecauseNoMoreQuery = YES ;
            }
            else if ([decruftedSelf characterAtIndex:range.location] == '#') {
                /* We have an empty query (followed by a fragment). */
                shouldRemoveOrphanedQuestionMarkBecauseNoMoreQuery = YES ;
            }

            if (shouldRemoveOrphanedQuestionMarkBecauseNoMoreQuery) {
                NSRange questionMarkRange = NSMakeRange((range.location - 1), 1) ;
                [decruftedSelf replaceCharactersInRange:questionMarkRange
                                             withString:@""] ;
            }
            else {
                /* Tweak #2:  If the first key/value pair (which does not begin with
                 a '&' or ';') has been removed and its place taken by any other
                 key/value pair (which does begin with a '&' or ';'), then remove
                 the '&' or ';'. */
                
                if ([[[self class] ssyQueryDelimiters] characterIsMember:[decruftedSelf characterAtIndex:range.location]]) {
                    [decruftedSelf deleteCharactersInRange:NSMakeRange(range.location,1)] ;
                }
            }
        }
        
        answer = [decruftedSelf copy] ;
#if !__has_feature(objc_arc)
        [decruftedSelf release] ;
        [answer autorelease] ;
#endif
    }
    else {
        answer = self ;
    }
    
    return answer ;
}

@end
