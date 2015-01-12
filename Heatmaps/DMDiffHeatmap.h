//
//  DMDiffHeatmap.h
//  A heatmap with cool colors representing -1..0 and warm colors representing 0..1
//
//  Created by Bryan Oltman on 1/12/15.
//  Copyright (c) 2015 Dataminr. All rights reserved.
//

#import "DMBaseHeatmap.h"

@interface DMDiffHeatmap : DMBaseHeatmap

- (void)setBeforeData:(NSDictionary *)before
            afterData:(NSDictionary *)after;

@end
