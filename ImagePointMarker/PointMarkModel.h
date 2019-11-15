//
//  PointMarkModel.h
//  ImagePointMarker
//
//  Created by zjj on 2019/11/15.
//  Copyright © 2019 zjj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PointMarkModel : NSObject

@property (nonatomic, strong) NSMutableArray *points;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSImage *image;

@property (nonatomic, readonly) NSString *jsonString;

@end

NS_ASSUME_NONNULL_END
