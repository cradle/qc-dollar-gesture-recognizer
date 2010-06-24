//
//  MCGestureView.m
//  MCGestureRecognizer
//	Original Concept:	The $1 Unistroke Recognizer by Jacob O. Wobbrock,Andrew D. Wilson,Yang Li
//						http://depts.washington.edu/aimgroup/proj/dollar/
//
//  Created by 'malcom' on 14/08/09.
//  Copyright 2009 Daniele Margutti 'malcom'. All rights reserved.
//	Email:	malcom.mac@gmail.com
//	Web:	http://www.malcom-mac.com
//
//	You can use this code in your commercial or opensource project without limitations,
//	but add this statement in your about or credits box:
//	"MCGestureRecognizer by Daniele Margutti - http://www.malcom-mac.com"
//
//	Original Concept: 
//	http://depts.washington.edu/aimgroup/proj/dollar/
//	http://blog.makezine.com/archive/2008/11/gesture_recognition_for_javasc.html

#import "MCGestureView.h"

#import "NSValue+CGPointConversions.h"

@implementation MCGestureView

@synthesize p_delegate;
@synthesize p_analyzer;

- (id) init {
    // Initialization code
	if( self = [super init] ) {
		[self _initSettings];
	}
    return self;
}

- (void) dealloc {
	[p_analyzer release];
	[p_delegate release];
	[super dealloc];
}

+ (CGPoint)locationInViewOfPoint: (CGPoint) point {
	// flipping to match built in guestures coords
	// should probably just store new ones with QC coords
	return CGPointMake(point.x-1,-point.y+1);
}

- (void)touchBegan: (CGPoint) touch {
	[p_analyzer clearTouches];
	[p_analyzer addTouchAtPoint: touch];
}

- (void)touchMoved: (CGPoint) touch {
	[p_analyzer addTouchAtPoint: touch];
}

- (void)touchEnded: (CGPoint) touch {
	[p_analyzer addTouchAtPoint: touch];
	[p_analyzer bestMatchedGesture];
}

- (void) _initSettings {
	p_analyzer = [[MCGestureAnalyzer alloc] initWithSourceView: self];
}

@end
