//
//  MCGestureAnalyzer.m
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

#import "MCGestureAnalyzer.h"
#import "MCGestureView.h"
#import "MCPointsContainer.h"

#import "NSValue+CGPointConversions.h"

@implementation MCGestureAnalyzer

@synthesize strictlyMatch;

- (id) initWithSourceView:(MCGestureView *) _view
{
	self = [super init];
	if (self != nil) {
		p_associatedView = [_view retain];
		p_gesturesList = [[NSMutableArray alloc] init];
		p_touchesContainer = [[MCPointsContainer alloc] init];
		
		strictlyMatch = NO;
		scoreThreshold = 0.7;

		numPoints = 64;
		squareSize = 2.0; // was 250.0
		halfDiagonal = 0.5 * sqrt(squareSize * squareSize + squareSize * squareSize);
	}
	return self;
}

- (void) dealloc {
	[p_touchesContainer release];
	[p_associatedView release];
	[p_gesturesList release];
	[super dealloc];
}

- (NSArray*) gestureTemplates {
	return p_gesturesList;
}

- (void) clearTouches {
	[p_touchesContainer clearPoints];
}

- (NSArray *) touches {
	return [p_touchesContainer pointsArray];
}

- (NSArray *) postElaborationTouches {
	return [p_endElaboration pointsArray];
}

- (void) addGesture:(NSDictionary *) _gesture {
	[p_gesturesList addObject: _gesture];
}

- (BOOL) addGestureFromFile:(NSString *) _datapath {
	if ([[NSFileManager defaultManager] fileExistsAtPath:_datapath] == NO) return NO;
	
	NSError *theError = nil;
	NSString *data = [NSString stringWithContentsOfFile: _datapath 
											   encoding: NSASCIIStringEncoding
												  error: &theError];
	NSArray *objects = [data componentsSeparatedByString:@"]\n"];
	for (NSString *cdata in objects) {
		if ([cdata length] > 0) {
			NSMutableArray *_pointsList = [[NSMutableArray alloc] init];
		
			NSRange _nameend = [cdata rangeOfString:@":"];
			NSString *_objname = [cdata substringToIndex:_nameend.location];
			NSArray *_points = [[cdata substringFromIndex: _nameend.location+2] componentsSeparatedByString:@";"];
			for (NSString *cPoint in _points) {
				int middle = [cPoint rangeOfString:@","].location;
				NSString *x = [cPoint substringWithRange:NSMakeRange(1,middle-1)];
				NSString *y = [cPoint substringWithRange:NSMakeRange(middle+1,[cPoint length]-middle-2)];

				CGPoint _p = CGPointMake([x doubleValue], [y doubleValue]);
				[_pointsList addObject: (NSValue*)[NSValue valueWithPoint: NSPointFromCGPoint(_p)]];
			}
			[p_gesturesList addObject: [NSDictionary dictionaryWithObjectsAndKeys:
									_objname,@"name",_pointsList,@"points",nil,nil]];
		}
	}
	return YES;	
}

- (void) addTouchAtPoint:(CGPoint )point {
	[p_touchesContainer addPoint: [MCGestureView locationInViewOfPoint: point]];
}

- (void) bestMatchedGesture {
	if ([p_associatedView.p_delegate respondsToSelector:@selector(MCGestureDelegateRecognizingGesture:)])
		[p_associatedView.p_delegate MCGestureDelegateRecognizingGesture: p_associatedView];
	
	//NSLog(@"points detected: %d",[p_touchesContainer points]);

	[p_endElaboration release];

	// Resample
	p_endElaboration = [[p_touchesContainer resampledPointsWithMax: numPoints] retain];
	//CGFloat sampleRatio = numPoints / [p_touchesContainer points];
	
	// Rotate
	CGFloat rotation = [p_endElaboration rotateToZero];
	
	// Rescale
	CGSize size = [p_endElaboration boundingBox].size;
	[p_endElaboration scaleToSquareSize: squareSize];
	
	// Translate
	[p_endElaboration traslateToOrigin];
	
	CGFloat b = +INFINITY;
	CGFloat sndBest = +INFINITY;

	int	t = -1;
	NSArray *_gestures = [self gestureTemplates];
	for (int i = 0; i < [_gestures count]; i++) {
		MCPointsContainer *gesturePoints = [[MCPointsContainer alloc] initWithPointsArrayForTemplate: [[_gestures objectAtIndex: i] objectForKey:@"points"] sampleTo:numPoints squareSize: squareSize];
		
		CGFloat d = [p_endElaboration distanceAtBestAngleWithTemplate: gesturePoints];
		
		if ([p_associatedView.p_delegate respondsToSelector:@selector(MCGestureDelegate:checkForGestureNamed:score:)])
			[p_associatedView.p_delegate MCGestureDelegate: p_associatedView checkForGestureNamed:[[_gestures objectAtIndex: i] objectForKey:@"name"] score:d];
		
		if (d < b) {
			sndBest = b;
			b = d;
			t = i;
		} else if (d < sndBest){
			sndBest = d;
		}
		[gesturePoints release];
	}
	CGFloat score = 1.0 - (b/halfDiagonal);
	CGFloat otherScore = 1.0 - (sndBest / halfDiagonal);
	CGFloat ratio = otherScore / score;

	if( (strictlyMatch == NO && t > -1) || (strictlyMatch && t >-1 && score > scoreThreshold)) {
		if ([p_associatedView.p_delegate respondsToSelector:@selector(MCGestureDelegate:recognizedGestureWithName:score:ratio:rotation:size:)]) {
			NSString *objectname = [ ((NSDictionary*)[_gestures objectAtIndex:t]) objectForKey:@"name"];
			[p_associatedView.p_delegate MCGestureDelegate: p_associatedView recognizedGestureWithName:objectname score:score ratio:ratio rotation:rotation size:size];
		}
	} else {		
		if ([p_associatedView.p_delegate respondsToSelector:@selector(MCGestureDelegateGestureNotRecognized:)])
			[p_associatedView.p_delegate MCGestureDelegateGestureNotRecognized: p_associatedView];
	}
}


@end
