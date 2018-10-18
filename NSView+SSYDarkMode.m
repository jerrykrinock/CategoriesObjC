#import "NSView+SSYDarkMode.h"

@implementation NSView (SSYDarkMode)

- (BOOL)isDarkMode_SSY {
    BOOL answer;
    if (@available(macOS 10.14, *)) {
        /* https://stackoverflow.com/questions/51672124/how-can-it-be-detected-dark-mode-on-macos-10-14 */
        NSAppearanceName basicAppearance = [self.effectiveAppearance bestMatchFromAppearancesWithNames:@[
                                                                                                         NSAppearanceNameAqua,
                                                                                                         NSAppearanceNameDarkAqua
                                                                                                         ]];
        answer = [basicAppearance isEqualToString:NSAppearanceNameDarkAqua];
    } else {
        answer = NO;
    }

    return answer;
}

@end
