#import "NSInvocation+MoreDescriptions.h"
#import "NSObject+MoreDescriptions.h"

@implementation NSInvocation (MoreDescriptions)

- (NSString*)shortDescription {
	return [NSString stringWithFormat:
			@"<%@ %p targ=%@ sel=%@>",
			[self className],
			self,
			[[self target] shortDescription],
			NSStringFromSelector([self selector])] ;
}

- (NSString*)longDescription {
	int nArgs = [[self methodSignature] numberOfArguments] ;
	NSScanner* scanner = [[NSScanner alloc] initWithString:NSStringFromSelector([self selector])] ;
	NSMutableString* msg = [NSMutableString string] ;
	NSString* piece ;
	int iArg = 2 ; // Because arguments 0 and 1 and cmd and sel
	while (![scanner isAtEnd]) {
		piece = @"" ;
		[scanner scanUpToString:@":"
					 intoString:&piece] ;
		if ([piece length] > 0) {
			// Scanned part of selector name
			[msg appendString:@"\n  "] ;
			[msg appendString:piece] ;
			[msg appendString:@":"] ;
		}
		piece = @"" ;
		if ([scanner scanString:@":"
					 intoString:&piece]) {
			// This piece has an argument
			[msg appendFormat:@"(arg %d/%d)", iArg, nArgs] ;
			NSString* argDesc = @"Internal Error 655-6086";
			if(iArg < nArgs) {
				const char* argType = [[self methodSignature] getArgumentTypeAtIndex:iArg] ;
				// The following argTypes are the common ones I have seen.
				// There are more in The Mac Hacker’s Handbook by
				// by Charlie Miller and Dino Dai Zovi, pg. 143

				if (!strcmp(argType, "@")) {
					// The argument is an object
					id arg = nil ;
					[self getArgument:&arg
							  atIndex:iArg] ;
					if (arg) {
						argDesc = [arg deepNiceDescription] ;
					}
					else {
						argDesc = @"A nil object" ;
					}
				}
				else if (!strcmp(argType, "^@")) {
					// The argument is a pointer to an object
					void* arg ;
					[self getArgument:&arg
							  atIndex:iArg] ;
					// We don't attempt to dig into the object because it might be invalid.
					argDesc = [NSString stringWithFormat:
							   @"type=id* value=%p",
							   arg] ;
				}
				else if (!strcmp(argType, "i")) {
					// The argument is an integer
					int arg ;
					[self getArgument:&arg
							  atIndex:iArg] ;
					argDesc = [NSString stringWithFormat:
							   @"type=int value = %d",
							   arg] ;
				}
				else if (!strcmp(argType, "c")) {
					// The argument is an BOOL or unsigned char
					unsigned char arg ;
					[self getArgument:&arg
							  atIndex:iArg] ;
					argDesc = [NSString stringWithFormat:
							   @"type=BOOL/uchar decimalValue=%d charValue='%c'",
							   arg,
							   arg] ;
				}
				else if (!strcmp(argType, ":")) {
					SEL arg ;
					[self getArgument:&arg
							  atIndex:iArg] ;
					// The argument is a selector
					argDesc = [NSString stringWithFormat:
							   @"type=SEL value=%@",
							   NSStringFromSelector((SEL)arg)] ;
				}
				else if (!strcmp(argType, "#")) {
					// The argument is a Class object
					Class arg ;
					[self getArgument:&arg
							  atIndex:iArg] ;
					argDesc = [NSString stringWithFormat:
							   @"type=Class value=%@",
							   NSStringFromClass((Class)arg)] ;
				}
				else if (!strcmp(argType, "f")) {
					// The argument is a float
					float arg ;
					[self getArgument:&arg
							  atIndex:iArg] ;
					argDesc = [NSString stringWithFormat:
							   @"type=float value=%f",
							   arg] ;
				}
				else if (!strcmp(argType, "d")) {
					// The argument is a double
					double arg ;
					[self getArgument:&arg
							  atIndex:iArg] ;
					argDesc = [NSString stringWithFormat:
							   @"type=double value=%f",
							   arg] ;
				}
				else if (!strcmp(argType, "^v")) {
					// The argument is probably a block
					void* arg ;
					[self getArgument:&arg
							  atIndex:iArg] ;
					argDesc = [NSString stringWithFormat:
							   @"type=block (I think) value=%p",
							   arg] ;
				}
				else {
					argDesc = [NSString stringWithFormat:
							   @"typeCode='%s', an uncommon type.  See The "
							   @"Mac Hacker’s Handbook, C. Miller & D. Dai Zovi, p. 143.",
							   argType] ;
				}
			}
			else {
				argDesc = @"NOT_SET" ;
			}
			
			[msg appendString:argDesc] ;
		}
		iArg++ ;
	}
	[scanner release] ;
	
	return [NSString stringWithFormat:
			@"<%@ %p with targ=%@\nselector is shown with 1 argument on each of the following lines:%@",
			[self className],
			self,
			[[self target] shortDescription],
			msg] ;
}


@end