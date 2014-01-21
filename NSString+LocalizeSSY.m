#import "NSString+LocalizeSSY.h"
#import "NSScanner+GeeWhiz.h"
#import "NSString+VarArgs.h"
#import "NSBundle+MainApp.h"

NSString* SSStringNotFoundAnnouncer = @" <NOT FOUND>" ;

@implementation NSString (LocalizeSSY)

- (NSString*)localizedTableValue {
	NSBundle* bundle = [NSBundle mainAppBundle] ;

	// To return nil if not found in Localizable.strings.
	NSString* answer = nil ;
	
	NSString* s = [bundle localizedStringForKey:self
										  value:SSStringNotFoundAnnouncer  // returned if not found in any Localizable.strings
										  table:@"Localizable"] ;
	// I would have preferred to use @"" for value, but that doesn't work.
	// I'd call this a bug in localizedStringForKey:value:table:
	if (![s isEqualToString:SSStringNotFoundAnnouncer]) {
		// This is the normal case
		answer = s ;
	}
	
	return answer ;
}

- (NSString*)notFoundInLocalizedTableValue {
	return [[self uppercaseString] stringByAppendingString:SSStringNotFoundAnnouncer] ;
}

+ (NSString*)localize:(NSString*)keyString {
	NSString* answer = [keyString localizedTableValue] ;
	if (answer == nil) {
		answer = [keyString notFoundInLocalizedTableValue] ;
	}
	
	return answer ;	
}

+ (NSString*)localizeWeakly:(NSString*)keyString {
	NSString* answer = [keyString localizedTableValue] ;
	if (answer == nil) {
		answer = keyString ;
	}
	
	return answer ;	
}

+ (NSString*)localizeFormat:(NSString*)formatString, ... {
	NSString* answer ;
	BOOL canDo = YES ;
	
	if (formatString == nil) {
		answer = nil ;
		canDo = NO ;
	}	
	
	if ([formatString length] == 0) {
		answer = formatString ;
		canDo = NO ;
	}
	
	NSString* s = [formatString localizedTableValue] ;
	if (s == nil) {
		answer = [formatString notFoundInLocalizedTableValue] ;
		canDo = NO ;
	}
	
	if (canDo) {
		va_list argPtr ;
		va_list* argPtr_p = &argPtr ;
		
		// Note that we pass argPtr by reference.  The reason for this may be explained in:
		// http://groups.google.com/group/gnu.gcc.help/browse_thread/thread/c4a6b74860b0899f/cbd1f71fd1613b7d?lnk=gst&q=va_arg#
		// More practically, I find (in project varArgsWeirdness), that if I pass
		// the actual argPtr instead of &argPtr, va_arg() in the subroutine fails to
		// increment when called.  Each call gives the same (first) argument.  It
		// just stays stuck there and doesn't move.  (1-2 hours to learn and fix!!!)

		va_start(argPtr, formatString) ;
		answer = [self replacePlaceholdersInString:s
										  argPtr_p:argPtr_p];
		va_end(argPtr) ;
	}
	
	return answer ;
}

// weaklyLocalizeFormat: is the same as localizeFormat: except for the answer when (s == nil)
// However, we cannot factor out any more because of the requirement that argPtr be
// declared within the function that has the variable arguments.

+ (NSString*)weaklyLocalizeFormat:(NSString*)formatString, ... {
	NSString* answer ;
	BOOL canDo = YES ;
	
	if (formatString == nil) {
		answer = nil ;
		canDo = NO ;
	}	
	
	if ([formatString length] == 0) {
		answer = formatString ;
		canDo = NO ;
	}
	
	NSString* s = [formatString localizedTableValue] ;
	if (s == nil) {
		answer = formatString ;
		canDo = NO ;
	}
	
	if (canDo) {
		va_list argPtr ;
		va_list* argPtr_p = &argPtr ;
		
		// Note that we pass argPtr by reference.  The reason for this may be explained in:
		// http://groups.google.com/group/gnu.gcc.help/browse_thread/thread/c4a6b74860b0899f/cbd1f71fd1613b7d?lnk=gst&q=va_arg#
		// More practically, I find (in project varArgsWeirdness), that if I pass
		// the actual argPtr instead of &argPtr, va_arg() in the subroutine fails to
		// increment when called.  Each call gives the same (first) argument.  It
		// just stays stuck there and doesn't move.  (1-2 hours to learn and fix!!!)
		
		va_start(argPtr, formatString) ;
		answer = [self replacePlaceholdersInString: s argPtr_p: argPtr_p];
		va_end(argPtr) ;
	}
	
	return answer ;
}

+ (NSString*)languageCodeLoaded {
	NSString* key = @"000_language" ;
	NSString* value = [self localizeWeakly:key] ;
	if ([value isEqualToString:key]) {
		value = @"en" ;
	}
	
	return value ;
}


@end