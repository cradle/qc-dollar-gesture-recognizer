//
//  NSValue+CGPointConversions.h
//  Jestieur
//
//  Created by Glenn Murray on 24/06/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSValue(CGPointConversions)
+ (NSValue *) valueWithCGPoint: (CGPoint) point;
- (CGPoint) CGPointValue;
@end

@interface NSValueCGPointConversions : NSObject
+ (NSValue *) NSValueWithCGPoint: (CGPoint) point;
@end