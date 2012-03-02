#import "NSString+PerlGrep.h"
#import "SSYShellTasker.h"
#import "NSString+Truncate.h"
#import "NSError+SSYAdds.h"
#import "NSString+SSYExtraUtils.h"


@implementation NSString (PerlGrep)

- (NSString*)stringByGreppingMatchPattern:(NSString*)matchPattern
							   outPattern:(NSString*)outPattern
								  error_p:(NSError**)error_p {
	if (!matchPattern && !outPattern) {
		return nil ;
	}
	
	// We want Perl to get the whole thing as one long line of stdin.
	// So we replace all newlines with spaces.
	// Another way to do this would be to add the -p option switch
	// in the command line to perl, i.e. "-Wwp" as the first arg.
	// But I couldn't get that to work properly.  It kept printing stdin.
	NSString* s = [self stringByReplacingAllOccurrencesOfString:@"\n"
													 withString:@" "] ;
	NSData* stdinToPerl = [s dataUsingEncoding:NSUTF8StringEncoding] ;
	NSString* perlCode = [NSString stringWithFormat:
						  @"<STDIN> =~ m/%@/ ; if($1&&$2&&$3){print \"%@\";}",
						  matchPattern,
						  outPattern] ;	
	NSData* stdoutFromPerl = nil ;
	NSData* stderrFromPerl = nil ;
	NSError* error = nil ;	
	NSArray* args = [NSArray arrayWithObjects:
					 @"-Ww",
					 @"-e",
					 perlCode,
					 nil] ;
	NSInteger resultFromPerl = [SSYShellTasker doShellTaskCommand:@"/usr/bin/perl"
														arguments:args
													  inDirectory:nil
														stdinData:stdinToPerl
													 stdoutData_p:&stdoutFromPerl
													 stderrData_p:&stderrFromPerl
														  timeout:1.0
														  error_p:&error] ;
	NSString* stringOut = nil ;
	if ([stdoutFromPerl length] > 0) {
		stringOut = [[[NSString alloc] initWithData:stdoutFromPerl
										   encoding:NSUTF8StringEncoding] autorelease] ;
	}
	
	if ((resultFromPerl != 0) || ([stderrFromPerl length] > 0)) {
		if (error_p) {
			if (!error) {
				error = SSYMakeError(298594, @"Perl grep error") ;
			}
			
			NSString* perlErrorString = [[[NSString alloc] initWithData:stderrFromPerl
															   encoding:NSUTF8StringEncoding] autorelease] ;
			
			error = [error errorByAddingUserInfoObject:perlErrorString
												forKey:@"Perl Error"] ;
			error = [error errorByAddingUserInfoObject:[self stringByTruncatingMiddleToLength:256
																				   wholeWords:NO]
												forKey:@"Input"] ;
			error = [error errorByAddingUserInfoObject:matchPattern
												forKey:@"Match Pattern"] ;
			error = [error errorByAddingUserInfoObject:outPattern
												forKey:@"Out Pattern"] ;
			error = [error errorByAddingUserInfoObject:stringOut
												forKey:@"Grep Output"] ;
			
			*error_p = error ;
		}
	}
	
	return stringOut ;
}

- (NSString*)extractEmail {
	// RFC 2821, 2822 specifies the characters that are valid in the "local" 
	// part of an email address, the part before the @, that is, the account name.
	// Because many of these characters are also quantifiers in Perl regex,
	// and because I got frustrated, I just backslash-escaped all of them.
	// Actually, double-backslashes are used to escape the NSString constant compilation.
	NSString* localCharacterPattern = @"[\\w\\-\\+\\&\\'\\*\\/\\=\\?\\^\\{\\}\\~]+" ;
	// RFC 1123 specifies the characters that are valid in the hostname labels.
	// They do not include the underscore, so I don't use \w.
	// Actually, a double-backslash is used to escape the NSString constant compilation.
	NSString* hostnameLabelPattern = @"[a-zA-z0-9\\-]+" ;
	NSString* matchPattern = [NSString stringWithFormat:
							  @"(%@)@(%@).(%@)",
							  localCharacterPattern,
							  hostnameLabelPattern,
							  hostnameLabelPattern] ;
	NSString* outPattern = @"$1\\@$2.$3" ;
	NSError* grepError = nil ;
	
	NSString* email = [self stringByGreppingMatchPattern:matchPattern
											  outPattern:outPattern
												 error_p:&grepError] ;
	
	if (grepError) {
		NSLog(@"%s: Error grepping for email: %@", __PRETTY_FUNCTION__, [grepError longDescription]) ;
	}
	
	return email ;
}

@end
