//
//  JestieurPlugIn.m
//  Jestieur
//
//  Created by Glenn Murray on 22/06/10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "JestieurPlugIn.h"
#import "MCGestureCore.h"

#define	kQCPlugIn_Name				@"Jestieur"
#define	kQCPlugIn_Description		@"Jestieur. Recognise gestures. Uses the MCGestureRecogniser which implements the $1 Gesture Recogniser"

@implementation JestieurPlugIn

/* MCGestureRecogniser Delegate Methods */ //TODO: move to a separate component
- (void) MCGestureDelegateGestureNotRecognized:(MCGestureView *) _view {
	self.outputStatus = @"Not recognized";
}
- (void) MCGestureDelegate:(MCGestureView *) _view recognizedGestureWithName:(NSString *) _name score:(CGFloat) _score ratio:(CGFloat) _ratio 
{
	self.outputStatus = [NSString stringWithFormat:@"Best Match '%@' \n(score:%.2f,ratio:%.2f)",_name,_score,_ratio];
}
- (void) MCGestureDelegateRecognizingGesture:(MCGestureView *) _view {
	self.outputStatus = @"Recognizing...";
}

/* Attributes */
@dynamic inputX, inputY, inputTouch, outputStatus, outputErrors;
@synthesize wasTouching, error;

+ (NSDictionary*) attributes
{
	return [NSDictionary dictionaryWithObjectsAndKeys:kQCPlugIn_Name, 
			QCPlugInAttributeNameKey, 
			kQCPlugIn_Description, 
			QCPlugInAttributeDescriptionKey, 
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
				//FALSE, QCPortAttributeDefaultValueKey,
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
		//[MCGestureView new]; // OBJC 2.0
		//[[MCGestureView alloc] init]; // OBJC 1.0
		p_gestureView = [MCGestureView new];
	}
	
	return self;
}

- (void) finalize
{
	/*
	Release any non garbage collected resources created in -init.
	*/
	
	[super finalize];
}

- (void) dealloc
{
	/*
	Release any resources created in -init.
	*/
	
	[super dealloc];
}

+ (NSArray*) plugInKeys
{
	/*
	Return a list of the KVC keys corresponding to the internal settings of the plug-in.
	*/
	
	return nil;
}

- (id) serializedValueForKey:(NSString*)key;
{
	/*
	Provide custom serialization for the plug-in internal settings that are not values complying to the <NSCoding> protocol.
	The return object must be nil or a PList compatible i.e. NSString, NSNumber, NSDate, NSData, NSArray or NSDictionary.
	*/
	
	return [super serializedValueForKey:key];
}

- (void) setSerializedValue:(id)serializedValue forKey:(NSString*)key
{
	/*
	Provide deserialization for the plug-in internal settings that were custom serialized in -serializedValueForKey.
	Deserialize the value, then call [self setValue:value forKey:key] to set the corresponding internal setting of the plug-in instance to that deserialized value.
	*/
	
	[super setSerializedValue:serializedValue forKey:key];
}

- (QCPlugInViewController*) createViewController
{
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
	/*
	Called by Quartz Composer when rendering of the composition starts: perform any required setup for the plug-in.
	Return NO in case of fatal failure (this will prevent rendering of the composition to start).
	*/
	self.wasTouching = FALSE;	
	p_gestureView.p_delegate = self;
	
	//NSError* theError = nil;
	//NSBundle * pluginBundle = [NSBundle bundleWithIdentifier: @"com.yourcompany.ReadFileToString"];
	//NSString * fileDataPath = [pluginBundle pathForResource: @"text" ofType:@"txt"];
	//NSString * datapath = @"/Users/glenn/Library/Graphics/Quartz Composer Plug-Ins/ReadFileToString.plugin/Contents/Resources/text.txt";
	//NSString *data = [NSString stringWithContentsOfFile: fileDataPath
	//										   encoding: NSASCIIStringEncoding
	//											  error: &theError];
	
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
	//self.error = [NSString stringWithFormat: "%p"];
	
	return YES;
}

- (void) enableExecution:(id<QCPlugInContext>)context
{
	/*
	Called by Quartz Composer when the plug-in instance starts being used by Quartz Composer.
	*/
	return;
}

- (BOOL) execute:(id<QCPlugInContext>)context 
			atTime:(NSTimeInterval)time 
			withArguments:(NSDictionary*)arguments
{
	//Called by Quartz Composer whenever the plug-in instance needs to execute.
	//Only read from the plug-in inputs and produce a result (by writing to the plug-in outputs or rendering to the destination OpenGL context) within that method and nowhere else.
	//Return NO in case of failure during the execution (this will prevent rendering of the current frame to complete). 

	CGPoint touch = CGPointMake(self.inputX, self.inputY);
	
	/*if(self.inputTouch) {
		self.wasTouching = TRUE;
		//if(!self.wasTouching) {
		//	self.wasTouching = TRUE;
			//[p_gestureView touchBegan: touch];
		//} else {
			//[p_gestureView touchMoved: touch];
		//}
	} else {
		//self.wasTouching = FALSE;
		//[p_gestureView touchEnded: touch];
	}	*/
	
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
			//self.outputStatus = @"End";
		} else {
			//self.outputStatus = @"Idle";
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
