#import <Cocoa/Cocoa.h>

/* 
 ***** GENERAL DOCUMENTATION ***** 
 
 ABSTRACT
 
 This category is my replacement for Cocoa's +[NSString localizedStringWithFormat:] method
 and also the NSLocalizedString() macro.  It extends Cocoa's NSString class with five
 additional methods.
 
 DEFINITIONS
 
 Substitution
 
 When substring(s) are substituted into a translated string, for example as in:
	"Put the %@ in the %@", "apples", "basket"
 they are called "substitutions".
 
 Reordering
 
 In many cases, the order in which substitutions occur will be different in
 in different languages.  For example, consider the English string:
    "Put the XXX in the YYY."
 No reordering is needed if the translator wants this:
    "Putten da XXX inta da YYY"
 But in many cases "reordering" is needed because the translator may want something like this:
    "Inta da YYY putten da XXX"
 The problem of Reordering requires that the placeholders be somehow indexed.
 
 MOTIVATIONS
 
 1.  Simpler Reorderable Strings
 
 In Apple documentation Internationalization Programming Topics > Strings Files, Apple
 states their solution to the problem of Reordering (described above):
 "The translator can reorder the arguments in the translated string if that is necessary.
 If a string contains multiple arguments, the translated string can use the
     [n][$] modifier[] n$
 modifier for each argument, where n indicates the position of the original argument."
 Actually, it's not quite as bad as that says.  In fact, after the modifier comes
 immediately the format character (f, e, d, etc.)  If the argument is an NSString,
 the required placeholders are %0$@, %1$@, etc.  These are ghastly.  They become worse when
 you actually use the modifiers, for example $%0$7.2f.  I sure as hell can't type them
 very fast without making lots of mistakes.  And, since the above-referenced Apple
 documentation is so confusing, I'd have to re-document it for our translators anyhow.
 I don't like to explain things that are ghastly.
 
 So, one motivation is to also support the "Classic Mac OS" placeholders %0, %1, %2, 
 which are much easier to use, even though they only allow strings to be substituted.
 In practice, this is a small limitation because > 98% of substitutions in most apps
 are strings anyhow, and the remaining 2% are mostly integers which can be handily
 converted to strings using +[NSString stringWithInt:] provided herein.  The very rare
 case of floats, etc. can be preprocessed with [NSString localizedStringWithFormat:].
 And my implementation of +[NSString localizeFormat:] still supports the ghastly Apple
 syntax for those that really want to use it.
 
 2.  Get the Localization Comments out of the Code
 
 I have no use for the 'comments' argument in NSLocalizedString because I prefer to carefully
 re-use my strings based on comments which I enter directly into a common Localizable.strings
 file.  My comments are sometimes very long and therefore would make my code hard to read if
 there were in every NSLocalizedString() call.  I consider my comments to be a property of the
 string key, not of any particular instantiated use, and that it is the responsiblity of the
 person writing the code to check that the "documentation", i.e. comments, defining a particular
 key before using it.  There are two other alternatives: (1) Never re-use any translations.
 (2) Have translators review the everyting whenever the app is updated.  My localization
 budget does not allow these other alternatives. 
 
 Of course, re-used translations can be poor if you don't define a broad enough scope
 for your translators in your comments, and have some knowledge of international
 linguistics to help you judge what can be generalized. But, again, my localization budget
 cannot afford perfection.
 
 Thus having dispensed with genstrings, I am tired of typing ", nil" in every call to
 NSLocalizedString(). 
 

 TEST CODE AND EXAMPLES
 
 *** To run these tests, paste the following definitions into project's Localizable.strings:
 
 "yessir" = "Oui" ;
 "putStuff" = "Inta da %2 afteren %0 putten %3%% of da %1." ;
 "destroy" = "We had to destroy the %0 in order to save the %0." ;
 "show123" = "first: %@.  second: %@.  third: %@." ;
 "unsignedLongz" = "Unsigned long numbers:\nlittleu: %u\n   bigU: %U\nlittlex: %x\n   bigX: %X\nlittleo: %o\n   bigO: %O\n self: %p" ;
 "putApple" = "Inta da %2$@ afteren %0$@ putten %3$d%% of da %1$@." ;
 "youHaveInteger" = "You have: %1$8i %0$@." ;
 "youHaveFloat" = "You have: $%1$7.2f %0$@ in your %2$@." ;
 "theFractions" = "Your fraction of the %2$@ is %1$0.3e and mine is %0$0.3e." ;
 
 *** And paste this code where it will execute:
 
 #import "SSYLocalize/NSString+Localize.h"
 
 NSString* s ;
 
 // Basic, no substitutions
 // Relevant entry in Localizable.strings:
 // "yessir" = "Oui" ;
 s = [NSString localize:@"yessir"] ;
 NSLog(@"%@", s) ;
 
 // Using the localizeFormat: when there are no subs
 // Wasteful, but works the same
 s = [NSString localizeFormat:@"yessir"] ;
 NSLog(@"%@", s) ;
 
 // Nil-terminate the argument list if you want to.
 // Nil termination is not necessary.
 s = [NSString localizeFormat:@"yessir", nil] ;
 NSLog(@"%@", s) ;
 
 // Simple reorderable string substitutions: %0, %1, %2, ...
 // also demonstrates a literal (escaped) percent %%
 // and preprocessing an integer using +[NSString stringWithInt:]
 // Relevant entry in Localizable.strings:
 // "putStuff" = "Inta da %2 afteren %0 putten %3%% of da %1." ;
 s = [NSString localizeFormat:@"putStuff",
 @"you're done",
 @"peanuts",
 @"bucket",
 [NSString stringWithInt:80]] ;
 NSLog(@"%@", s) ;
 
 // Reorderable string arguments will be re-used if not enough
 // are supplied in the argument list.
 // Relevant entry in Localizable.strings:
 // "destroy" = "We had to destroy the %0 in order to save the %0." ;
 s = [NSString localizeFormat:@"destroy",
 @"village"] ;
 NSLog(@"%@", s) ;
 
 // Simpler nonreorderable string substitutions: %@, %@, %@, ...
 // Relevant entry in Localizable.strings:
 // "show123" = "first: %@.  second: %@.  third: %@." ;
 s = [NSString localizeFormat:@"show123",
 @"alpha",
 @"beta",
 @"gamma"] ;
 NSLog(@"%@", s) ;
 
 // Error indicated if missing entry in Localizable.strings
 s = [NSString localizeFormat:@"Oops some %@ forgot to enter a string for %@.",
 @"This substring will not be used."] ;
 NSLog(@"%@", s) ;
 
 // "unsignedLongz" = "Unsigned long numbers:\nlittleu: %u\n   bigU: %U\nlittlex: %x\n   bigX: %X\nlittleo: %o\n   bigO: %O\n self: %p" ;
 s = [NSString localizeFormat:@"unsignedLongz",
 0xFFFFFF00,
 0xFFFFFF01,
 0xFFFFFF02,
 0xFFFFFF03,
 0xFFFFFF04,
 0xFFFFFF05,
 self] ;
 NSLog(@"%@", s) ;
 
 // Remaining tests use Apple's ("ghastly") syntax (%n$x.yz) for reordering 
 // substitutions.  It is messy but allows arbitrary format specifiers.
 
 // Re-do the peanuts in the bucket example, with apples
 // Relevant entry in Localizable.strings:
 // "putApple" = "Inta da %2$@ afteren %0$@ putten %3$d%% of da %1$@." ;
 s = [NSString localizeFormat:@"putApple",
 @"you're done",
 @"apples",
 @"bucket",
 80] ;
 NSLog(@"%@", s) ;
 
 
 // Relevant entry in Localizable.strings:
 // "youHaveInteger" = "You have: %1$8i %0$@." ;
 s = [NSString localizeFormat:@"youHaveInteger",
 @"toes",
 10] ;
 NSLog(@"%@", s) ;	
 // Relevant entry in Localizable.strings:
 // "youHaveFloat" = "You have: $%1$7.2f %0$@ in your %2$@." ;
 s = [NSString localizeFormat:@"youHaveFloat",
 @"dollars",
 14.95123,  // floats are promoted to double by ...
 @"pocket"] ;
 NSLog(@"%@", s) ;
 // Relevant entry in Localizable.strings:
 // "theFractions" = "Your fraction of the %2$@ is %1$0.3e and mine is %0$0.3e." ;
 s = [NSString localizeFormat:@"theFractions",
 .56789,
 1.2345e-5,
 @"pie"] ;
 NSLog(@"%@", s) ;
 
 NSLog(@"\nTest suite for SSLocalizable is done.") ;
 
 */


@interface NSString (SSYLocalize)

/* 
 Returns a localized string built from formatString and placeholder substitutions
 If formatString
   - is nil, this method will return nil.
   - is an empty string, this method will return the same empty string.
 
 Otherwise, will search the "Localizable.strings" resources in the framework bundle which 
 is named "SSYLocalize" (i.e. one which has a path of the form:
 "/path/to/SSYLocalize.framework).  If formatString is not found,
 this method will return formatString capitalized (UPPER CASE) and followed by 
 " <NOT FOUND>", and will also log the error to stderr.
 
 If formatString is found, will process as explained below.

 This method will parse formatString for percent ("%") characters which denote
 placeholders.  Placeholders will be parsed out (in this order):
    literal % characters by escaping; i.e. %%.
	nonreorderable NSString placeholders %@
    reorderable NSString placeholders %0, %1, %2, ... , %9.
	reorderable arbitrary placeholders n$[modifier][formatChar]
		Examples: %0$@, %1$@, $%0$7.2f

 For formatChar, all of the single-character Format Specifiers listed in:
	String Programming Guide For Cocoa > String Format Specifiers 
        > Format Specifiers > Table 1
 are supported.  Specifically, these are:
	@, c, C, d, D, i, e, f, F, g, G, s, S, p, u, U, x, X, o, O

 The same reorderable placeholder may be used more than once, for example,
	"We had to destroy the %0 in order to save the %0."

 There is no need to nil-terminate the argument list.
  
 DISCUSSION
 
 As is typical of methods based on va_arg, it's easy to cause a crash.  Here,
 the number of placeholders with unique index numbers in in the first argument
 (the format string) must be <= number of remaining arguments (placeholder
 substitutions).  (The alternative design is to require that argument lists
 be nil-terminated, but that often results in crashes too.)  For example, the
 following formatString will cause a crash if it is not followed by at least
 two arguments:
     "We had to destroy the %@ in order to save the %@."
 
 You can still use the simple reorderable NSString placeholders %0, %1, %2,...
 to process numbers by preprocessing the arguments.
 If you want to substitute in an integer, preprocess it with
      +[NSString stringWithInt:].
 If you want to substitute in a float, preprocess it with 
      +[NSString localizedStringWithFormat:],
 which will give a string "locale-ized" to the user's default locale.
 For example, the decimal point may be a comma in some locales.

*/
+ (NSString*)localizeFormat:(NSString*)formatString, ... ;

/*
 Same as localizeFormat:, except that if formatString is not found in any relevant
 "Localizable.strings", will return formatString and will not log anything
 to stderr.
*/
+ (NSString*)weaklyLocalizeFormat:(NSString*)formatString, ... ;

/*
 Convenient and cheaper-running method for when there are no substitutions. 
 keyString should be a key in Localizable.strings.
 keyString may include literal percent characters (%) without escaping. 
*/
+ (NSString*)localize:(NSString*)keyString ;

/*
 Same as localize:, except that if keyString is not found in any relevant
 "Localizable.strings", will return formatString and will not log anything
 to stderr.
*/
+ (NSString*)localizeWeakly:(NSString*)keyString ;

/*
 Returns the nominal two-letter code of the language which is loaded and currently
 running in the application.  Actually, it simply returns the value of the entry
 in Localizable.strings for the key "000_language", but if this entry is missing
 it returns "en" (for English).
*/
+ (NSString*)languageCodeLoaded ;

/*
 returns a string representation of the integer.  Examples: "1" "42", "-579".
*/
+ (NSString*)stringWithInt:(NSInteger)i ;

@end

