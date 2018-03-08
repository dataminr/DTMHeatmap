//
//  ViewController.m
//  DTMHeatMapExample
//
//  Created by Bryan Oltman on 1/7/15.
//  Copyright (c) 2015 Dataminr. All rights reserved.
//

#import "ViewController.h"
#import "DTMHeatmapRenderer.h"
#import "DTMDiffHeatmap.h"

@interface ViewController ()
@property (strong, nonatomic) DTMHeatmap *heatmap;
@property (strong, nonatomic) DTMDiffHeatmap *diffHeatmap;
@end

@implementation ViewController {
    BOOL accidentsCenter;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupHeatmaps];
}

- (void)setupHeatmaps
{
    // Set map region
    [self setAccidentsCenter];
    
    self.heatmap = [DTMHeatmap new];
    [self.heatmap setData:[self parseAccidentsFile:@"accidents_geo"]];
    [self.mapView addOverlay:self.heatmap];

    self.diffHeatmap = [DTMDiffHeatmap new];
    [self.diffHeatmap setBeforeData:[self parseLatLonFile:@"first_week"]
                          afterData:[self parseLatLonFile:@"third_week"]];
}

- (void) setAccidentsCenter {
    // Set map region
    accidentsCenter = true;
    MKCoordinateSpan span = MKCoordinateSpanMake(0.02, 0.02);
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(41.3810048, 2.1831424);
    self.mapView.region = MKCoordinateRegionMake(center, span);
}

- (void) setWeeksCenter {
    // Set map region
    accidentsCenter = false;
    MKCoordinateSpan span = MKCoordinateSpanMake(1.0, 1.0);
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(38.5556, -121.4689);
    self.mapView.region = MKCoordinateRegionMake(center, span);
}

- (NSDictionary *)parseLatLonFile:(NSString *)fileName
{
    NSMutableDictionary *ret = [NSMutableDictionary new];
    NSString *path = [[NSBundle mainBundle] pathForResource:fileName
                                                     ofType:@"txt"];
    NSString *content = [NSString stringWithContentsOfFile:path
                                                  encoding:NSUTF8StringEncoding
                                                     error:NULL];
    NSArray *lines = [content componentsSeparatedByString:@"\n"];
    for (NSString *line in lines) {
        NSArray *parts = [line componentsSeparatedByString:@","];
        NSString *latStr = parts[0];
        NSString *lonStr = parts[1];
        
        CLLocationDegrees latitude = [latStr doubleValue];
        CLLocationDegrees longitude = [lonStr doubleValue];
        
        // For this example, each location is weighted equally
        double weight = 1;
        
        CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude
                                                          longitude:longitude];
        MKMapPoint point = MKMapPointForCoordinate(location.coordinate);
        NSValue *pointValue = [NSValue value:&point
                                withObjCType:@encode(MKMapPoint)];
        ret[pointValue] = @(weight);
    }
    
    return ret;
}

- (NSDictionary *)parseAccidentsFile:(NSString *)fileName
{
    NSMutableDictionary *ret = [NSMutableDictionary new];
    NSString *path = [[NSBundle mainBundle] pathForResource:fileName
                                                     ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile: path];
    NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSArray *accidents = [jsonData objectForKey:@"accidents"];
    for (NSDictionary* jsonAccident in accidents) {
        NSNumber *lat = [jsonAccident objectForKey:@"lat"];
        NSNumber *lon = [jsonAccident objectForKey:@"lon"];
        
        CLLocationDegrees latitude = [lat doubleValue];
        CLLocationDegrees longitude = [lon doubleValue];
        
        // For this example, each location is weighted equally
        double weight = 1;
        
        CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude
                                                          longitude:longitude];
        MKMapPoint point = MKMapPointForCoordinate(location.coordinate);
        NSValue *pointValue = [NSValue value:&point
                                withObjCType:@encode(MKMapPoint)];
        ret[pointValue] = @(weight);
    }

    
    return ret;
}

- (IBAction)segmentedControlValueChanged:(UISegmentedControl *)sender
{
    switch (sender.selectedSegmentIndex) {
        case 0:
            [self setAccidentsCenter];
            [self.mapView removeOverlay:self.diffHeatmap];
            [self.heatmap setData:[self parseAccidentsFile:@"accidents_geo"]];
            [self.mapView addOverlay:self.heatmap];
            break;
        case 1:
            [self setWeeksCenter];
            [self.mapView removeOverlay:self.diffHeatmap];
            [self.heatmap setData:[self parseLatLonFile:@"first_week"]];
            [self.mapView addOverlay:self.heatmap];
            break;
        case 2:
            [self setWeeksCenter];
            [self.mapView removeOverlay:self.diffHeatmap];
            [self.heatmap setData:[self parseLatLonFile:@"third_week"]];
            [self.mapView addOverlay:self.heatmap];
            break;
        case 3:
            [self setWeeksCenter];
            [self.mapView removeOverlay:self.heatmap];
            [self.mapView addOverlay:self.diffHeatmap];
            break;
    }
}

#pragma mark - MKMapViewDelegate
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    DTMHeatmapRenderer * renderer = [[DTMHeatmapRenderer alloc] initWithOverlay:overlay];
    renderer.zoomNormalization = accidentsCenter;
    return renderer;
}

@end
