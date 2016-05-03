#import "NSString+SSYHttpQueryCruft.h"
#import "Stark.h"

@implementation QueryCruftSpec

- (void)dealloc {
#if !__has_feature(objc_arc)
    [_domain release] ;
    [_key release] ;
    
    [super dealloc] ;
#endif
}

@end

@implementation NSString (SSYRemoveHttpQueryCruft)

- (NSString*)urlStringByRemovingQueryCruftSpecs:(NSArray <QueryCruftSpec*> *)cruftSpecs
                                        error_p:(NSError**)error_p {
    /* Most URLs use '&' to delimit queries, but ';' is also supported. */
    NSCharacterSet* queryDelimiters = [NSCharacterSet characterSetWithCharactersInString:@"&;"] ;
    NSError* error = nil ;
    NSString* answer = self ;
    
    NSURL* url = [[NSURL alloc] initWithString:self] ;
    /* Only proceed if this stark (a) has a non-nil url string and (b) the
     it contains the query string decoded by -[NSURL queryString]  I think
     that this may not be the case for some edge-case URLs.  Just skip any
     such URLs. */
    if (url.query) {
        NSRange rangeOfQuery = [self rangeOfString:url.query] ;
        if (rangeOfQuery.location != NSNotFound) {
            NSString* host = url.host ;
            
            for (QueryCruftSpec* cruftSpec in cruftSpecs) {
                BOOL hostMatch = ((cruftSpec.domain == nil) || [host hasSuffix:cruftSpec.domain]) ;
                if (hostMatch) {
                    NSString* queryString = url.query ;
                    /* We use a scanner here.  I considered using
                     -[NSString componentsSeparatedByString:@"="], but I think
                     that maybe '=' is a legal character in some values, Base 64
                     encoded data in particular.  This way, we should always be
                     in a key and never a value when scanning for '='. */
                    NSScanner* scanner = [[NSScanner alloc] initWithString:queryString] ;
                    NSString* key ;
                    NSMutableArray* rangesToRemove = [NSMutableArray new] ;
                    while (![scanner isAtEnd] && !error) {
                        NSInteger startOfThisPair = [scanner scanLocation] ;
                        [scanner scanUpToString:@"="
                                     intoString:&key] ;

                        /* In case the key has percent escapes in it? */
                        key = [key stringByRemovingPercentEncoding] ;
                        
                        BOOL removeThisPair = NO ;
                        if (cruftSpec.keyIsRegex) {
                            NSRegularExpression* regex = [[NSRegularExpression alloc] initWithPattern:cruftSpec.key
                                                                                              options:0
                                                                                                error:&error] ;
                            
                            removeThisPair = ([regex numberOfMatchesInString:key
                                                                     options:0
                                                                       range:NSMakeRange(0, key.length)] > 0) ;
#if !__has_feature(objc_arc)
                            [regex release] ;
#endif                        
                        }
                        else {
                            if ([key isEqualToString:cruftSpec.key]) {
                                removeThisPair = YES ;
                            }
                        }

                        if (!error) {
                            [scanner scanUpToCharactersFromSet:queryDelimiters
                                                    intoString:NULL] ;
                            
                            if (removeThisPair) {
                                if (startOfThisPair > 0) {
                                    /* Delete the delimiter ('&' or ';')
                                     preceding the key also. */
                                    startOfThisPair-- ;
                                }
                                NSInteger length = scanner.scanLocation - startOfThisPair ;
                                NSString* rangeString = NSStringFromRange(NSMakeRange(startOfThisPair, length)) ;
                                [rangesToRemove addObject:rangeString] ;
                            }
                            
                            [scanner scanCharactersFromSet:queryDelimiters
                                                intoString:NULL] ;
                        }
                        
                    }
                    
#if !__has_feature(objc_arc)
                    [scanner release] ;
#endif
                    if (rangesToRemove.count > 0) {
                        NSMutableString* decruftedQueryString = [queryString mutableCopy] ;
                        /* Must start from the *end* to avoid shifting ranges which
                         have yet to be removed. */
                        for (NSString* rangeString in [rangesToRemove reverseObjectEnumerator]) {
                            NSRange range = NSRangeFromString(rangeString) ;
                            [decruftedQueryString deleteCharactersInRange:range] ;
                        }
                        
                        if ([queryDelimiters characterIsMember:[decruftedQueryString characterAtIndex:0]]) {
                            /* A key/value pair has been moved from a later
                             position to the first position, due to the removal
                             of the former first key/value pair.  It should
                             no longer begin with a delimiter. */
                            [decruftedQueryString deleteCharactersInRange:NSMakeRange(0,1)] ;
                        }
                        
                        NSMutableString* decruftedUrlString = [self mutableCopy] ;
                        [decruftedUrlString replaceCharactersInRange:rangeOfQuery
                                                          withString:decruftedQueryString] ;
                        
                        if (decruftedQueryString.length == 0) {
                            /* Query has been entirely removed.  Remove the
                             question mark character too. */
                            NSInteger locationOfQuestionMark = (decruftedUrlString.length - 1) ;
                            if ([decruftedUrlString characterAtIndex:locationOfQuestionMark] == '?') {
                                [decruftedUrlString replaceCharactersInRange:NSMakeRange(locationOfQuestionMark,1)
                                                                  withString:@""] ;
                            }
                            else {
                                NSAssert1(NO, @"Internal Error 252-4598", self) ;
                            }
                        }
                        
                        answer = [decruftedUrlString copy] ;
                        
#if !__has_feature(objc_arc)
                        [decruftedUrlString release] ;
                        [decruftedQueryString release] ;
                        [answer autorelease] ;
#endif
                    }
                    
#if !__has_feature(objc_arc)
                    [rangesToRemove release] ;
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

@end
