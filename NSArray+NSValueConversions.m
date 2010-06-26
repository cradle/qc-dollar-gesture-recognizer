//
//  NSArray+NSValueConversions.m
//  Jestieur
//
//  Created by Glenn Murray on 26/06/10.
//  Copyright 2010 glennfrancismurray. All rights reserved.
//

#import "NSArray+NSValueConversions.h"
#import "NSValue+CGPointConversions.h"

@implementation NSArray(NSValueConversions)

- (NSArray *) asDictionaryArray {
	NSMutableArray * p_dictArray = [NSMutableArray arrayWithCapacity:[self count]];
	for(NSValue *point in self) {
		[p_dictArray addObject: [point dictionaryValue]];
	}
	return p_dictArray;
}

@end