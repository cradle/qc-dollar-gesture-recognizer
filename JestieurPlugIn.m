//
//  JestieurPlugIn.m
//  Jestieur
//
//  Created by Glenn Francis Murray on 22/06/10.
//  Copyright (c) 2010 Glenn Francis Murray. All rights reserved.
//
//  TODO: insert license that allows distribution and enforces code sharing

#import "JestieurPlugIn.h"
#import "MCGestureCore.h"

#define	kQCPlugIn_Name				@"$1 Gesture Recognizer"
#define	kQCPlugIn_Description	    @"$1 Unistroke Gesture Recognizer QC Plugin by Glenn Francis Murray.\n\nRecognises gestures, or, more specifically, unistrokes. Unistrokes are defined as gestures (or glyphs) with a start and an end, and where 'the pen doesn't leave the paper'.\n\nThe plugin will track the input on X & Y whilst the 'Touch' boolean is true. When the 'Touch' boolean becomes false, it will calculate the closest gesture from its internal database, then write its name to that 'Name' output field, setting 'Match' to FALSE if there was none.\n\nThe X,Y cardinality is standard Quartz Composer, 2 units wide, [-1...1], (0,0) centered, square pixel - however - gestures are scale invariant, and in the current settings +- 45 degrees rotation also. This means that the relative resolution doesn't matter, it is resampled internally. \n\nThe returned 'score' value is how near the sampled gesture was to the reference gesture, 1.0 means perfect match (as far as $1 recognition is concerned). The 'ratio' output is a fraction of how close the 2nd nearest match was. It's (2ndBestScore/BestScore) so '1' means that there was another gesture almost just as fitting, lower is more certain it's just that one gesture.\n\nFor more information on the theory behind the $1 Recognizer, visit its originators at http://depts.washington.edu/aimgroup/proj/dollar/\n"
#define kQCPlugin_Copyright			@"\n//  Attribution must be preserved.\n//	Licence must be preserved upon transfer.\n//\n//  You have permission to:\n//   - use this plugin:\n//     + for personal use\n//	   + for personal profit (eg. VJ)\n//   - distribute this plugin:\n//     + not for profit:\n//		 > unmodified, without its source\n//		 > modified, with its source\n//     + for profit, as part of a larger work:\n//		 > modified or unmodified, with its source made public\n//   - modify this plugin:\n//	   + for personal use\n//	   + for personal profit, with modified source made public\n\n$1 Unistroke Recognizer QuartzComposer Plugin\nCopyright (c) 2010 Glenn Francis Murray. All rights reserved.\n\nThe ObjectiveC Code is based on MCGestureRecognizer by 'malcom' on 14/08/09.\nCopyright 2009 Daniele Margutti 'malcom'. All rights reserved.\nHe released the code for use in commercial or opensource projects without limitations, as long as with attribution:\n\t'MCGestureRecognizer by Daniele Margutti - http://www.malcom-mac.com'.\n\nMCGestureRecogniser signficantly modified by Glenn Francis Murray on 22/06/10\nModified to interact with QuartzComposer on OS X without UIKit & integrated into QCPlugIn.\n\nModifications Copyright (c) 2010 Glenn Francis Murray. All rights reserved.\n\nThe code is based on the '$1 Unistroke Recognizer'\n\tby Jacob O. Wobbrock,\n\tAndrew D. Wilson,\n\tYang Li \nhttp://depts.washington.edu/aimgroup/proj/dollar/\nhttp://blog.makezine.com/archive/2008/11/gesture_recognition_for_javasc.html"

@implementation JestieurPlugIn

/* MCGestureRecogniser Delegate Methods */ //TODO: move to a separate component
- (void) MCGestureDelegateGestureNotRecognized:(MCGestureView *) _view {
	self.outputStatus = @"Not recognized";
	self.outputMatch = FALSE;	
	self.outputScore = 0.0;
	self.outputRatio = 0.0;
	self.outputRotation = 0.0;
	self.outputSizeX = 0.0;
	self.outputSizeY = 0.0;
	self.outputName = @"";
	self.outputLastUnistroke = [p_gestureView postElaborationTouches];
}
- (void) MCGestureDelegate:(MCGestureView *) _view recognizedGestureWithName:(NSString *) _name score:(CGFloat) _score ratio:(CGFloat) _ratio rotation:(CGFloat) _rotation size:(CGSize) _size
{
	self.outputStatus = [NSString stringWithFormat:@"Best Match '%@' \n(score:%.2f,ratio:%.2f)",_name,_score,_ratio];
	self.outputMatch = TRUE;
	self.outputScore = (double)_score;
	self.outputRatio = (double)_ratio;
	self.outputName = [NSString stringWithString: _name];
	self.outputLastUnistroke = [p_gestureView postElaborationTouches];
	self.outputRotation =  _rotation * 180 / pi;
	self.outputSizeX = _size.width;
	self.outputSizeY = _size.height;
}
- (void) MCGestureDelegateRecognizingGesture:(MCGestureView *) _view {
	self.outputStatus = @"Processing...";
}

/* Attributes */
@dynamic inputX, inputY, inputTouch;
@dynamic outputStatus, outputErrors, outputName;
@dynamic outputScore, outputRatio, outputMatch, outputRotation;
@dynamic outputTemplateGestures, outputLastUnistroke;
@dynamic outputSizeX, outputSizeY;
@synthesize wasTouching, error;

+ (NSDictionary*) attributes
{
	return [NSDictionary dictionaryWithObjectsAndKeys:kQCPlugIn_Name, 
			QCPlugInAttributeNameKey, 
			kQCPlugIn_Description, 
			QCPlugInAttributeDescriptionKey,
			kQCPlugin_Copyright,
			QCPlugInAttributeCopyrightKey,
			nil];
}

+ (NSDictionary*) attributesForPropertyPortWithKey:(NSString*)key
{
	if([key isEqualToString:@"inputX"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"X Position", QCPortAttributeNameKey,
				nil];
	if([key isEqualToString:@"inputY"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Y Position", QCPortAttributeNameKey,
				nil];
	if([key isEqualToString:@"outputErrors"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Errors", QCPortAttributeNameKey,
				nil];
	if([key isEqualToString:@"outputStatus"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Status", QCPortAttributeNameKey,
				nil];
	if([key isEqualToString:@"inputTouch"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Touch", QCPortAttributeNameKey,
				FALSE, QCPortAttributeDefaultValueKey,
				nil];
	if([key isEqualToString:@"outputMatch"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Match?", QCPortAttributeNameKey,
				FALSE, QCPortAttributeDefaultValueKey,
				nil];
	if([key isEqualToString:@"outputName"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Name", QCPortAttributeNameKey,
				@"", QCPortAttributeDefaultValueKey,
				nil];
	if([key isEqualToString:@"outputRatio"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Ratio", QCPortAttributeNameKey,
				nil];
	if([key isEqualToString:@"outputRotation"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Rotation", QCPortAttributeNameKey,
				nil];
	if([key isEqualToString:@"outputScore"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Score", QCPortAttributeNameKey,
				nil];
	if([key isEqualToString:@"outputLastUnistroke"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Points", QCPortAttributeNameKey,
				nil];
	if([key isEqualToString:@"outputSizeX"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"X Size", QCPortAttributeNameKey,
				nil];
	if([key isEqualToString:@"outputSizeY"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Y Size", QCPortAttributeNameKey,
				nil];
	if([key isEqualToString:@"outputTemplateGestures"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Templates", QCPortAttributeNameKey,
				nil];	
	return nil;
}

+ (QCPlugInExecutionMode) executionMode {
	// Return the execution mode of the plug-in: kQCPlugInExecutionModeProvider, kQCPlugInExecutionModeProcessor, or kQCPlugInExecutionModeConsumer.
	return kQCPlugInExecutionModeProcessor;
}

+ (QCPlugInTimeMode) timeMode {
	// Return the time dependency mode of the plug-in: kQCPlugInTimeModeNone, kQCPlugInTimeModeIdle or kQCPlugInTimeModeTimeBase.
	return kQCPlugInTimeModeNone;
}

- (id) init
{
	if(self = [super init]) {
		p_gestureView = [MCGestureView new];
		
		NSBundle * pluginBundle = [NSBundle bundleWithIdentifier: @"com.glennfrancismurray.Jestieur"];
		NSString *_fpath = [pluginBundle pathForResource: @"gestures_data" ofType:@"txt"];
		BOOL loaded = [p_gestureView.p_analyzer addGestureFromFile:_fpath];
		if (!loaded) {
			self.error = [NSString stringWithFormat: @"Preloaded geometries not loaded. Missing file '%@'?", _fpath];
		} else {
			self.error = @"Gestures loaded";
		}
		if(!p_gestureView) {
			self.error = @"p_gestureView is null";
		}
	}
	
	return self;
}

- (void) finalize {
	[super finalize];
}

- (void) dealloc {	
	[super dealloc];
}

+ (NSArray*) plugInKeys {
	return nil;
}

- (id) serializedValueForKey:(NSString*)key; {
	/*
	Provide custom serialization for the plug-in internal settings that are not values complying to the <NSCoding> protocol.
	The return object must be nil or a PList compatible i.e. NSString, NSNumber, NSDate, NSData, NSArray or NSDictionary.
	*/
	return [super serializedValueForKey:key];
}

- (void) setSerializedValue:(id)serializedValue forKey:(NSString*)key {
	/*
	Provide deserialization for the plug-in internal settings that were custom serialized in -serializedValueForKey.
	Deserialize the value, then call [self setValue:value forKey:key] to set the corresponding internal setting of the plug-in instance to that deserialized value.
	*/
	[super setSerializedValue:serializedValue forKey:key];
}

- (QCPlugInViewController*) createViewController {
	/*
	Return a new QCPlugInViewController to edit the internal settings of this plug-in instance.
	You can return a subclass of QCPlugInViewController if necessary.
	*/
	return [[QCPlugInViewController alloc] initWithPlugIn:self viewNibName:@"Settings"];
}

@end

@implementation JestieurPlugIn (Execution)

- (BOOL) startExecution:(id<QCPlugInContext>)context
{
	// Return NO in case of fatal failure (this will prevent rendering of the composition to start).
	self.wasTouching = FALSE;	
	p_gestureView.p_delegate = self;
	//self.outputTemplateGestures = [p_gestureView.p_analyzer gestureTemplatesWithNSDictionaries];
	
	return YES;
}

- (void) enableExecution:(id<QCPlugInContext>)context
{
	// Called by Quartz Composer when the plug-in instance starts being used by Quartz Composer.
	return;
}

- (BOOL) execute:(id<QCPlugInContext>)context 
			atTime:(NSTimeInterval)time 
			withArguments:(NSDictionary*)arguments
{
	//Return NO in case of failure during the execution (this will prevent rendering of the current frame to complete). 

	// Arguments to the method execute:atTime:withArguments:.
	//extern NSString* const QCPlugInExecutionArgumentEventKey;
	//extern NSString* const QCPlugInExecutionArgumentMouseLocationKey;
	
	CGPoint touch = CGPointMake(self.inputX, self.inputY);
	
	if(self.inputTouch) {
		if(!self.wasTouching) {
			self.outputStatus = @"Start";
			[p_gestureView touchBegan: touch];
		} else {
			self.outputStatus = @"Sampling";
			[p_gestureView touchMoved: touch];
		}
	} else {
		if(self.wasTouching) {
			[p_gestureView touchEnded: touch];
		} else {
		}
	}
	
	self.wasTouching = self.inputTouch;
	self.outputErrors = self.error;//[NSString stringWithFormat: @"x: %f y: %f s: %i %i", self.inputX, self.inputY, self.wasTouching, self.inputTouch];
	
	return YES;
}

- (void) disableExecution:(id<QCPlugInContext>)context
{
	/*
	Called by Quartz Composer when the plug-in instance stops being used by Quartz Composer.
	*/
}

- (void) stopExecution:(id<QCPlugInContext>)context
{
	/*
	Called by Quartz Composer when rendering of the composition stops: perform any required cleanup for the plug-in.
	*/
}

@end
