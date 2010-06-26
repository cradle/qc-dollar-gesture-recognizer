//
//  NSValue+CGPointConversions.h
//  Jestieur
//
//  Implementing the missing functionality that is in UIKit
//	that MCGestureRecogniser is expecting
//
//  Created by Glenn Francis Murray on 24/06/10.
//  Public Domain
//

#import <Foundation/Foundation.h>

@interface NSValue(CGPointConversions)
+ (NSValue *) valueWithCGPoint: (CGPoint) point;
- (CGPoint) CGPointValue;
- (NSDictionary *) dictionaryValue;
@end

@interface NSValueCGPointConversions : NSObject
+ (NSValue *) NSValueWithCGPoint: (CGPoint) point;
@end