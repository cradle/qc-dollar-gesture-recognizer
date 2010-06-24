//
//  JestieurPlugIn.h
//  Jestieur
//
//  Created by Glenn Murray on 22/06/10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//
// TODO: possible enhancements
//	 * allow external control for when to 'start', 'sample', and 'end'
//   * offer options for show gestures (see _showTouchDrawing:(CGContextRef) ctx forList:(NSArray *) _list
//		- the points in the current guesture as a structure
//      - the points for the last completed gesture as inputed
//		- the points for the recognised guesture
//   * gesture management
//		- load (replaced/add) from file
//		- save to file
//		- record gestures (and new/update existing)
//	 * hook properly into UIEvents like the iphone one does
//		- would allow multi touch events, ala rotations I think
//   * somehow display the current guestures, maybe on an output as points?
//	 * work as an 'interaction' patch somehow
//		- would allow saying 'gesture only responds in this area', or 'to this area'
//	 * grap offscreen mouse coords (like CoGeMouse, or just refer to that)
#import "MCGestureView.h"

@interface JestieurPlugIn : QCPlugIn <MCGestureDelegate> {
	MCGestureView *p_gestureView;
	BOOL wasTouching;
	NSString* error;
}

@property double inputX, inputY;
@property BOOL inputTouch;
@property(assign) NSString* error;
@property(assign) BOOL wasTouching;
@property(assign) NSString* outputStatus;
@property(assign) NSString* outputErrors;

@end
