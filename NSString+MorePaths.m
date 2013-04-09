#import "NSString+MorePaths.h"
#import "NSError+SSYAdds.h"
#import "NSCharacterSet+SSYMoreCS.h"
#import "NSString+SSYExtraUtils.h"
#import "NSString+Truncate.h"

@implementation NSString (MorePaths)

- (NSString*)pathBySuffixingFilenameWithString:(NSString*)suffix {
	NSString* parent = [self stringByDeletingLastPathComponent] ;
	NSString* extendedFilename = [self lastPathComponent] ;
	NSString* extension = [extendedFilename pathExtension] ;
	NSString* baseFilename = [extendedFilename stringByDeletingPathExtension] ;
	baseFilename = [baseFilename stringByAppendingString:suffix] ;
	extendedFilename = [baseFilename stringByAppendingPathExtension:extension] ;
	NSString* answer = [parent stringByAppendingPathComponent:extendedFilename] ;
	
	return answer ;
}

- (BOOL)pathIsReadableError_p:(NSError**)error_p {
	NSFileManager* fm = [NSFileManager defaultManager] ;
	BOOL isReadable = [fm isReadableFileAtPath:[self stringByDeletingLastPathComponent]] ;
	if (!isReadable) {
		NSString* msg = [NSString stringWithFormat:@"NSFileManager says this path is not readable:\n\n%@", self] ;
		NSError* error = SSYMakeError(23400, msg) ;
		if (error_p) {
			*error_p = error ;
		}
	}
	
	return isReadable ;
}

- (BOOL)pathIsWritableError_p:(NSError**)error_p {
	NSFileManager* fm = [NSFileManager defaultManager] ;
	BOOL isWritable = [fm isWritableFileAtPath:[self stringByDeletingLastPathComponent]] ;
	if (!isWritable) {
		NSString* msg = [NSString stringWithFormat:@"NSFileManager says this path is not writable:\n\n%@", self] ;
		NSError* error = SSYMakeError(23415, msg) ;
		if (error_p) {
			*error_p = error ;
		}
	}
	
	return isWritable ;
}

- (BOOL)isDirectory {
	BOOL isDirectory ;
	NSFileManager* fileManager = [NSFileManager defaultManager] ;
	BOOL exists = [fileManager fileExistsAtPath:self
									isDirectory:&isDirectory] ;
	// Noting that isDirectory is undefined if not exists,
	return (exists && isDirectory) ;
}

- (NSArray*)directoryContents {
	NSArray* directoryContents ;
	if ([self isDirectory]) {
		NSFileManager* fileManager = [NSFileManager defaultManager] ;
		directoryContents = [fileManager contentsOfDirectoryAtPath:self
															 error:NULL] ;
}
	else {
		directoryContents = nil ;
	}
	
	return directoryContents ;
}

- (NSArray*)directoryContentsAsFullPaths {
	NSArray* directoryContentsAsFullPaths ;
	if ([self isDirectory]) {
		NSFileManager* fileManager = [NSFileManager defaultManager] ;
		NSArray* filenames = [fileManager contentsOfDirectoryAtPath:self
															  error:NULL] ;
NSMutableArray* a = [[NSMutableArray alloc] init] ;
		NSEnumerator* e = [filenames objectEnumerator] ;
		NSString* filename ;
		while ((filename = [e nextObject])) {
			[a addObject:[self stringByAppendingPathComponent:filename]] ;
		}
		directoryContentsAsFullPaths = [[a copy] autorelease] ;
		[a release] ;
	}
	else {
		directoryContentsAsFullPaths = nil ;
	}
	
	return directoryContentsAsFullPaths ;
}

- (NSString*)parentHomePath {
	// There are three possible cases
	// Case 1.  We're on the startup disk.  Example:
	//     /Users/jk/path/to/self
	// Case 2.  We're on a mounted network disk.  Example:
	//     /Volumes/AlPbHD/Users/bh/path/to/self
	// Case 3.  We're on a mounted network home directory.  Example:
	//     /Volumes/bh/path/to/self
	
	NSString* homePath = nil ;
	NSArray* comps = [self pathComponents] ;
	NSUInteger nComps = [comps count] ;
	NSUInteger homeIndex = NSNotFound - 1 ;
	
	// The shortest valid number of comps is 3.  Examples:
	//   Case 1: {"/", "Users", "jk"}
	//   Case 3: {"/", "Volumes", "bh"}
	if (nComps < 3) {
		goto end ;
	}
	
	// For a valid path, the first component is always "/"
	if (![[comps objectAtIndex:0] isEqualToString:@"/"]) {
		goto end ;
	}
	
	NSUInteger usersIndex = [comps indexOfObject:@"Users"] ;
	// But if someone has named an external drive "Users", we'll be at "/Volumes/Users/Users/..."
	if (usersIndex == 1) {
		if ([[comps objectAtIndex:2] isEqualToString:@"Users"]) {
			usersIndex = 2 ;
		}
	}
	
	if ((usersIndex <= 3) && (usersIndex < NSNotFound)) {
		// Case 1 or Case 2
		homeIndex = usersIndex + 1 ;
	}
	else if ([[comps objectAtIndex:1] isEqualToString:@"Volumes"]) {
		// Case 3
		homeIndex = 2 ;
	}
			
	NSUInteger nHomeComps = homeIndex + 1 ;
	if (nComps >= nHomeComps) {
		NSRange range = NSMakeRange(0, nHomeComps) ;
		NSArray* homeComps = [comps subarrayWithRange:range] ;
		homePath = [NSString pathWithComponents:homeComps] ;
	}

end:	
	return homePath ; 
}

+ (NSString*)libraryPathForHomePath:(NSString*)homePath {
	NSString* path ;
	
	if (homePath) {
		path = [homePath stringByAppendingPathComponent:@"Library"] ;
	}
	else {
		// Current user's Library
		NSArray *paths = NSSearchPathForDirectoriesInDomains(
															 NSLibraryDirectory,  
															 NSUserDomainMask,
															 YES
															 ) ;
		path = ([paths count] > 0) ? [paths objectAtIndex:0] : nil ;
	}
	
	return path ;
}

+ (NSString*)applicationSupportPathForHomePath:(NSString*)homePath {
	NSString* path ;

	if (homePath) {
		path = [[homePath stringByAppendingPathComponent:@"Library"]
				stringByAppendingPathComponent:@"Application Support"] ;
	}
	else {
		// Current user's Application Support
		NSArray *paths = NSSearchPathForDirectoriesInDomains(
															 NSApplicationSupportDirectory,  
															 NSUserDomainMask,
															 YES
															 ) ;
		path = ([paths count] > 0) ? [paths objectAtIndex:0] : nil ;
	}
	
	return path ;
}

+ (NSString*)applicationSupportFolderForThisApp {
	return [[self applicationSupportPathForHomePath:nil] stringByAppendingPathComponent:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleExecutable"]] ;
}

+ (NSString*)preferencesPathForHomePath:(NSString*)homePath {
	NSString* path = [[homePath stringByAppendingPathComponent:@"Library"]
					  stringByAppendingPathComponent:@"Preferences"] ;
	
	return path ;
}

- (NSString*)displayPathName {
	NSFileManager* fm = [NSFileManager defaultManager] ;
	NSString* displayName ;
	
	if ([fm fileExistsAtPath:self]) {
		displayName = [fm displayNameAtPath:self] ;
	}
	else {
		displayName = @"notAvailable" ;
	}
	
	return displayName ;
}

- (NSArray*)pathAncestorsUpTo:(NSString*)tooHighAncestor {
	NSArray* components = [self pathComponents] ;
	NSUInteger nAncestors = [components count] ;
	// In most cases we should have subtracted one or two, because
	// the first "component" returned by -pathComponents will be the slash, @"/"
	// (if self begins with a slash), and appending the last component will make self,
	// and both of these will be disqualified by one of the if conditions below.
	NSMutableArray* ancestors = [[NSMutableArray alloc] initWithCapacity:nAncestors] ;
	NSEnumerator* e = [components objectEnumerator] ;
	NSString* component ;
	NSMutableString* path = [[NSMutableString alloc] init] ;
	BOOL stillTooHigh = YES ;
	while ((component = [e nextObject])) {
		if (![component isEqualToString:@"/"]) {
			[path appendString:@"/"] ;
			[path appendString:component] ;
			if (![path isEqualToString:self] && !stillTooHigh) {
				NSString* ancestor = [path copy] ;
				[ancestors addObject:ancestor] ;
				[ancestor release] ;
			}
			if ([path isEqualToString:tooHighAncestor]) {
				stillTooHigh = NO ;
			}
		}
	}
	[path release] ;
    
	NSArray* output = [ancestors copy] ;
	[ancestors release] ;
	
	return [output autorelease] ;
}

- (BOOL)pathIsOrIsAncestorOf:(NSString*)target {
	// Example:            If target is: @"/Users/jk/Docs/MyDocs"
	//     will return YES if self is: @"/Users/jk"
	//     will return YES if self is: @"/Users/jk/Docs/MyDocs" 
	NSRange r = [target rangeOfString:self] ;
	if (r.location == 0) {
		// OK if self "is" target:
		if (r.length == [target length]) {
			return YES ;
		}
		// OK if self "is ancestor of" target:
		if ([target length] > r.length) {
			//   Example: self = /Users/jerry 
			//          target = /Users/jerry/Docs
			//               r = ************
			//    rExpectSlash =             * 
			NSRange rExpectSlash = NSMakeRange(r.length, 1) ;
			if ([[target substringWithRange:rExpectSlash] isEqualToString:@"/"]) {
				return YES ;
			}
		}
		// else, we're in the wrong directory.  For example, we may
		// have found "/Users/j" when we were looking for ancestors
		// of target  "/Users/jerry/Docs"
		// and got r=  ********
	}
	
	return NO ;
}

- (BOOL)pathIsDescendantOf:(NSString*)target {
	if (!target) {
		return NO ; 
	}

	// Example:            If target is: @"/Users/jk"
	//       will return YES if self is: @"/Users/jk/Docs"
	//       will return YES if self is: @"/Users/jk/Docs/MyDocs" 
	NSUInteger targetLength = [target length] ;
	if ([self hasPrefix:target]) {
		if ([self length] > targetLength) {
			//   Example: s = /Users/jk/Docs 
			//       target = /Users/jk
			// rExpectSlash =          * 
			NSRange rExpectSlash = NSMakeRange(targetLength, 1) ;
			if ([[self substringWithRange:rExpectSlash] isEqualToString:@"/"]) {
				return YES ;
			}
		}
		// else, we're in the wrong directory.  For example, we may
		// have found "/Users/jkrinock/Documents when we were looking for descendants
		// of target  "/Users/jk"
	}
	return NO ;
}

- (NSNumber*)returningGlobalObjectYESNOPathIsDescendantOf:(NSString*)target {
	// invokes pathIsDescendantOf but returns an NSNumber Bool instead of a BOOL
	BOOL yn = [self pathIsDescendantOf:target] ? YES : NO ;
	return [NSNumber numberWithBool:yn] ;
}

- (NSString*)pathRelativeToFirstComponent {
	//	Returns empty string if path separator "/" is not found
	NSUInteger loc = [self rangeOfString:@"/"].location + 1 ;
	loc = MIN(loc, [self length]) ;
	return [self substringFromIndex:loc] ;
}

- (NSArray*)directoryContentsAsFullPaths:(BOOL)fullNotRelative
							excludePaths:(NSArray*)excludedPaths
							excludeNames:(NSArray*)excludedNames {
	//  Useful if self is a file system path
	//  return nil if self does not exist as path or is not a directory.
	//	returns empty array if self is a good directory but has no children
	//  if fullNotRelative is NO, returns paths relative to self
	NSFileManager *fileManager = [NSFileManager defaultManager] ;
	BOOL isDir ;
	BOOL exists = [fileManager fileExistsAtPath:self isDirectory:&isDir] ;
	
	NSArray* paths = nil ;
	if (exists && isDir) {
		NSArray *childLastNames = [fileManager contentsOfDirectoryAtPath:self
																   error:NULL] ;
		NSMutableArray* bucket = [[NSMutableArray alloc] initWithCapacity:[childLastNames count]] ;
		NSEnumerator* e = [childLastNames objectEnumerator] ;
		NSString* childLastName ;
		NSString* childFullPath ;
		while ((childLastName = [e nextObject])) {
			BOOL ok = YES ;
			
			if (excludedPaths || fullNotRelative) {
				// For efficiency, only get childFullPath if we might need it
				childFullPath = [self stringByAppendingPathComponent:childLastName] ;
			}
			
			if (excludedNames) {
				if ([excludedNames indexOfObject:childLastName] != NSNotFound) {
					ok = NO ;
				}
			}
			
			if (ok) {
				if (excludedPaths) {
					if ([excludedPaths indexOfObject:childFullPath] != NSNotFound) {
						ok = NO ;
					}
				}
				
				if (ok) {
					NSString* path = fullNotRelative ? childFullPath : childLastName ;
					[bucket addObject:path] ;
				}
			}
		}
		paths = [[bucket copy] autorelease] ;
		[bucket release] ;
	}
	
	return paths ;
}	


// Convert a slash-delimited POSIX path to a colon-delimited HFS path.
- (NSString*)hfsPath {
    // Ripped from Bill Monk, http://www.cocoabuilder.com/archive/message/cocoa/2005/7/13/141777
	// Bill thanks stone.com for the pointer to CFURLCreateWithFileSystemPath()
	
    CFURLRef url;
    CFStringRef hfsPath = NULL;
	
    BOOL isDirectoryPath = [self hasSuffix:@"/"];
    // Note that for the usual case of absolute paths, isDirectoryPath is
	// completely ignored by CFURLCreateWithFileSystemPath.
	// isDirectoryPath is only considered for relative paths.
	// This code has not really been tested relative paths...
	
	url = CFURLCreateWithFileSystemPath(
										kCFAllocatorDefault,
										(CFStringRef)self,
										kCFURLPOSIXPathStyle,
										isDirectoryPath);
    
	if (url) {
        // Convert URL to a colon-delimited HFS path
        // represented as Unicode characters in an NSString.
        hfsPath = CFURLCopyFileSystemPath(url, kCFURLHFSPathStyle) ;
		
        CFRelease(url);
    }
	
    return [(NSString*)hfsPath autorelease] ;
}



- (NSString*)uniqueFilenameInDirectory:(NSString*)directory
#if MAC_OS_X_VERSION_MAX_ALLOWED >= 1050		
							 maxLength:(NSUInteger)maxLength 
#else
							 maxLength:(NSInteger)maxLength 
#endif
							truncateOk:(BOOL)truncateOk {
	
	// Get list of already-existing filenames
	NSArray* existingFilenames ;
	if (directory) {
		existingFilenames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directory
																				error:NULL] ;
}
	else {
		existingFilenames = [NSArray array] ;
	}
	
	if (!existingFilenames) {
		// This will happen if directory does not exist, but will cause
		// an infinite loop below.  So, we give a more sensible value...
		existingFilenames = [NSArray array] ;
	}
	
	// Dissect the initial name=self
	NSMutableString* nameMutable = [self mutableCopy] ;

	NSString* extension = [nameMutable pathExtension] ;
	
	// Replace characters not allowed in a Mac or Unix filename with "-"
	NSCharacterSet* disallowedSet = [[NSCharacterSet filenameLegalMacUnixCharacterSet] invertedSet] ;
	NSUInteger loc = 0 ;
	while (loc < [nameMutable length]) {
		loc = [nameMutable rangeOfCharacterFromSet:disallowedSet].location ;
		if (loc < NSNotFound) {
			[nameMutable replaceCharactersInRange:NSMakeRange(loc, 1)
								withString:@"-"] ;
		}
	}
	NSString* name = [[nameMutable copy] autorelease] ;
	// Autorelease because we may or may not reassign this to an autoreleased
	// variable, in a couple places.  It would get tricky to retain+release.
	NSMutableString* baseName = [[[name stringByDeletingPathExtension] mutableCopy] autorelease] ;
	[nameMutable release] ;
	
	BOOL lengthOK = NO ;
	BOOL unique = NO ;
	NSMutableArray* baseNamesAlreadyTried = [[NSMutableArray alloc] init] ;
	NSUInteger maxBaseNameLength = maxLength - 1 - [extension length] ;  // 1 for the dot "."
	NSUInteger endLength = ((maxBaseNameLength - 1)*2)/3 ;
	NSUInteger beginLength = maxBaseNameLength - endLength - 2 ;  // reserve 2 for the dashes
	while (YES) {		
		// Modify if needed for length requirement
		NSUInteger length = [name length] ;
		if (length > maxLength) {
			if (truncateOk) {
				NSUInteger endLocation = [baseName length] - endLength ;
				NSRange endRange = NSMakeRange(endLocation, endLength) ;
				baseName = [NSMutableString stringWithFormat:@"%@--%@",  // 2 dashes are subtracted above
							[baseName substringToIndex:beginLength],
							[baseName substringWithRange:endRange]] ;
				name = [baseName stringByAppendingPathExtension:extension] ;
				unique = NO ;
			}
			else {
				baseName = [NSMutableString stringWithString:[baseName stringByTruncatingMiddleToLength:(maxBaseNameLength-3)
																							 wholeWords:NO]] ;
				// ... allowed 3 numbers to be appended
				name = [baseName stringByAppendingPathExtension:extension] ;
			}
		}
		// Length either was OK, or has been fixed.
		lengthOK = YES ;
		
		// Modify if needed for uniqueness
		if ([existingFilenames indexOfObject:name] != NSNotFound) {
			// Take it apart
			NSString* decimalDigitSuffix = [baseName decimalDigitSuffix] ;
#if MAC_OS_X_VERSION_MAX_ALLOWED >= 1050		
			NSUInteger currentIndex = [decimalDigitSuffix integerValue] ;
			NSUInteger suffixLength = [decimalDigitSuffix length] ;
#else
			NSInteger currentIndex = [decimalDigitSuffix integerValue] ;
			NSInteger suffixLength = [decimalDigitSuffix length] ;
#endif
			NSRange suffixRange = NSMakeRange([baseName length] - suffixLength, suffixLength) ;
			[baseName deleteCharactersInRange:suffixRange] ;
			unichar lastChar ;
			if ([baseName length] > 0) {
				lastChar = [baseName characterAtIndex:([baseName length] -1)] ;
			}
			else {
				lastChar = (unichar)0 ;
			}
			BOOL needsConjunction = ((lastChar != '_') && (lastChar != '-'));
			
			// Build it back up
			if (needsConjunction) {
				[baseName appendString:@"_"] ;
			}
			[baseName appendFormat:@"%ld", (long)(currentIndex + 1)] ;
			name = [baseName stringByAppendingPathExtension:extension] ;
			lengthOK = NO ;
			
			// Note that, at this point, it still might not be unique.
		}
		else {
			unique = YES ;
		}
		
		if (unique && lengthOK) {
			// Success!  Done!
			break ;
		}
		
		if ([baseNamesAlreadyTried indexOfObject:baseName] == NSNotFound) {
			[baseNamesAlreadyTried addObject:[NSString stringWithString:baseName]] ;
		}
		else {
			// We're restarted a cycle (infinite loop)
			// Set answer to nil and bail out
			name = nil ;
			break ;
		}
	}
	
	[baseNamesAlreadyTried release] ;
	NSString* answer = [name copy] ;
	return [answer autorelease] ;
}

- (NSString*)volumePath {
	NSArray* components = [self pathComponents] ;
	if ([components count] < 3) {
		return nil ;
	}
	if (![[components objectAtIndex:0] isEqualToString:@"/"]) {
		return nil ;
	}
	if (![[components objectAtIndex:1] isEqualToString:@"Volumes"]) {
		return nil ;
	}
	
	NSRange first3 = NSMakeRange(0,3) ;
	NSArray* volumeComponents = [components subarrayWithRange:first3] ;
	NSString* volumePath = [NSString pathWithComponents:volumeComponents] ;
	return volumePath ;
}

- (NSString*)pathSuffixedWithString:(NSString*)suffix {
	NSString* newPath = self ;
	do {
		newPath = [[[newPath stringByDeletingPathExtension] stringByAppendingString:suffix] stringByAppendingPathExtension:[self pathExtension]] ;
	} while ([[NSFileManager defaultManager] fileExistsAtPath:newPath]) ;
	
	return newPath ;	
}

- (NSString*)tildefiedPath {
	return [self pathSuffixedWithString:@"~"] ;
}

- (NSString*)hashifiedPath {
	return [self pathSuffixedWithString:@"#"] ;
}


@end