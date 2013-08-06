#import "NSSplitView+Fraction.h"

@implementation NSSplitView (Fraction)

// Ripped from an old version of OmniGroup / Frameworks / OmniAppKit / OpenStepExtensions.subproj / NSSplitView-OAExtensions.m
// https://github.com/omnigroup/OmniGroup/blob/c5ebd4b3c36457d11ffa8ba11123fab4361c6f24/Frameworks/OmniAppKit/OpenStepExtensions.subproj/NSSplitView-OAExtensions.m

// Copyright 1997-2005, 2007-2008 Omni Development, Inc.  All rights reserved.
//
// This software may only be used and reproduced according to the
// terms in the file OmniSourceLicense.html, which should be
// distributed with this project and can also be found at
// <http://www.omnigroup.com/developer/sourcecode/sourcelicense/>.


- (CGFloat)fraction {
    NSRect topFrame, bottomFrame;
    
    if ([[self subviews] count] < 2)
        return 0.0f;
    
    if ([self isSubviewCollapsed:[[self subviews] objectAtIndex:0]])
        topFrame = NSZeroRect;
    else
        topFrame = [[[self subviews] objectAtIndex:0] frame];
    
    if ([self isSubviewCollapsed:[[self subviews] objectAtIndex:1]])
        bottomFrame = NSZeroRect;
    else
        bottomFrame = [[[self subviews] objectAtIndex:1] frame];
    
    if (topFrame.origin.y != bottomFrame.origin.y)
        return bottomFrame.size.height / (bottomFrame.size.height + topFrame.size.height);
    else
        return bottomFrame.size.width / (bottomFrame.size.width + topFrame.size.width);
}

- (void)setFraction:(CGFloat)newFract {
    NSRect                      topFrame, bottomFrame;
    NSView                      *topSubView;
    NSView                      *bottomSubView;
    CGFloat                     total;
    
    if ([[self subviews] count] < 2)
        return;
    
    topSubView = [[self subviews] objectAtIndex:0];
    bottomSubView = [[self subviews] objectAtIndex:1];
    topFrame = [topSubView frame];
    bottomFrame = [bottomSubView frame];
    
    if (topFrame.origin.y != bottomFrame.origin.y) {
        total = bottomFrame.size.height + topFrame.size.height;
        bottomFrame.size.height = newFract * total;
        topFrame.size.height = total - bottomFrame.size.height;
    } else {
        total = bottomFrame.size.width + topFrame.size.width;
        bottomFrame.size.width = newFract * total;
        topFrame.size.width = total - bottomFrame.size.width;
    }
    [topSubView setFrame:topFrame];
    [bottomSubView setFrame:bottomFrame];
    [self adjustSubviews];
    [self setNeedsDisplay: YES];
}

@end
