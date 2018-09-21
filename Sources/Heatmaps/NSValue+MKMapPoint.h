//
//  NSValue+MKMapPoint.h
//  DTMHeatmap
//
//  Created by Cal Stephens on 12/16/17.
//  Copyright (c) 2015 Dataminr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface NSValue (MKMapPoint)

+ (NSValue * _Nonnull )valueWithMKMapPoint:(MKMapPoint)mapPoint;

@end
