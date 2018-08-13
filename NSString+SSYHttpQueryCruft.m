#import "NSString+SSYHttpQueryCruft.h"

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
            
            NSMutableArray* cruftRanges = [NSMutableArray new] ;
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
                            NSRange wholeKey = NSMakeRange(0, key.length) ;
                            NSInteger countOfMatches = [regex numberOfMatchesInString:key
                                                                              options:0
                                                                                range:wholeKey] ;
                            thisPairIsCruft = (countOfMatches > 0) ;
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
                                NSInteger length = scanner.scanLocation - startOfThisPair ;
                                NSRange rangeOfThisPair = NSMakeRange(rangeOfQuery.location + startOfThisPair, length) ;
                                NSString* rangeString = NSStringFromRange(rangeOfThisPair) ;
                                if ([cruftRanges indexOfObject:rangeString] == NSNotFound) {
                                    [cruftRanges addObject:rangeString] ;
                                }
                            }
                            
                            [scanner scanCharactersFromSet:[[self class] ssyQueryDelimiters]
                                                intoString:NULL] ;
                        }
                        
                    }
                    
                    
#if !__has_feature(objc_arc)
                    [scanner release] ;
#endif
                    if (error) {
                        break ;
                    }
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
            [answer autorelease] ;
#endif
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

        /* Before beginning, because we are going to remove ranges, we must
         sort them into descending order of .location. */
        NSMutableArray* sortedRanges = [ranges mutableCopy];
        [sortedRanges sortUsingComparator:^NSComparisonResult(id  _Nonnull s1, id  _Nonnull s2) {
            NSInteger loc1 = NSRangeFromString(s1).location;
            NSInteger loc2 = NSRangeFromString(s2).location;
            if (loc1 < loc2) {
                return NSOrderedDescending;
            }
            else if (loc1 > loc2) {
                return NSOrderedAscending;
            }
            else {
                return NSOrderedSame;
            }
        }];

        /* Firstly, we remove the key/value pairs themselves. */
        NSInteger beginningOfHighestRemovedPair = NSRangeFromString(sortedRanges.firstObject).location ;
        NSRange range = NSMakeRange(NSNotFound, 0) ;
        for (NSString* rangeString in sortedRanges) {
            range = NSRangeFromString(rangeString) ;
            [decruftedSelf deleteCharactersInRange:range] ;
        }

#if !__has_feature(objc_arc)
        [sortedRanges release];
#endif
        /* At this point,
         .  * decruftedSelf may end with a string of delimiters due to the
         .    removed key/value pairs.  Example:
         .        https://www.youtube.com/watch?&v=2jg33NUsCAg&&&&&
         .  * range.location indicates the first character where a crufty
         .    key/value pair was removed from.

         Our second task is to now remove those delimiters. */

        NSScanner* scanner = [[NSScanner alloc] initWithString:decruftedSelf] ;
        NSMutableIndexSet* indexesOfOrphanedDelimiters = [[NSMutableIndexSet alloc] init] ;
        /* Fast-forward up to the beginning of the query, but back by 1 because
         the first delimiter would be 1 character before the beginning of the
         first key/value pair. */
        [scanner setScanLocation:(range.location - 1)] ;
        while (YES) {
            /* Scan up to the next delimiter */
            [scanner scanUpToCharactersFromSet:[[self class] ssyQueryDelimiters]
                                    intoString:NULL] ;
            NSInteger location1 = scanner.scanLocation ;
            BOOL isStartOfQuery = [decruftedSelf characterAtIndex:(location1 - 1)] == '?' ;
            /* Scan up to the next non-delimiter */
            [scanner scanUpToCharactersFromSet:[[[self class] ssyQueryDelimiters] invertedSet]
                                    intoString:NULL] ;
            NSInteger location2 = scanner.scanLocation ;

            /* The difference between location2 and location1 is the number of
             consecutive delimiter characters. */
            NSInteger properCountOfConsecutiveDelimiters ;
            if (isStartOfQuery) {
                properCountOfConsecutiveDelimiters = 0 ;
            }
            else if ([scanner isAtEnd]) {
                /* We are at the end of the query, and there is no fragment. */
                properCountOfConsecutiveDelimiters = 0 ;
            }
            else if ([decruftedSelf characterAtIndex:scanner.scanLocation] == '#') {
                /* We are at the end of the query, before the fragment. */
                properCountOfConsecutiveDelimiters = 0 ;
            }
            else {
                /* We are between two key/value pairs. */
                properCountOfConsecutiveDelimiters = 1 ;
            }

            /* Remember the indexes of orphaned delimiters. */
            while (location2 - location1 > properCountOfConsecutiveDelimiters) {
                [indexesOfOrphanedDelimiters addIndex:(location2-1)] ;
                location2-- ;
            }
            
            if (scanner.isAtEnd) {
                break ;
            }

            /* Also break when we get to the end of the query (so we
             don't go into the # fragment portion. */
            if (scanner.scanLocation > beginningOfHighestRemovedPair) {
                break ;
            }
        }

        /* Actually remove the orphaned delimiters. */
        NSInteger i = [indexesOfOrphanedDelimiters lastIndex] ;
        while ((i != NSNotFound)) {
            [decruftedSelf deleteCharactersInRange:NSMakeRange(i,1)] ;
            i = [indexesOfOrphanedDelimiters indexLessThanIndex:i] ;
        }

        /* Thirdly, if all key/value pairs have been removed, we must remove
         the '?'.  We consider for two possibilities, without a fragment and
         with a fragment. */
        if ([decruftedSelf hasSuffix:@"?"]) {
            [decruftedSelf deleteCharactersInRange:NSMakeRange(decruftedSelf.length - 1, 1)] ;
        }
        [decruftedSelf replaceOccurrencesOfString:@"?#"
                                       withString:@"#"
                                          options:0
                                            range:NSMakeRange(0, decruftedSelf.length)] ;
        
#if !__has_feature(objc_arc)
        [scanner release] ;
        [indexesOfOrphanedDelimiters release] ;
#endif
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
