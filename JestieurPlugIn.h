//
//  JestieurPlugIn.h
//  Jestieur
//
//  Created by Glenn Francis Murray on 22/06/10.
//  Copyright (c) 2010 Glenn Francis Murray. All rights reserved.
//
//  Disclaimer: Alpha Quality, almost guaranteed to crash itself and your Mac
//
//  ///////
//  License
//  ///////
//
//  Attribution must be preserved.
//	Licence must be preserved upon transfer.
//
//  You have permission to:
//   - use Jestieur:
//     + for personal use
//	   + for personal profit (eg. VJ)
//   - distribute Jestieur:
//     + not for profit:
//		 > unmodified, without its source
//		 > modified, with its source
//     + for profit, as part of a larger work:
//		 > modified or unmodified, with its source mad public
//   - modify Jestieur:
//	   + for personal use
//	   + for personal profit, with modified source made public
//
//  All other rights reserved.

//// License regarding $1 research paper (http://faculty.washington.edu/wobbrock/pubs/uist-07.1.pdf
/*
 Permission to make digital or hard copies of all or part of this work for personal or 
 classroom use is granted without fee provided that copies are not made or distributed 
 for profit or commercial advantage and that copies bear this notice and the full citation 
 on the first page. To copy otherwise, or republish, to post on servers or to redistribute 
 to lists, requires prior specific permission and/or a fee.
 
 UISTÕ07, October 7-10, 2007, Newport, Rhode Island, USA. 
 Copyright 2007 ACM 978-1-59593-679-2/07/0010...$5.00.
*/
//// Citation, I think it's only needed for textual references. But I didn't port that algorithm for this implementation
/*
 	Wobbrock, J.O., Wilson, A.D. and Li, Y. (2007). Gestures without libraries, toolkits or training: A $1 recognizer for user interface prototypes.
	Proceedings of the ACM Symposium on User Interface Software and Technology (UIST '07).
	Newport, Rhode Island (October 7-10, 2007). New York: ACM Press, pp. 159-168.
*/
////


//
// TODO: urgent
//	 * I think I am loading from disk too soon. I should do it when the plugin is loaded into a composition, not when quartz composer scans the library (which I presume is happening, because I get a long lag now)
//
// TODO: high priority
//	 * fix order of output parameters
//   * use 'angle to best match' + 'initial rotaiton' rather than just initial
//   * make width and hight settable
//     - allows returning gestures at the size they were inputted
//     - all internal calculations are scale invariant
//	   - could alternatively be stored with size before resizeing, then restored for display
//     - could extend dollar gesture to include 'size' as a factor, but how to weight?
//		  + FEATURE POSSIBLE could have non size invariant gestures stored then scale each input to match, noting rescale factor (slow?)
//			+++ store 'scale' with gestures when stored, would allow size variant comparison
//
//	TODO: refactor
//		+ separate functionality into separate patches
//			+ PointsList -> "Recognize Gesture" -> Name, Score, Ratio
//			+ PointsList, Name -> "Racognize Gesture as Name" -> Score, Ratio
//			+ PointsList, Name -> "Make Gesture" -> {"name":<Name>, {"points":<PointList>}}
//				- KinemeStructMaker
//		+ structure formats
//			+ Point = {'x':0} or {'y':0} 
//			+ Gesture = {"name": "Circle", "points": [<point1>,<point2>, ... ]}
//			+ GestureStore = [<gesture1>,<gesture2>, ...]
//
// TODO: possible enhancements
//	 * make pure QC version (will make heavy use of 'math', conditional, and iteration)
//	 *** when adding new templates to existing names, could use this from study
//		An interactive extension would be to allow users to correct a failed recognition result using the N-best list, and then have their articulated gesture morph some percentage of the way toward the selected template until it would have been successfully recognized. This kind of interactive correction and animation might aid gesture learning and retention.
//	 * allow bezier and straight line based gesture adding, like curve interface on interpolation plugin
//   * have interpolation-like settings pane allowing editing, adding, removing etc..
//   * try and make sure 'corner' points are kept
//	 * add 'simple' line detection
//		- add 'bounding-box' size measurements after the initial rotation ("axis-aligned")
//			then work out the height of this box, compare that to a threshold
// (from paper [after I worked out bounding box :P])
// // NOTE TO SELF: instead of doing this, *could* do non linear scaling on major axis, exaggerating intentional?
// modifying the algorithm. Furthermore, horizontal and vertical lines are abused by non-uniform scaling;
// if 1-D gestures are to be recognized, candidates can be tested to see if the minor dimension of their 
//bounding box exceeds a minimum. If it does not, the candidate (e.g., line) can be scaled uniformly so that
//its major dimension matches the reference square. Finally, $1 does not use time,
//so gestures cannot be differentiated on the basis of speed. Prototypers wishing to differentiate gestures
//on these bases will need to understand and modify the $1 algorithm. For example, if scale invariance is 
//not desired, the candidate C can be resized to match each unscaled template Ti before comparison. Or if 
//rotation invariance is unwanted, C and Ti can be compared without rotating the indicative angle to 0¡. 
//Importantly, such treatments can be made on a per gesture (Ti) basis.
//	 * add 6 pointed start, see if it can handle it, $N can!
//	 * store gestures with 't', time it occured presuming p[0] is t=0.
//		- could normalise all times to '1' and use as another 'dimension' for measuring closeness
//		- could use normalised 't' for where in line to sample, rather then equidistant in space (equichronic! boojah)
//		- allow do both, compare somehow, blog all comparisons
//	 * interpolate points non-linearly, or allow choice
//		- external? at least 'bezier' would be good.
//		- can I access QC interpolation? 
//   * could have option for 'directionality' invariance
//		- flipping the input in the x&|y planes, either pre-processed as separate tempaltes or multiple comaprison passes
//   * make setable the more detailed settings
//      - AngleRange(45.0) // how much a gesture can be rotated in either direction and still match
//		- AnglePrecision(2.0) // How accurate rotations are? (not used in file, deleted, although "_threshold" exists
//			+ uses "Golden" search between -45&45 degrees (using PHI), stopping when the difference is less than 'precision' degrees
//		- squareSize(250.0) // the 'scale' of the stored coords, [0..250][0..250]
//		- numPoints(16) // number of points in a gesture
//	 * "indicative angle" only exists for rotation invariance, and even then, only for speed boost
//	 * make use binary search instead, math out average steps and benchmark, why does he use golden?
//	 * allow external control for when to 'start', 'sample', and 'end'
//   * allow passing of a gesture *as point list* for recognition
//   * offer options for show gestures
//      - last gesture modified - DONE	
//		- the points for the last completed gesture as inputed
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
@property(assign) NSString* outputName;
@property(assign) double outputScore;
@property(assign) double outputRatio;
@property(assign) double outputRotation;
@property(assign) double outputSizeX;
@property(assign) double outputSizeY;
@property(assign) NSString* outputErrors;
@property(assign) BOOL outputMatch;
@property(assign) NSArray* outputLastUnistroke;
@property(assign) NSArray* outputTemplateGestures;
@end
