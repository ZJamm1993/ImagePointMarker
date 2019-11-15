//
//  PointMarkModel.m
//  ImagePointMarker
//
//  Created by zjj on 2019/11/15.
//  Copyright © 2019 zjj. All rights reserved.
//

#import "PointMarkModel.h"

@implementation PointMarkModel

- (NSMutableArray *)points {
    if (_points == nil) {
        _points = [NSMutableArray array];
    }
    return _points;
}

- (NSString *)jsonString {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    [dictionary setValue:self.name forKey:@"name"];
    
    NSMutableArray *points = [NSMutableArray array];
    NSInteger count = self.points.count;
    CGFloat height = self.image.size.height;
    CGFloat width = self.image.size.width;
    for (NSInteger i = 0; i < count; i++) {
        NSValue *value = self.points[i];
        NSPoint poi = value.pointValue;
        CGFloat x = poi.x / width;
        CGFloat y = 1.0 - (poi.y / height); // mac坐标系翻转
        [points addObject:@[@(i), @(x), @(y)]]; // 保存百分比，而不是绝对值
    }
    [dictionary setValue:points forKey:@"points"];
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

@end
