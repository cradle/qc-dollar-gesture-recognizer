//
//  MCPointsContainer.h
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


@interface MCPointsContainer : NSObject {
	NSMutableArray *p_pointsList;
}

- (id) init;
- (id) initWithPoints:(CGPoint *) _points total:(int) _npoints;
- (id) initWithPointsArray:(NSArray *) _list;
- (id) initWithPointsArrayForTemplate:(NSArray *) _list sampleTo:(int) _maxsampled squareSize:(int) _square;
- (MCPointsContainer *) copyMe;

- (void) destructiveFastSampledArrayWithMax:(int) _n;
- (MCPointsContainer *) fastSampledPointsWithMax:(int) _n;
- (MCPointsContainer *) resampledPointsWithMax:(int) _n;

- (void) getPoints:(CGPoint *) _points;
- (int) points;
- (void) addPoint:(CGPoint) _point;
- (void) clearPoints;
- (NSArray *) pointsArray;
- (CGPoint) pointAtIndex:(int) _i;

- (CGPoint) centroid;
- (CGFloat) pathLength;

- (void) rotateBy:(CGFloat) _radians;
- (CGFloat) rotateToZero;

- (CGPoint) scaleToSquareSize:(NSInteger) _size;
- (void) traslateToOrigin;
- (CGRect) boundingBox;

- (CGFloat) distanceAtAngleWithTemplatePoints:(MCPointsContainer *) _templatepts theta:(CGFloat) _theta;
- (CGFloat) pathDistanceWithTemplatePoints:(MCPointsContainer *) _templatepts;
- (CGFloat) distanceAtBestAngleWithTemplate:(MCPointsContainer *) _template;
- (CGFloat) distanceFrom:(CGPoint ) _p1 to:(CGPoint) _p2;

@end
