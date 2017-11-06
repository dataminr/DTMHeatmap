//
//  DTMHeatmapRenderer.m
//  HeatMapTest
//
//  Created by Bryan Oltman on 1/6/15.
//  Copyright (c) 2015 Dataminr. All rights reserved.
//

#import "DTMHeatmapRenderer.h"
#import "DTMColorProvider.h"

// This sets the spread of the heat from each map point (in screen pts.)
static const NSInteger kSBHeatRadiusInPoints = 48;

@interface DTMHeatmapRenderer ()
@property (nonatomic, readonly) float *scaleMatrix;
@end

@implementation DTMHeatmapRenderer {
    NSInteger heatRadiusInPoints;
}

- (id)initWithOverlay:(id <MKOverlay>)overlay
{
    self = [self initWithOverlay:overlay andHeatRadiusPoints:kSBHeatRadiusInPoints];
    return self;
}

- (id)initWithOverlay:(id <MKOverlay>)overlay andHeatRadiusPoints: (NSInteger) heatRadius {
    if (self = [super initWithOverlay:overlay]) {
        heatRadiusInPoints = heatRadius;
        _scaleMatrix = malloc(2 * heatRadiusInPoints * 2 * heatRadiusInPoints * sizeof(float));
        [self populateScaleMatrix];
        self.zoomNormalization = false;
    }
    
    return self;
}

- (void)dealloc
{
    free(_scaleMatrix);
}

- (void)populateScaleMatrix
{
    for (int i = 0; i < 2 * heatRadiusInPoints; i++) {
        for (int j = 0; j < 2 * heatRadiusInPoints; j++) {
            float distance = sqrt((i - heatRadiusInPoints) * (i - heatRadiusInPoints) + (j - heatRadiusInPoints) * (j - heatRadiusInPoints));
            float scaleFactor = 1 - distance / heatRadiusInPoints;
            if (scaleFactor < 0) {
                scaleFactor = 0;
            } else {
                scaleFactor = (expf(-distance/10.0) - expf(-heatRadiusInPoints/10.0)) / expf(0);
            }
            
            _scaleMatrix[j * 2 * heatRadiusInPoints + i] = scaleFactor;
        }
    }
}

- (void)drawMapRect:(MKMapRect)mapRect
          zoomScale:(MKZoomScale)zoomScale
          inContext:(CGContextRef)context
{
    CGRect usRect = [self rectForMapRect:mapRect]; //rect in user space coordinates (NOTE: not in screen points)
    MKMapRect visibleRect = [self.overlay boundingMapRect];
    MKMapRect mapIntersect = MKMapRectIntersection(mapRect, visibleRect);
    CGRect usIntersect = [self rectForMapRect:mapIntersect]; //rect in user space coordinates (NOTE: not in screen points)
    
    int columns = ceil(CGRectGetWidth(usRect) * zoomScale);
    int rows = ceil(CGRectGetHeight(usRect) * zoomScale);
    int arrayLen = columns * rows;
    
    // allocate an array matching the screen point size of the rect
    float *pointValues = calloc(arrayLen, sizeof(float));
   
    if (pointValues) {
        // pad out the mapRect with the radius on all sides.
        // we care about points that are not in (but close to) this rect
        CGRect paddedRect = [self rectForMapRect:mapRect];
        paddedRect.origin.x -= heatRadiusInPoints / zoomScale;
        paddedRect.origin.y -= heatRadiusInPoints / zoomScale;
        paddedRect.size.width += 2 * heatRadiusInPoints / zoomScale;
        paddedRect.size.height += 2 * heatRadiusInPoints / zoomScale;
        MKMapRect paddedMapRect = [self mapRectForRect:paddedRect];
        
        // Get the dictionary of values out of the model for this mapRect and zoomScale.
        DTMHeatmap *hm = (DTMHeatmap *)self.overlay;
        NSDictionary *heat = [hm mapPointsWithHeatInMapRect:paddedMapRect
                                                    atScale:zoomScale];
        
        double maxValue = 0;
        for (NSValue *key in heat) {
            // convert key to mapPoint
            MKMapPoint mapPoint;
            [key getValue:&mapPoint];
            double value = [[heat objectForKey:key] doubleValue];
            
            // figure out the correspoinding array index
            CGPoint usPoint = [self pointForMapPoint:mapPoint];
            
            CGPoint matrixCoord = CGPointMake((usPoint.x - usRect.origin.x) * zoomScale,
                                              (usPoint.y - usRect.origin.y) * zoomScale);
            
            if (value != 0 && !isnan(value)) { // don't bother with 0 or NaN
                // iterate through surrounding pixels and increase
                for (int i = 0; i < 2 * heatRadiusInPoints; i++) {
                    for (int j = 0; j < 2 * heatRadiusInPoints; j++) {
                        // find the array index
                        int column = floor(matrixCoord.x - heatRadiusInPoints + i);
                        int row = floor(matrixCoord.y - heatRadiusInPoints + j);
                        
                        // make sure this is a valid array index
                        if (row >= 0 && column >= 0 && row < rows && column < columns) {
                            int index = columns * row + column;
                            double addVal = value * _scaleMatrix[j * 2 * heatRadiusInPoints + i];
                            pointValues[index] += addVal;
                            
                            if (pointValues[index] > maxValue) {
                                maxValue = pointValues[index];
                            }
                        }
                    }
                }
            }
        }
        
        double normalizedMax = log2(1/zoomScale);
        
        CGFloat red, green, blue, alpha;
        uint indexOrigin;
        unsigned char *rgba = (unsigned char *)calloc(arrayLen * 4, sizeof(unsigned char));
        DTMColorProvider *colorProvider = [hm colorProvider];
        for (int i = 0; i < arrayLen; i++) {
            if (pointValues[i] != 0) {
                indexOrigin = 4 * i;
                double value = self.zoomNormalization ? pointValues[i] / normalizedMax : pointValues[i];
                [colorProvider colorForValue:value
                                         red:&red
                                       green:&green
                                        blue:&blue
                                       alpha:&alpha];
                
                rgba[indexOrigin] = red;
                rgba[indexOrigin + 1] = green;
                rgba[indexOrigin + 2] = blue;
                rgba[indexOrigin + 3] = alpha;
            }
        }
        
        free(pointValues);

        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef bitmapContext = CGBitmapContextCreate(rgba,
                                                           columns,
                                                           rows,
                                                           8, // bitsPerComponent
                                                           4 * columns, // bytesPerRow
                                                           colorSpace,
                                                           kCGImageAlphaPremultipliedLast | kCGBitmapByteOrderDefault);

       
        CGImageRef cgImage = CGBitmapContextCreateImage(bitmapContext);
        UIImage *img = [UIImage imageWithCGImage:cgImage];
        UIGraphicsPushContext(context);
        [img drawInRect:usIntersect];
        UIGraphicsPopContext();
        
        CFRelease(cgImage);
        CFRelease(bitmapContext);
        CFRelease(colorSpace);
        free(rgba);
    }
}

@end
