#include <sys/types.h>


struct rc4_state {
	u_char	perm[256];
	u_char	index1;
	u_char	index2;
} ;

static __inline void swap_bytes(u_char *a, u_char *b) {
	u_char temp;
	
	temp = *a;
	*a = *b;
	*b = temp;
}

/*
 * Initialize an RC4 state buffer using the supplied key,
 * which can have arbitrary length.  keylen is in bytes.
 */
void rc4_init(
			  struct rc4_state* const state,
			  const u_char* key,
			  int keylen
			  ) {
	u_char j;
	int i;
	
	/* Initialize state with identity permutation */
	for (i = 0; i < 256; i++)
		state->perm[i] = (u_char)i; 
	state->index1 = 0;
	state->index2 = 0;
	
	/* Randomize the permutation using key data */
	for (j = i = 0; i < 256; i++) {
		j += state->perm[i] + key[i % keylen]; 
		swap_bytes(&state->perm[i], &state->perm[j]);
	}
}

/*
 * Encrypt some data using the supplied RC4 state buffer.
 * The input and output buffers may be the same buffer.
 * Since RC4 is a stream cypher, this function is used
 * for both encryption and decryption.
 */
void rc4_crypt(
			   struct rc4_state* const state,
			   const u_char* inbuf,
			   u_char* outbuf,
			   int buflen
			   ) {
	int i;
	u_char j;
	
	for (i = 0; i < buflen; i++) {
		
		/* Update modification indicies */
		state->index1++;
		state->index2 += state->perm[state->index1];
		
		/* Modify permutation */
		swap_bytes(&state->perm[state->index1],
				   &state->perm[state->index2]);
		
		/* Encrypt/decrypt next byte */
		j = state->perm[state->index1] + state->perm[state->index2];
		outbuf[i] = inbuf[i] ^ state->perm[j];
	}
}


@implementation NSData (Crypt)

+ (NSData*)dataKeyByteCount:(int)nKeyBytes
			 from7BitString:(NSString*)password {
	const char* passwordString = [password UTF8String] ;
	NSMutableData* keyData = [[NSMutableData alloc] init] ;
	int gotBits = 0 ;
	int carryBits ;
	u_char currentByte = 0 ;
	u_char nextByte ;
	u_char mask ;
	u_char newASCIIChar ;
	int gotKeyBytes = 0 ;
	int iASCII = 0 ;
	while ((newASCIIChar = passwordString[iASCII]) != 0) {
		currentByte = currentByte | (newASCIIChar << gotBits) ; // "<<" shifts on zeros
		carryBits = 8 - gotBits ;
		nextByte = (newASCIIChar >> carryBits) ; // ">>" shifts in ones but we don't care because they will be masked off later
		gotBits += 7 ;
		if (gotBits >= 8) {
			[keyData appendBytes:&currentByte
						  length:1] ;
			gotBits -= 8 ;
			currentByte = nextByte ;
			mask = ~(0xff << gotBits) ;
			currentByte &= mask ;
			gotKeyBytes++ ;
		}
		iASCII++ ;
	}
	
	if (gotKeyBytes < nKeyBytes) {
		NSLog(
			  @"Failed since %d-bit key requires password of %d bytes.  Password %@ has only %u.",
			  nKeyBytes*8,
			  (int)ceil((nKeyBytes*8)/7.0),
			  password,
			  (unsigned int)strlen(passwordString)) ;
		[keyData release] ;
		keyData = nil ;
	}
	
	return [keyData autorelease] ;
}	

- (NSData*)cryptRC4WithKeyData:(NSData*)keyData {	
	int nKeyBytes = [keyData length] ;
	u_char key[nKeyBytes] ;
	[keyData getBytes:key] ;	
	struct rc4_state state ;
	rc4_init(&state, key, nKeyBytes) ;
	int nPayloadBytes = [self length] ;
	unsigned char buf[nPayloadBytes] ;
	[self getBytes:buf] ;
	
	rc4_crypt(&state, buf, buf, nPayloadBytes) ;
	return [NSData dataWithBytes:buf length:nPayloadBytes] ;
}
	

@end


/*
 * rc4.c
 *
 * Copyright (c) 1996-2000 Whistle Communications, Inc.
 * All rights reserved.
 * 
 * Subject to the following obligations and disclaimer of warranty, use and
 * redistribution of this software, in source or object code forms, with or
 * without modifications are expressly permitted by Whistle Communications;
 * provided, however, that:
 * 1. Any and all reproductions of the source or object code must include the
 *    copyright notice above and the following disclaimer of warranties; and
 * 2. No rights are granted, in any manner or form, to use Whistle
 *    Communications, Inc. trademarks, including the mark "WHISTLE
 *    COMMUNICATIONS" on advertising, endorsements, or otherwise except as
 *    such appears in the above copyright notice or in the software.
 * 
 * THIS SOFTWARE IS BEING PROVIDED BY WHISTLE COMMUNICATIONS "AS IS", AND
 * TO THE MAXIMUM EXTENT PERMITTED BY LAW, WHISTLE COMMUNICATIONS MAKES NO
 * REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED, REGARDING THIS SOFTWARE,
 * INCLUDING WITHOUT LIMITATION, ANY AND ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT.
 * WHISTLE COMMUNICATIONS DOES NOT WARRANT, GUARANTEE, OR MAKE ANY
 * REPRESENTATIONS REGARDING THE USE OF, OR THE RESULTS OF THE USE OF THIS
 * SOFTWARE IN TERMS OF ITS CORRECTNESS, ACCURACY, RELIABILITY OR OTHERWISE.
 * IN NO EVENT SHALL WHISTLE COMMUNICATIONS BE LIABLE FOR ANY DAMAGES
 * RESULTING FROM OR ARISING OUT OF ANY USE OF THIS SOFTWARE, INCLUDING
 * WITHOUT LIMITATION, ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
 * PUNITIVE, OR CONSEQUENTIAL DAMAGES, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES, LOSS OF USE, DATA OR PROFITS, HOWEVER CAUSED AND UNDER ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 * THIS SOFTWARE, EVEN IF WHISTLE COMMUNICATIONS IS ADVISED OF THE POSSIBILITY
 * OF SUCH DAMAGE.
 *
 * $FreeBSD: src/sys/crypto/rc4/rc4.c,v 1.2.2.1 2000/04/18 04:48:31 archie Exp $
 */

