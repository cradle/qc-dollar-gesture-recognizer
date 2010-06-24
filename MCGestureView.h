//
//  MCGestureView.h
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

#import "NSValue+CGPointConversions.h"

@protocol MCGestureDelegate
- (void) MCGestureDelegate:(MCGestureView *) _view recognizedGestureWithName:(NSString *) _name score:(CGFloat) _score ratio:(CGFloat) _ratio;
- (void) MCGestureDelegateGestureNotRecognized:(MCGestureView *) _view;
@optional
- (void) MCGestureDelegate:(MCGestureView *) _view checkForGestureNamed:(NSString *) _name score:(CGFloat) _score;
- (void) MCGestureDelegateRecognizingGesture:(MCGestureView *) _view;
@end


@interface MCGestureView : NSObject {
	NSObject <MCGestureDelegate>*	p_delegate;
	
	@private
		MCGestureAnalyzer	*p_analyzer;
}
@property (retain) NSObject <MCGestureDelegate>*	p_delegate;
@property (readonly) MCGestureAnalyzer*				p_analyzer;

- (void)touchBegan: (CGPoint) touch;
- (void)touchMoved: (CGPoint) touch;
- (void)touchEnded: (CGPoint) touch;

#pragma mark PRIVATE METHODS
- (void) _initSettings;

@end
