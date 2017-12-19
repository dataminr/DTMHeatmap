# DTMHeatmap
A heatmap for iOS, implemented as an `MKOverlay` to provide seamless integration with MapKit.

This project is based on https://github.com/ryanolsonk/HeatMapDemo. It has been updated to improve performance and add a "diff" mode. https://github.com/gpolak/LFHeatMap was also referenced.

## Modes
### Standard

<img src="./DTMHeatmapExample/Images/std-heatmap.gif" />

This mode is a standard heatmap and should produce the same results as the original `HeatMapDemo` project, but more quickly.
### Diff

<img src="./DTMHeatmapExample/Images/diff-heatmap.gif" />

This mode compares two sets of data to visualize which areas have "heated up" and which have "cooled down". Increased activity is shown with warm colors, decreased activity is shown with cool colors.

## Installation
#### [CocoaPods](https://github.com/cocoapods/cocoapods)
Add `pod 'DTMHeatmap'` to your Podfile

#### [Carthage](https://github.com/Carthage/Carthage)
Add `github "dataminr/DTMHeatmap"` to your Cartfile

## Usage
Using `DTMHeatmap` is relatively straightforward. After installing using the instructions above:
  0. Register as a delegate of your map view
  1. Create an instance of `DTMHeatmap`
  2. Provide data in the form of a dictionary mapping `MKMapPoint` (wrapped in `NSValue` using `[NSValue value:&point withObjCType:@encode(MKMapPoint)]`) to weights
  3. Add the heatmap as an overlay to your map view.

In the simplest form, the code looks something like this:
``` objective-c
- (void)viewDidLoad
{
    self.mapView.delegate = self;

    // Create DTMHeatmap
    self.heatmap = [DTMHeatmap new];
    [self.heatmap setData:myData];
    [self.mapView addOverlay:self.heatmap];

    // or...
    // Create DTMDiffHeatmap
    self.diffHeatmap = [DTMDiffHeatmap new];
    [self.diffHeatmap setBeforeData:beforeData
                          afterData:afterData];
    [self.mapView addOverlay:self.diffHeatmap];
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView
            rendererForOverlay:(id<MKOverlay>)overlay
{
    return [[DTMHeatmapRenderer alloc] initWithOverlay:overlay];
}
```

As you can see, the only difference between the stanard heatmap API and that of the diff heatmap is that the diff heatmap requires two sets of data – before and after.

## Example Project
A sample project (`DTMHeatmapExample`) has been provided to demonstrate basic usage. There are currently four visualization options:
- Standard: shows US locations of McDonald's as a regular heatmap
- Week 1: shows Sacramento crime data for the first week of January 2006 as a regular heatmap
- Week 3: shows Sacramento crime data for the third week of January 2006 as a regular heatmap
- Diff: compares the data from Week 3 to Week 1 as a diff heatmap. As one might expect, the diff is fairly random. If you can recommend a better dataset, please let me know :)

### Data Sources
[McDonald's Locations](https://github.com/gavreh/usa-mcdonalds-locations)
