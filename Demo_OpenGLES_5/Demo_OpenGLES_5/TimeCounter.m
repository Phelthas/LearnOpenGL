//
//  TimeCounter.m
//  Demo_OpenGLES_5
//
//  Created by billthaslu on 2022/3/5.
//

#import "TimeCounter.h"

#pragma mark ----------------------------------StatisticModel----------------------------------

@interface StatisticModel : NSObject

@property (nonatomic, assign) NSInteger totalCount;
@property (nonatomic, assign) NSTimeInterval totalTime;
@property (nonatomic, assign) NSTimeInterval tempStartTime;

@end

@implementation StatisticModel
@end


#pragma mark ----------------------------------TimeCounter----------------------------------

@interface TimeCounter ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, StatisticModel *> *allDict;

@end

@implementation TimeCounter

- (instancetype)init {
    self = [super init];
    if (self) {
        _allDict = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)countOnceStart {
    [self countOnceStartWithKey:@"TempCountOnceKey"];
}

- (void)countOnceEnd {
    [self countOnceEndWithKey:@"TempCountOnceKey"];
}


#pragma mark -

- (void)countOnceStartWithKey:(NSString *)key {
    NSAssert(key && key.length > 0, @"key should not be nil");
    @synchronized (self) {
        StatisticModel *model = self.allDict[key];
        if (!model) {
            model = [[StatisticModel alloc] init];
            self.allDict[key] = model;
        }
        model.tempStartTime = CFAbsoluteTimeGetCurrent();
    }
}

- (void)countOnceEndWithKey:(NSString *)key {
    NSAssert(key && key.length > 0, @"key should not be nil");
    @synchronized (self) {
        StatisticModel *model = self.allDict[key];
        NSAssert(model != nil, @"no start for key:%@",key);
        NSTimeInterval endTime = CFAbsoluteTimeGetCurrent();
        model.totalCount += 1;
        model.totalTime += endTime - model.tempStartTime;
        model.tempStartTime = 0;
    }
}

- (void)logStatisticsWithKey:(NSString *)key {
    NSAssert(key && key.length > 0, @"key should not be nil");
    @synchronized (self) {
        StatisticModel *model = self.allDict[key];
        if (!model) {
            NSLog(@"%s nothing for key: %@", __FUNCTION__, key);
            return;
        }
        if (model.totalCount <= 0) {
            NSLog(@"%s statistics key:%@ totalCount is 0 !!!", __FUNCTION__, key);
            return;
        }
        NSLog(@"%s statistics \n key:%@,\n totalCount:%ld,\n totalTime:%f,\n averageTime:%f", __FUNCTION__, key, model.totalCount, model.totalTime, model.totalTime / model.totalCount);
    }
}

- (void)logAllStatistics {
    @synchronized (self) {
        for (NSString *key in self.allDict.allKeys) {
            [self logStatisticsWithKey:key];
        }
    }
}

- (void)clearAll {
    @synchronized (self) {
        [self.allDict removeAllObjects];
    }
}

@end
