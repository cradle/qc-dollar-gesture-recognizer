//
//  MCGestureAnalyzer.h
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


#import "NSValue+CGPointConversions.h"

@class MCGestureView;
@class MCPointsContainer;
@interface MCGestureAnalyzer : NSObject {
	BOOL				strictlyMatch;
	float				scoreThreshold;
	
	// you can't change these without invalidating the stored gestures
	float				numPoints;
	float				squareSize;
	float				halfDiagonal;
	
	MCGestureView		*p_associatedView;
	NSMutableArray		*p_gesturesList;
	MCPointsContainer	*p_touchesContainer;
	MCPointsContainer	*p_endElaboration;
}

@property (assign) BOOL strictlyMatch;

#pragma mark INIT METHODS
- (id) initWithSourceView:(MCGestureView *) _view;

#pragma mark WORKING WITH TOUCHES
- (void) clearTouches;
- (void) addTouchAtPoint:(CGPoint)point;
- (NSArray *) touches;
- (NSArray *) postElaborationTouches;

#pragma mark CORE
- (void) bestMatchedGesture;
- (NSArray*) gestureTemplates;
- (void) addGesture:(NSDictionary *) _gesture;
- (BOOL) addGestureFromFile:(NSString *) _datapath;

@end
