#import "NSString+UserAgents.h"
#import "NSScanner+GeeWhiz.h"

@implementation NSString (UserAgents)

- (NSString*)browserNameFromUserAgentStringAmongCandidates:(NSArray*)candidates {
	// self should be one of these:
	// OmniWeb:   Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_2; en-US) AppleWebKit/531.9+(KHTML, like Gecko, Safari/528.16) OmniWeb/v622.11.0
	// Opera:     Opera/9.80 (Macintosh; Intel Mac OS X; U; en) Presto/2.2.15 Version/10.10
	// Firefox:   Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; en-US; rv:1.9.1.7) Gecko/20091221 Firefox/3.5.7
	// Minefield: Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; en-US; rv:1.9.3a2pre) Gecko/20100214 Minefield/3.7a2pre
	// Camino:    Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; en; rv:1.9.0.16pre) Gecko/2009113000 Camino/2.1a1pre (like Firefox/3.0.16pre)
	// Safari:    Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_2; en-us) AppleWebKit/531.21.8 (KHTML, like Gecko) Version/4.0.4 Safari/531.21.10
	// Chrome:    Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_6; en-US) AppleWebKit/534.10 (KHTML, like Gecko) Chrome/8.0.552.237 Safari/534.10
	
	// First, remove any parenthesized clauses
	NSScanner* scanner = [[NSScanner alloc] initWithString:self] ;
	[scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@""]] ;
	NSMutableString* nonparenthesized = [[NSMutableString alloc] init] ;
	while (![scanner isAtEnd]) {
		NSString* scanned = @"" ;
		[scanner scanUpToAndThenLeapOverString:@"("
									intoString:&scanned] ;
		[scanner scanUpToAndThenLeapOverString:@")"
									intoString:NULL] ;
		[nonparenthesized appendString:scanned] ;
	}
	[scanner release] ;
	
	// nonparenthesized should be one of these:
	// Mozilla/5.0  AppleWebKit/531.9+ OmniWeb/v622.11.0
	// Opera/9.80  Presto/2.2.15 Version/10.10
	// Mozilla/5.0  Gecko/20091221 Firefox/3.5.7
	// Mozilla/5.0  Gecko/20100214 Minefield/3.7a2pre
	// Mozilla/5.0  Gecko/2009113000 Camino/2.1a1pre 
	// Mozilla/5.0  AppleWebKit/531.21.8  Version/4.0.4 Safari/531.21.10
	// Mozilla/5.0  AppleWebKit/534.10  Chrome/8.0.552.237 Safari/534.10
	
	// Split at spaces
	NSString* trimmed = [nonparenthesized stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] ;
	[nonparenthesized release] ;
	NSArray* clauses = [trimmed componentsSeparatedByString:@" "] ;
	
	NSString* chosenCandidate = nil ;
	// Choose the candidate from the first
	// clause that begins with a candidate
	for (NSString* clause in clauses) {
		for (NSString* candidate in candidates) {
			if ([clause hasPrefix:candidate]) {
				chosenCandidate = candidate ;
				break ;
			}
		}
		
		if (chosenCandidate) {
			break ;
		}
	}
	
	return chosenCandidate ;
}

@end