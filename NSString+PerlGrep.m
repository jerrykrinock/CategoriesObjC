#import "NSString+PerlGrep.h"
#import "SSYShellTasker.h"
#import "NSString+Truncate.h"
#import "NSError+InfoAccess.h"
#import "NSString+SSYExtraUtils.h"
#import "NSError+MoreDescriptions.h"
#import "NSError+MyDomain.h"


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
	// The part before the @ in an email address, which is commonly
	// thought of as the "account name", is, technically, called the
	// "local-part" in RFC 2821 and RFC 5321.  Unfortunately, these
	// RFC do not very well specify what characters are allowed in the
	// local-part.  So I got the answer instead from here…
	// http://www.remote.org/jochen/mail/info/chars.html
	// I included all of the characters that Jochen lists as YES or MAYBE.
	// Because many of these characters are also quantifiers in Perl regex,
	// and because I got frustrated, I just backslash-escaped all of them.
	// Note that the first item, \\w, means 0-9, a-z, A-Z, and _.
	NSString* localCharacterPattern = @"[\\w\\-\\+\\&\\'\\*\\/\\=\\?\\^\\{\\}\\~\\.]+" ;
	// Actually, double-backslashes are used to escape the NSString constant compilation.
	// The last item, \\., was added in BookMacster 1.11 to fix the bug that
	// firstname.lastname@gmail.com was being returned as lastname.gmail.com.

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
