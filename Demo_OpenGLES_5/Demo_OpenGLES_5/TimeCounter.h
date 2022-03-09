//
//  TimeCounter.h
//  Demo_OpenGLES_5
//
//  Created by billthaslu on 2022/3/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TimeCounter : NSObject

- (void)countOnceStart;

- (void)countOnceEnd;

- (void)countOnceStartWithKey:(NSString *)key;

- (void)countOnceEndWithKey:(NSString *)key;

- (void)logStatisticsWithKey:(NSString *)key;

- (void)logAllStatistics;

- (void)clearAll;

@end

NS_ASSUME_NONNULL_END
