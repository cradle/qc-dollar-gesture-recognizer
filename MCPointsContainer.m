//
//  MCPointsContainer.m
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

#import "MCPointsContainer.h"

#import "NSValue+CGPointConversions.h"

#define kAngleRange (45.0)

@implementation MCPointsContainer

- (id) init {
	return [self initWithPoints: NULL total:0];
}

- (id) initWithPointsArrayForTemplate:(NSArray *) _list sampleTo:(int) _maxsampled squareSize:(int) _square {
	self = [super init];
	if (self != nil) {
		p_pointsList = [[NSMutableArray alloc] initWithArray: _list];
		[self destructiveFastSampledArrayWithMax:_maxsampled];
		[self rotateToZero];
		[self scaleToSquareSize:_square];
		[self traslateToOrigin];
	}
	return self;
}

- (MCPointsContainer *) copyMe {
	MCPointsContainer *copy = [[MCPointsContainer alloc] initWithPointsArray: [self pointsArray]];
	return [copy autorelease];
}

- (id) initWithPointsArray:(NSArray *) _list {
	self = [super init];
	if (self != nil) {
		p_pointsList = [[NSMutableArray alloc] initWithArray: _list];
	}
	return self;
}

- (void) dealloc {
	[p_pointsList release];
	[super dealloc];
}

- (id) initWithPoints:(CGPoint *) _points total:(int) _npoints {
	self = [super init];
	if (self != nil) {
		p_pointsList = [[NSMutableArray alloc] init];
		for (int i=0; i < _npoints; i++)
			[p_pointsList addObject:[NSValue valueWithCGPoint: _points[i]]];
	}
	return self;
}

- (int) points {
	return [p_pointsList count];
}

- (void) getPoints:(CGPoint *) _points {
	for (int i = 0; i < [self points]; i++)
		_points[i] = [((NSValue *)[p_pointsList objectAtIndex:i]) CGPointValue];
}

- (void) destructiveFastSampledArrayWithMax:(int) _n {
	NSMutableArray *newpoints = [[NSMutableArray alloc] init];
	int c = [self points];
	for (int i = 0; i < _n; i++)
		[newpoints addObject: [NSValue valueWithCGPoint: 
							   [self pointAtIndex:MAX(0, (c-1)*i/(_n-1))]]];
	[p_pointsList release];
	p_pointsList = [newpoints retain];
}

- (MCPointsContainer *) fastSampledPointsWithMax:(int) _n {
	NSMutableArray *newpoints = [[NSMutableArray alloc] init];
	int c = [self points];
	for (int i = 0; i < _n; i++)
		[newpoints addObject: [NSValue valueWithCGPoint: 
							   [self pointAtIndex:MAX(0, (c-1)*i/(_n-1))]]];
	MCPointsContainer *new = [[[MCPointsContainer alloc] initWithPointsArray: newpoints] autorelease];
	[newpoints release];
	return new;
}

- (MCPointsContainer *) resampledPointsWithMax:(int) _n {
	CGFloat I = [self pathLength]/(float)((float)_n-1);
	CGFloat D = 0.0;
	
	NSMutableArray *srcPts = [[NSMutableArray alloc] initWithArray: p_pointsList];
	NSMutableArray *dstPts = [[NSMutableArray alloc] initWithObjects: [srcPts objectAtIndex:0],nil];
	
	for (int i = 1; i < [srcPts count]; i++) {
		CGPoint pt1 = [((NSValue*)[srcPts objectAtIndex:i-1]) CGPointValue];
		CGPoint pt2 = [((NSValue*)[srcPts objectAtIndex:i]) CGPointValue];
		
		CGFloat d = [self distanceFrom: pt1 to: pt2];
		if ((D+d) >= I) {
			CGFloat qx = pt1.x + ((I-D)/d)*(pt2.x-pt1.x);
			CGFloat qy = pt1.y + ((I-D)/d)*(pt2.y-pt1.y);
			NSValue *q = [NSValue valueWithCGPoint: CGPointMake(qx,qy)];
			[dstPts addObject: q];
			[srcPts insertObject: q atIndex:i];
			D= 0.0;
		} else {
			D += d;
		}
	}
	if ([dstPts count] == (_n-1)) {
		[dstPts addObject: [srcPts lastObject]];
	}
	[srcPts release];
	MCPointsContainer *sampled = [[MCPointsContainer alloc] initWithPointsArray: dstPts];
	[dstPts release];
	return [sampled autorelease];
}

- (CGFloat) pathLength {
	CGFloat d = 0.0;
	for (int i = 1; i < [self points]; i++)
		d+=[self distanceFrom: [self pointAtIndex:i-1] to: [self pointAtIndex:i]];
	return d;
}

- (CGFloat) distanceFrom:(CGPoint ) _p1 to:(CGPoint) _p2 {
	CGFloat dx = _p2.x - _p1.x;
	CGFloat dy = _p2.y - _p1.y;
	CGFloat res =  sqrtf(dx*dx + dy*dy);
	return res;
}

- (void) rotateBy:(CGFloat) _radians {
	CGPoint c = [self centroid];
	CGFloat cos = cosf(_radians);
	CGFloat sin = sinf(_radians);
	
	for (int i = 0; i < [self points]; i++) {
		CGPoint p = [self pointAtIndex: i];
		CGFloat dx = p.x - c.x;
		CGFloat dy = p.y - c.y;
		CGPoint newp = CGPointMake(dx * cos - dy * sin + c.x,
								   dx * sin + dy * cos + c.y);
		[p_pointsList replaceObjectAtIndex: i withObject: [NSValue valueWithCGPoint: newp]];
	}
}

- (CGPoint) scaleToSquareSize:(NSInteger) _size {
	CGRect B = [self boundingBox];
	CGPoint scale = CGPointMake((_size / B.size.width), (_size / B.size.height));
	for (int i=0; i < [self points]; i++) {
		CGPoint thisPoint = [self pointAtIndex: i];
		CGFloat qx = thisPoint.x * scale.x;
		CGFloat qy = thisPoint.y * scale.y;
		[p_pointsList replaceObjectAtIndex: i withObject: [NSValue valueWithCGPoint: CGPointMake(qx, qy)]];
	}
	return scale;
}

- (CGFloat) rotateToZero {
	CGPoint c = [self centroid];
	CGPoint cFirstPoint = [self pointAtIndex: 0];
	CGFloat theta = atan2f(c.y-cFirstPoint.y,c.x-cFirstPoint.x);
	[self rotateBy: -theta];
	return theta;
}

- (void) traslateToOrigin {
	CGPoint c = [self centroid];	
	for (int i = 0; i < [self points]; i++) {
		CGPoint cPoint = [self pointAtIndex: i];
		CGFloat qx = cPoint.x - c.x;
		CGFloat qy = cPoint.y - c.y;
		[p_pointsList replaceObjectAtIndex: i withObject: [NSValue valueWithCGPoint: CGPointMake(qx, qy)]];
	}
}

- (CGRect) boundingBox {
	CGFloat minX = +INFINITY;
	CGFloat maxX = -INFINITY;
	CGFloat minY = +INFINITY;
	CGFloat maxY = -INFINITY;
	for (int i = 0; i < [self points]; i++) {
		CGPoint cPoint = [self pointAtIndex: i];
		minX = MIN(cPoint.x,minX);
		maxX = MAX(cPoint.x,maxX);
		minY = MIN(cPoint.y,minY);
		maxY = MAX(cPoint.y,maxY);
	}
	return CGRectMake(minX, minY, maxX-minX, maxY-minY);
}

- (CGPoint) centroid {
	CGPoint center = CGPointZero;
	for (int i = 0; i < [self points]; i++) {
		CGPoint cPoint = [self pointAtIndex: i];
		center.x += cPoint.x;
		center.y += cPoint.y;
	}
	center.x /= [self points];
	center.y /= [self points];
	return center;
}

- (CGFloat) distanceAtAngleWithTemplatePoints:(MCPointsContainer *) _templatepts theta:(CGFloat) _theta {
	MCPointsContainer *copy = [self copyMe];
	[copy rotateBy: _theta];
	return [copy pathDistanceWithTemplatePoints: _templatepts];
}

- (CGPoint) pointAtIndex:(int) _i {
	return [((NSValue*)[p_pointsList objectAtIndex: _i]) CGPointValue];
}

- (CGFloat) pathDistanceWithTemplatePoints:(MCPointsContainer *) _templatepts {
	CGFloat d = 0.0;
	for (int i = 0; i < [self points]; i++) // assumes pts1.length == pts2.length
		d+= [self distanceFrom: [self pointAtIndex:i] to: [_templatepts pointAtIndex: i]];
	return d / (CGFloat)[self points];
}

- (CGFloat) distanceAtBestAngleWithTemplate:(MCPointsContainer *) _template {
	CGFloat _a = -kAngleRange;
	CGFloat _b = +kAngleRange;
	CGFloat _threshold= 2.0f;
	CGFloat PHI = 0.5 * (-1.0 + sqrt(5.0)); // Golden Ratio
	
	CGFloat x1 = PHI * _a + (1.0 - PHI) * _b;
	CGFloat f1 = [self distanceAtAngleWithTemplatePoints: _template  theta: x1];
	CGFloat x2 = (1.0 - PHI) * _a + PHI * _b;
	CGFloat f2 = [self distanceAtAngleWithTemplatePoints: _template theta: x2];
	
	while (abs(_b-_a) > _threshold) {
		if (f1 < f2) {
			_b = x2;
			x2 = x1;
			f2 = f1;
			x1 = PHI * _a + (1.0 - PHI) * _b;
			f1 = [self distanceAtAngleWithTemplatePoints: _template theta: x1];
		} else {
			_a = x1;
			x1 = x2;
			f1 = f2;
			x2 = (1.0-PHI)*_a+PHI*_b;
			f2 = [self distanceAtAngleWithTemplatePoints: _template theta:x2];
		}
	}
	return MIN(f1, f2);
}

- (void) addPoint:(CGPoint) _point {
	[p_pointsList addObject: [NSValue valueWithCGPoint:_point]];	 
}

- (void) clearPoints {
	[p_pointsList removeAllObjects];
}

- (NSArray *) pointsArray {
	return p_pointsList;
}
@end