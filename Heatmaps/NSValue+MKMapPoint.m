//
//  NSValue+MKMapPoint.m
//  DTMHeatmap
//
//  Created by Cal Stephens on 12/16/17.
//  Copyright (c) 2015 Dataminr. All rights reserved.
//

#import "NSValue+MKMapPoint.h"

@implementation NSValue (MKMapPoint)

+ (NSValue *)valueWithMKMapPoint:(MKMapPoint)mapPoint {
    return [NSValue value:&mapPoint withObjCType:@encode(MKMapPoint)];
}

@end
