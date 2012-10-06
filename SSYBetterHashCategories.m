#import "SSYBetterHashCategories.h"


#if 0
#warning Using untested 64-bit version of mix()
/*
 If I ever wanted to make a 64-bit version of mix(),
 I would do something like this.
 I made up the shift values for this 64-bit version of mix()
 by doubling the values in the 32-bit version.  I have no idea
 how well this will work.
 */
int64_t mix(unsigned long long a, unsigned long long b, unsigned long long c)
{
	a=a-b;  a=a-c;  a=a^(c >> 25);
	b=b-c;  b=b-a;  b=b^(a << 16); 
	c=c-a;  c=c-b;  c=c^(b >> 25);
	a=a-b;  a=a-c;  a=a^(c >> 24);
	b=b-c;  b=b-a;  b=b^(a << 32);
	c=c-a;  c=c-b;  c=c^(b >> 11);
	a=a-b;  a=a-c;  a=a^(c >> 5);
	b=b-c;  b=b-a;  b=b^(a << 20);
	c=c-a;  c=c-b;  c=c^(b >> 31);
	return c;
}
#endif

uint32_t mix(uint32_t a, uint32_t b, uint32_t c)
{
	a=a-b;  a=a-c;  a=a^(c >> 13);
	b=b-c;  b=b-a;  b=b^(a << 8); 
	c=c-a;  c=c-b;  c=c^(b >> 13);
	a=a-b;  a=a-c;  a=a^(c >> 12);
	b=b-c;  b=b-a;  b=b^(a << 16);
	c=c-a;  c=c-b;  c=c^(b >> 5);
	a=a-b;  a=a-c;  a=a^(c >> 3);
	b=b-c;  b=b-a;  b=b^(a << 10);
	c=c-a;  c=c-b;  c=c^(b >> 15);
	return c;
}

@implementation NSObject (HashBetter)

- (uint32_t)hashBetter32 {
#ifdef __LP64__
	uint32_t hash = [self hash] & 0x00000000ffffffff ;
#else
	uint32_t hash = [self hash] ;
#endif
	if ([self respondsToSelector:@selector(integerValue)]) {
		if ([(NSNumber*)self integerValue] < 0) {
#ifdef __LP64__
			hash += (NSNotFound & 0x00000000ffffffff) ;
#else
			hash += NSNotFound ;
#endif
		}
	}
	
	if (hash == 0) {
		hash = SSY_HASH_BETTER_SEED ;
	}

	return hash ;
}

@end

@implementation NSArray (HashBetter)

- (uint32_t)mixHash:(uint32_t)hash {
	// Jenkins' function is designed to mix in two values with the
	// initial value.  Threfore, the following loop takes groups our
	// values into pairs (hash1, hash2) and calls mix() on alternate
	// iterations.
	NSUInteger count = [self count] ;
	NSUInteger i=0 ;
	for (id object in self) {
		uint32_t hash1 = 0 ;
        uint32_t hash2 = 0 ;
		if (i%2==0) {
			// This is the 0th, 2nd, 4th etc. element
			hash1 = [object hashBetter32] ;
			if (i == count-1) {
				// It is also the last element.
				// This branch will only execute if self has
				// an odd number of elements.
				// Fake a final element by using ~hash1, and
				// do the final mix
				hash = mix(hash1, ~hash1, hash) ;
			}
		}
		else {
			// object is element indexed 1, 3, 5, etc.
			hash2 = [object hashBetter32] ;
			hash = mix(hash1, hash2, hash) ;
		}

		i++ ;
	}
	
	return hash ;	
}

- (uint32_t)hashBetter32 {
	return [self mixHash:0] ;
}

@end